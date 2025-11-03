# DeployCFStack.ps1
param(
    [string]$Region = "us-east-1",
    [string]$BucketName
)

# ===== Controleer of AWS CLI aanwezig is =====
if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
    Write-Host "AWS CLI is niet geïnstalleerd. Installeer eerst AWS CLI v2." -ForegroundColor Red
    exit 1
}

Write-Host "AWS CLI gevonden, verder met deployment" -ForegroundColor Green

# ===== Vraag tijdelijke AWS credentials =====
$awsFile = ".\aws.txt"

# Als bestand er niet is, error
if (-Not (Test-Path $awsFile)) {
    Write-Host "Fout: aws.txt niet gevonden in de huidige map. Maak een bestand met deze inhoud:" -ForegroundColor Red
    Write-Host "aws_access_key_id=WAARDE" -ForegroundColor Yellow
    Write-Host "aws_secret_access_key=WAARDE" -ForegroundColor Yellow
    Write-Host "aws_session_token=WAARDE" -ForegroundColor Yellow
    exit 1
} 

Write-Host "aws.txt gevonden credentials worden ingelezen" -ForegroundColor Green

# Data inladen uit bestand
$awsData = @{}
Get-Content $awsFile | ForEach-Object {
    if ($_ -match '^\s*([^=]+)\s*=\s*(.+)\s*$') {
        $key = $matches[1].Trim()
        $value = $matches[2].Trim()
        $awsData[$key] = $value
    }
}

# Data opzoeken
foreach ($k in @('aws_access_key_id','aws_secret_access_key','aws_session_token')) {
    if (-not $awsData.ContainsKey($k)) {
        Write-Host "Fout: sleutel '$k' ontbreekt in aws.txt" -ForegroundColor Red
        exit 1
    }
}

# Data in variabele zetten
$AccessKey    = $awsData['aws_access_key_id']
$SecretKey    = $awsData['aws_secret_access_key']
$SessionToken = $awsData['aws_session_token']

# ===== Stel de omgeving in =====
$env:AWS_ACCESS_KEY_ID     = $AccessKey
$env:AWS_SECRET_ACCESS_KEY = $SecretKey
$env:AWS_SESSION_TOKEN     = $SessionToken
$env:AWS_DEFAULT_REGION    = $Region

# Controleer of credentials geldig zijn
$caller = aws sts get-caller-identity 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "`nFout: de ingevoerde credentials zijn ongeldig of verlopen." -ForegroundColor Red
    exit 1
}

if ($BucketName -eq "")
{
    $BucketName   = Read-Host "Geef naam voor de S3-bucket"
}

write-host "Bucketname is $BucketName" -ForegroundColor yellow

# ===== Haal automatisch AWS Account ID op =====
$AccountId = (aws sts get-caller-identity --query "Account" --output text 2>$null)

if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($AccountId) -or $AccountId -eq "null") {
  Write-Host "Kon AWS Account ID niet automatisch ophalen." -ForegroundColor Yellow
  $AccountId = Read-Host "Voer AWS Account ID handmatig in (bijv. 730335381450)"
  if ([string]::IsNullOrWhiteSpace($AccountId)) {
    Write-Host "Geen Account ID opgegeven. Stop." -ForegroundColor Red
    exit 1
  }
} else {
  Write-Host "AWS Account ID automatisch gevonden: $AccountId" -ForegroundColor Green
}

# ===== Functie om stack te deployen =====
function Deploy-Stack {
    param (
        [string]$StackName,
        [string]$TemplateFile,
        [switch]$IncludeCredentials,
        [switch]$IncludeBucketName
    )

    Write-Host ">>> Deploying stack: $StackName ($TemplateFile)" -ForegroundColor Cyan

    # Controleer of stack al bestaat
    $exists = aws cloudformation describe-stacks --region $Region --stack-name $StackName 2>$null

    $params = @()
    # Parameters indien nodig
    if ($IncludeCredentials) {
        $Params += (
            "ParameterKey=AccessKey,ParameterValue=$AccessKey",
            "ParameterKey=SecretKey,ParameterValue=$SecretKey",
            "ParameterKey=SessionToken,ParameterValue=$SessionToken",
            "ParameterKey=AccountId,ParameterValue=$AccountId"
        )
    }

    if ($IncludeBucketName) {
        $Params += "ParameterKey=BucketName,ParameterValue=$BucketName"
    }

    if ($LASTEXITCODE -eq 0) {
        # Stack bestaat al → update
        aws cloudformation update-stack `
            --region $Region `
            --stack-name $StackName `
            --template-body file://$TemplateFile `
            --parameters $Params `
            --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND

        if ($LASTEXITCODE -eq 0) {
            aws cloudformation wait stack-update-complete --region $Region --stack-name $StackName
            Write-Host "Stack $StackName updated." -ForegroundColor Green
        } else {
            Write-Host "Geen wijzigingen of fout bij update van $StackName." -ForegroundColor Yellow
        }
    } else {
        # Stack bestaat nog niet → create
        aws cloudformation create-stack `
            --region $Region `
            --stack-name $StackName `
            --template-body file://$TemplateFile `
            --parameters $Params `
            --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND

        if ($LASTEXITCODE -eq 0) {
            aws cloudformation wait stack-create-complete --region $Region --stack-name $StackName
            Write-Host "Stack $StackName created." -ForegroundColor Green
        } else {
            Write-Host "Fout bij aanmaken van $StackName." -ForegroundColor Red
            exit 1
        }
    }
}

# ===== Deployment volgorde =====
# 1. Base
Deploy-Stack -StackName "base-stack" -TemplateFile ".\base_file.yml"

# 2. Parallel (RDS, EFS, ELK)
Deploy-Stack -StackName "efs-stack" -TemplateFile ".\efs.yml"
Deploy-Stack -StackName "elk-stack" -TemplateFile ".\elk.yml"
Deploy-Stack -StackName "rds-stack" -TemplateFile ".\rds.yml"

# 3. EC2
Deploy-Stack -StackName "ec2-stack" -TemplateFile ".\ec2.yml" -IncludeCredentials -IncludeBucketName

# 4. Load Balancer
Deploy-Stack -StackName "lb-stack" -TemplateFile ".\Loadbalancer.yml"

# 5. Auto Scaling Group
Deploy-Stack -StackName "asg-stack" -TemplateFile ".\AutoScalingGroup.yml" -IncludeCredentials -IncludeBucketName

# 6. S3 bucket
Deploy-Stack -StackName "s3-stack" -TemplateFile ".\s3.yml" -IncludeBucketName
