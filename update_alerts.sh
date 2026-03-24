#!/bin/bash
# Home Assistant Alert System Updater
# Updates the alert system package + dashboard file from GitHub

echo "🔄 Updating Home Assistant Alert System..."

########################
# Update alert_system.yaml (in packages)
########################
cd /config/packages/ || exit 1

if [ -f "alert_system.yaml" ]; then
    cp alert_system.yaml alert_system.yaml.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ Backed up current alert_system.yaml"
fi

echo "📥 Downloading latest alert_system.yaml from GitHub..."
wget -O alert_system.yaml.tmp https://raw.githubusercontent.com/BackyardBird/ha-alert-system/main/packages/alert_system.yaml

if [ $? -eq 0 ]; then
    mv alert_system.yaml.tmp alert_system.yaml
    echo "✅ Successfully updated alert_system.yaml"
else
    echo "❌ Failed to download alert_system.yaml"
    rm -f alert_system.yaml.tmp
    exit 1
fi

########################
# Update alert_system_dash.yaml (in lovelace)
########################
cd /config/lovelace/ || exit 1

if [ -f "alert_system_dash.yaml" ]; then
    cp alert_system_dash.yaml alert_system_dash.yaml.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ Backed up current alert_system_dash.yaml"
fi

echo "📥 Downloading latest alert_system_dash.yaml from GitHub..."
wget -O alert_system_dash.yaml.tmp https://raw.githubusercontent.com/BackyardBird/ha-alert-system/main/lovelace/alert_system_dash.yaml

if [ $? -eq 0 ]; then
    mv alert_system_dash.yaml.tmp alert_system_dash.yaml
    echo "✅ Successfully updated alert_system_dash.yaml"
else
    echo "❌ Failed to download alert_system_dash.yaml"
    rm -f alert_system_dash.yaml.tmp
    exit 1
fi

########################
# Update blueprint
########################
mkdir -p /config/blueprints/automation/alert_system/

echo "Downloading latest send_alert blueprint from GitHub..."
wget -O /config/blueprints/automation/alert_system/send_alert.yaml.tmp https://raw.githubusercontent.com/BackyardBird/ha-alert-system/main/blueprints/automation/alert_system/send_alert.yaml

if [ $? -eq 0 ]; then
    mv /config/blueprints/automation/alert_system/send_alert.yaml.tmp /config/blueprints/automation/alert_system/send_alert.yaml
    echo "Successfully updated send_alert blueprint"
else
    echo "Failed to download blueprint (non-critical)"
    rm -f /config/blueprints/automation/alert_system/send_alert.yaml.tmp
fi

########################
# Final notes
########################
echo "🔄 Restart Home Assistant to apply changes"
echo ""
echo "📋 Recent changes:"
echo "   - Check your GitHub repository for latest commits"
echo "   - Remember to test all alert types after restart"
