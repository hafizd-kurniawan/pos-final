#!/bin/bash

echo "=== Flutter App Analysis ==="
echo "Checking for potential issues..."

# Check if all imports are properly structured
echo -e "\n1. Checking main.dart structure..."
head -20 lib/main.dart

echo -e "\n2. Checking theme imports..."
grep -n "import.*app_theme" lib/main.dart || echo "Theme import not found"

echo -e "\n3. Checking constants imports..."
grep -n "import.*app_constants" lib/main.dart || echo "Constants import not found"

echo -e "\n4. Checking if all required files exist..."
required_files=(
    "lib/core/constants/app_theme.dart"
    "lib/core/constants/app_constants.dart" 
    "lib/core/constants/api_constants.dart"
    "lib/shared/models/models.dart"
    "lib/shared/widgets/app_widgets.dart"
    "lib/features/dashboard/screens/simple_dashboard.dart"
)

for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "✓ $file exists"
    else
        echo "✗ $file MISSING"
    fi
done

echo -e "\n5. Checking pubspec.yaml structure..."
head -15 pubspec.yaml

echo -e "\n6. Checking for any obvious syntax issues in main.dart..."
# Basic syntax check
if grep -q "class POSApp extends StatelessWidget" lib/main.dart; then
    echo "✓ POSApp class structure looks good"
else
    echo "✗ POSApp class structure issue"
fi

if grep -q "void main()" lib/main.dart; then
    echo "✓ main() function found"
else
    echo "✗ main() function missing"
fi

echo -e "\n=== Analysis Complete ==="
echo "If no major issues found above, the app should display properly."
echo "Try running: flutter pub get && flutter run -d chrome"