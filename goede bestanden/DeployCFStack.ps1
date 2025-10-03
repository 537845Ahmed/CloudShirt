# DeployCFStack.ps1

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

# Functie om stack te deployen (update of create)
function Deploy-Stack {
    param (
        [string]$StackName,
        [string]$TemplateFile
    )

    Write-Host ">>> Deploying stack: $StackName ($TemplateFile)" -ForegroundColor Cyan

    $exists = aws cloudformation describe-stacks --region $Region --stack-name $StackName 2>$null

    if ($LASTEXITCODE -eq 0) {
        # Stack bestaat al, pas hem aan
        aws cloudformation update-stack `
            --region $Region `
            --stack-name $StackName `
            --template-body file://$TemplateFile `
            --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND

        if ($LASTEXITCODE -eq 0) {
            aws cloudformation wait stack-update-complete --region $Region --stack-name $StackName
            Write-Host "Stack $StackName updated." -ForegroundColor Green
        } else {
            Write-Host "Geen wijzigingen of fout bij update van $StackName." -ForegroundColor Yellow
        }
    } else {
        # Stack bestaat nog niet, maak hem aan
        aws cloudformation create-stack `
            --region $Region `
            --stack-name $StackName `
            --template-body file://$TemplateFile `
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
Deploy-Stack -StackName "ec2-stack" -TemplateFile ".\ec2.yml"

# 4. Load Balancer
Deploy-Stack -StackName "lb-stack" -TemplateFile ".\Loadbalancer.yml"

# 5. Auto Scaling Group
Deploy-Stack -StackName "asg-stack" -TemplateFile ".\AutoScalingGroup.yml"
