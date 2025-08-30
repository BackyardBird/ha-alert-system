#!/bin/bash
# Home Assistant Alert System Updater
# Updates the alert system package from GitHub

echo "🔄 Updating Home Assistant Alert System..."

# Navigate to packages directory
cd /config/packages/

# Backup current version
if [ -f "alert_system.yaml" ]; then
    cp alert_system.yaml alert_system.yaml.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ Backed up current version"
fi

# Download latest version
echo "📥 Downloading latest version from GitHub..."
wget -O alert_system.yaml.tmp https://raw.githubusercontent.com/BackyardBird/ha-alert-system/main/packages/alert_system.yaml

# Check if download was successful
if [ $? -eq 0 ]; then
    mv alert_system.yaml.tmp alert_system.yaml
    echo "✅ Successfully updated alert_system.yaml"
    echo "🔄 Restart Home Assistant to apply changes"
    echo ""
    echo "📋 Recent changes:"
    echo "   - Check your GitHub repository for latest commits"
    echo "   - Remember to test all alert types after restart"
else
    echo "❌ Failed to download update"
    rm -f alert_system.yaml.tmp
    exit 1
fi
