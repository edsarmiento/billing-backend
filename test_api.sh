#!/bin/bash

# Test script for the deployed Rails API
# Railway URL: https://api.technicaltest.xyz

echo "🚀 Testing Rails API at https://api.technicaltest.xyz"
echo "=================================================="

# Test 1: Health check
echo ""
echo "1️⃣ Testing health check endpoint:"
curl -s -w "\nStatus: %{http_code}\nTime: %{time_total}s\n" \
  "https://api.technicaltest.xyz/up"

# Test 2: Root endpoint
echo ""
echo "2️⃣ Testing root endpoint:"
curl -s -w "\nStatus: %{http_code}\nTime: %{time_total}s\n" \
  "https://api.technicaltest.xyz/"

# Test 3: Invoices index (with pagination)
echo ""
echo "3️⃣ Testing invoices index with pagination:"
curl -s -w "\nStatus: %{http_code}\nTime: %{time_total}s\n" \
  "https://api.technicaltest.xyz/api/v1/invoices?per_page=5&page=1" \
  -H "Accept: application/json"

# Test 4: Invoices index (without pagination)
echo ""
echo "4️⃣ Testing invoices index without pagination:"
curl -s -w "\nStatus: %{http_code}\nTime: %{time_total}s\n" \
  "https://api.technicaltest.xyz/api/v1/invoices" \
  -H "Accept: application/json"

# Test 5: Search invoices by status
echo ""
echo "5️⃣ Testing invoice search by status:"
curl -s -w "\nStatus: %{http_code}\nTime: %{time_total}s\n" \
  "https://api.technicaltest.xyz/api/v1/invoices?status=paid&per_page=3" \
  -H "Accept: application/json"

# Test 6: Search invoices by date range
echo ""
echo "6️⃣ Testing invoice search by date range:"
curl -s -w "\nStatus: %{http_code}\nTime: %{time_total}s\n" \
  "https://api.technicaltest.xyz/api/v1/invoices?date_from=2024-01-01&date_to=2024-12-31&per_page=3" \
  -H "Accept: application/json"

# Test 7: Export invoices to CSV
echo ""
echo "7️⃣ Testing invoice export to CSV:"
curl -s -w "\nStatus: %{http_code}\nTime: %{time_total}s\n" \
  "https://api.technicaltest.xyz/api/v1/invoices/export?per_page=5" \
  -H "Accept: text/csv" \
  -o invoices_export.csv

if [ -f invoices_export.csv ]; then
  echo "✅ CSV file downloaded: invoices_export.csv"
  echo "📄 First 5 lines of CSV:"
  head -5 invoices_export.csv
else
  echo "❌ CSV file not downloaded"
fi

# Test 8: Get specific invoice (if you have invoice numbers)
echo ""
echo "8️⃣ Testing specific invoice (replace INVOICE_NUMBER with actual number):"
curl -s -w "\nStatus: %{http_code}\nTime: %{time_total}s\n" \
  "https://api.technicaltest.xyz/api/v1/invoices/INVOICE-001" \
  -H "Accept: application/json"

# Test 9: Test with different Accept headers
echo ""
echo "9️⃣ Testing with different Accept headers:"
curl -s -w "\nStatus: %{http_code}\nTime: %{time_total}s\n" \
  "https://api.technicaltest.xyz/api/v1/invoices?per_page=2" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json"

# Test 10: Check response headers
echo ""
echo "🔟 Checking response headers:"
curl -s -I "https://api.technicaltest.xyz/api/v1/invoices?per_page=1" \
  -H "Accept: application/json"

echo ""
echo "✅ API testing completed!"
echo "📊 Check the responses above for status codes and response times"
