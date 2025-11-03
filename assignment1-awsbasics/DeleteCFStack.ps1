# DeleteCFStack.ps1

param(
    [string]$Region = "us-east-1",
    [string[]]$StacksToDelete = @("asg-stack","lb-stack","ec2-stack","rds-stack","efs-stack","elk-stack","base-stack")
)

# Check of AWS CLI credentials beschikbaar zijn
$awsIdentity = aws sts get-caller-identity --region $Region 2>$null

if ($LASTEXITCODE -ne 0) {
    Write-Host "Voordat je begint met dit script, moet AWS geconfigureerd zijn!" -ForegroundColor Yellow
    exit 1
}

Write-Host "AWS CLI is geconfigureerd, verder met het verwijderen van stacks..." -ForegroundColor Green

# Functie om stack te verwijderen
function Delete-Stack {
    param (
        [string]$StackName
    )

    Write-Host ">>> Verwijderen stack: $StackName" -ForegroundColor Cyan

    # Controleer of de stack bestaat
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
            Write-Host "Fout bij verwijderen van $StackName." -ForegroundColor Red
        }
    } else {
        Write-Host "Stack $StackName bestaat niet, overslaan." -ForegroundColor Gray
    }
}

# Verwijder stacks in de juiste volgorde
foreach ($stack in $StacksToDelete) {
    Delete-Stack -StackName $stack
}

Write-Host "Alle opgegeven stacks zijn verwijderd (indien aanwezig)." -ForegroundColor Green
