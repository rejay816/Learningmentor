#!/bin/bash

echo "Removing Sources/Core/New if it still exists..."
rm -rf "Sources/Core/New"

echo "Finding duplicates inside Sources/Core..."
# This command looks for files named Document.swift, User.swift, etc., repeated.
find Sources/Core -type f \( -iname "Document.swift" -o -iname "User.swift" -o -iname "Services.swift" -o -iname "ServiceProtocols.swift" \) \
  -exec ls -lh {} \;

echo "If you see the same filename in multiple places, remove or rename duplicates as needed."

echo "Cleaning build artifacts..."
rm -rf .build
rm -rf DerivedData
rm -f Package.resolved 