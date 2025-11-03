#!/bin/bash

# Bestanden met configuratie
endpoint_file="/mnt/efs/rds-endpoint"
bucket_file="/mnt/efs/s3-name"

# Controleer of de bestanden bestaan
if [ ! -f "$endpoint_file" ]; then
    echo "Fout: bestand $endpoint_file niet gevonden!"
    exit 1
fi

if [ ! -f "$bucket_file" ]; then
    echo "Fout: bestand $bucket_file niet gevonden!"
    exit 1
fi

# Lees waarden uit de bestanden
endpoint=$(cat "$endpoint_file" | tr -d '[:space:]')
bucket=$(cat "$bucket_file" | tr -d '[:space:]')

db_user="csadmin"
db_password="Welkom123!"
database="Microsoft.eShopOnWeb.CatalogDb"
table="dbo.Orders"

# Paden voor bestanden
export_csv="/tmp/orders.csv"
tmp_csv="/tmp/orders_tmp.csv"

export PATH=$PATH:/opt/mssql-tools/bin

# bcp -v

echo "Exporteren van $table van $database op $endpoint..."
#echo "user: $db_user || password: $db_password"

# Exporteer naar tijdelijke CSV
bcp "$table" out "$tmp_csv" -c -t, -S "$endpoint" -d "$database" -U "$db_user" -P "$db_password" -b 10000

if [ $? -ne 0 ]; then
    echo "Fout bij exporteren met bcp!"
    rm -f "$tmp_csv"
    exit 1
fi

# Controleer of het bestaande bestand bestaat en vergelijk
if [ -f "$export_csv" ]; then
    echo "Vergelijken met bestaande $export_csv..."
    if diff -q "$tmp_csv" "$export_csv" > /dev/null; then
        echo "Geen wijzigingen gedetecteerd — upload naar S3 wordt overgeslagen."
        rm -f "$tmp_csv"
        exit 0
    else
        echo "Wijzigingen gedetecteerd — nieuw bestand wordt geüpload."
    fi
else
    echo "Geen bestaand bestand gevonden — nieuw bestand wordt geüpload."
fi

# Overschrijf oude CSV met de nieuwe
mv "$tmp_csv" "$export_csv"

# Upload nieuwe data naar S3
echo "Uploaden naar s3://$bucket/orders.csv ..."
aws s3 cp "$export_csv" "s3://$bucket/orders.csv"

if [ $? -ne 0 ]; then
    echo "Fout bij uploaden naar S3!"
    sudo rm /tmp/orders.csv
    exit 1
fi

echo "Export en upload succesvol voltooid!"
