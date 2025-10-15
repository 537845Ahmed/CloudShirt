#!/bin/bash

read -p "Voer het RDS endpoint in (bijv. mydb.abcd1234.us-east-1.rds.amazonaws.com): " endpoint
read -p "Voer de S3 bucket naam in (bijv. mijn-bucket): " bucket

db_user="csadmin"
db_password="Welkom123!"
database="Microsoft.eShopOnWeb.CatalogDb"
table="dbo.Orders"

tmp_csv="/tmp/orders.csv"

export PATH=$PATH:/opt/mssql-tools/bin

echo "Exporteren van $table van $database op $endpoint..."

bcp "$table" out "$tmp_csv" -c -t, -S "$endpoint" -d "$database" -U "$db_user" -P "$db_password" -b 10000

if [ $? -ne 0 ]; then
    echo "Fout bij exporteren met bcp!"
    exit 1
fi

echo "Uploaden naar s3://$bucket/orders.csv ..."
aws s3 cp "$tmp_csv" "s3://$bucket/orders.csv"

if [ $? -ne 0 ]; then
    echo "Fout bij uploaden naar S3!"
    exit 1
fi

echo "Export en upload succesvol voltooid!"
