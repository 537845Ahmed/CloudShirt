# DeleteCFStackDocker.ps1
param(
    [string]$Region = "us-east-1",
    [string[]]$StacksToDelete = @(
        "s3-stack",
        "ec2-stack",
        "buildserver-stack",
        "rds-stack",
        "efs-stack",
        "elk-stack",
        "base-stack"
    )
)

# ===== Controleer of AWS CLI aanwezig is =====
if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
    Write-Host "AWS CLI is niet geïnstalleerd. Installeer eerst AWS CLI v2." -ForegroundColor Red
    exit 1
}

# Controleer of credentials geldig zijn
$awsIdentity = aws sts get-caller-identity --region $Region 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Fout: geen geldige AWS-credentials gevonden." -ForegroundColor Red
    Write-Host "Voer eerst het deployscript uit of stel tijdelijke credentials in." -ForegroundColor Yellow
    exit 1
}

Write-Host "AWS CLI geverifieerd, verder met het verwijderen van stacks..." -ForegroundColor Green

# ===== Functie om stack te verwijderen =====
function Delete-Stack {
    param (
        [string]$StackName
    )

    Write-Host ">>> Verwijderen stack: $StackName" -ForegroundColor Cyan

    # Controleer of stack bestaat
    $exists = aws cloudformation describe-stacks --region $Region --stack-name $StackName 2>$null

    if ($LASTEXITCODE -eq 0) {
        aws cloudformation delete-stack `
            --region $Region `
            --stack-name $StackName

        if ($LASTEXITCODE -eq 0) {
            Write-Host "Wachten tot stack $StackName volledig verwijderd is..." -ForegroundColor Yellow
            aws cloudformation wait stack-delete-complete --region $Region --stack-name $StackName
            Write-Host "Stack $StackName verwijderd." -ForegroundColor Green
        } else {
            Write-Host "Fout bij het starten van verwijderen voor $StackName." -ForegroundColor Red
        }
    } else {
        Write-Host "Stack $StackName bestaat niet, overslaan." -ForegroundColor Gray
    }
}

# ===== Verwijder stacks in juiste volgorde =====
foreach ($stack in $StacksToDelete) {
    Delete-Stack -StackName $stack
}

Write-Host "Alle opgegeven stacks zijn verwijderd (indien aanwezig)." -ForegroundColor Green
