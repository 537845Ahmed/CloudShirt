# DeployCFStackDocker.ps1
param(
    [string]$Region = "us-east-1"
)

# Check of AWS CLI credentials beschikbaar zijn
$awsIdentity = aws sts get-caller-identity --region $Region 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Voordat je begint met dit script, moet AWS geconfigureerd zijn!`nAWS configure" -ForegroundColor Yellow
    exit 1
}

Write-Host "AWS CLI is geconfigureerd, verder met deployment" -ForegroundColor Green

# ===== Vraag tijdelijke AWS credentials =====
Write-Host "`nVoer je tijdelijke AWS-credentials in (zoals uit AWS Academy 'Show AWS CLI Credentials')" -ForegroundColor Cyan

$AccessKey = Read-Host "AWS_ACCESS_KEY_ID"
$SecretKey = Read-Host "AWS_SECRET_ACCESS_KEY"
$SessionToken = Read-Host "AWS_SESSION_TOKEN"

# Exporteer ze voor deze sessie (zodat aws cli ook werkt)
$env:AWS_ACCESS_KEY_ID = $AccessKey
$env:AWS_SECRET_ACCESS_KEY = $SecretKey
$env:AWS_SESSION_TOKEN = $SessionToken

# ===== Functie om stack te deployen (update of create) =====
function Deploy-Stack {
    param (
        [string]$StackName,
        [string]$TemplateFile,
        [switch]$IncludeCredentials # Nieuw!
    )

    Write-Host ">>> Deploying stack: $StackName ($TemplateFile)" -ForegroundColor Cyan

    # Controleer of stack al bestaat
    $exists = aws cloudformation describe-stacks --region $Region --stack-name $StackName 2>$null

    # Als de stack credentials moet ontvangen
    if ($IncludeCredentials) {
        $Params = @(
            "ParameterKey=AccessKey,ParameterValue=$AccessKey",
            "ParameterKey=SecretKey,ParameterValue=$SecretKey",
            "ParameterKey=SessionToken,ParameterValue=$SessionToken"
        )
    } else {
        $Params = @()
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
Deploy-Stack -StackName "base-stack" -TemplateFile ".\base_file.yml"
Deploy-Stack -StackName "efs-stack" -TemplateFile ".\efs.yml"
Deploy-Stack -StackName "elk-stack" -TemplateFile ".\elk.yml"
Deploy-Stack -StackName "rds-stack" -TemplateFile ".\rds.yml"

# Deze twee stacks gebruiken de tijdelijke credentials in hun UserData:
Deploy-Stack -StackName "buildserver-stack" -TemplateFile ".\buildserver.yml" -IncludeCredentials
Deploy-Stack -StackName "ec2-stack" -TemplateFile ".\ec2Docker.yml" -IncludeCredentials

Deploy-Stack -StackName "s3-stack" -TemplateFile ".\s3.yml"
