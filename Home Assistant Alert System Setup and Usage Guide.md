# Home Assistant Alert System
## Complete Setup & Usage Guide

---

## Quick Setup Checklist

**Everything you need to do to get the alert system working:**

1. **Create Telegram Bot** via @BotFather → Get bot token
2. **Create Telegram Groups** (2 groups: Main Alerts + Technical Alerts) → Get Chat IDs  
3. **Configure Home Assistant Telegram Integration** → Add bot token and Chat IDs
4. **Update configuration.yaml** → Add packages directory and Lovelace dashboard
5. **Create directories** → `/config/packages/` and `/config/lovelace/`
6. **Download package files** → `alert_system.yaml` and `alert_system_dash.yaml`
7. **Configure secrets.yaml** → Add house name and Chat IDs
8. **Create update script** → `update_alerts.sh` for easy updates
9. **Restart Home Assistant** and test

**For multiple houses:** Repeat steps 2-3 and 7 for each additional house using the same bot token.

*Detailed instructions for each step are in the [Implementation Guide](#implementation-guide) section.*

---

## Table of Contents

1. [System Overview](#system-overview)
2. [Implementation Guide](#implementation-guide) 
3. [Testing Your Setup](#testing-your-setup)
4. [Using Alert Scripts](#using-alert-scripts)
5. [Creating Automations with Alerts](#creating-automations-with-alerts)
6. [Using the Lovelace Cards](#using-the-lovelace-cards)
7. [Essential Security](#essential-security)
8. [Maintenance & Updates](#maintenance--updates)
9. [Troubleshooting](#troubleshooting)

---

## System Overview

### What It Does

The Home Assistant Alert System provides intelligent Telegram notifications with dual-channel routing:

- **Main Channel**: Family-friendly notifications ("Dishwasher finished", "Pool temperature ready")
- **Technical Channel**: System administration alerts ("Low disk space", "Device offline") 
- **Security Alerts**: Always sent to both channels ("Motion detected when away")

### Key Features

- **9 Alert Scripts**: From simple `quick_alert` to advanced `bulk_alert`
- **Threshold Monitoring**: Automatic alerts when sensors exceed configured limits
- **Device Monitoring**: Alerts when devices go offline/online
- **Lovelace Dashboard**: Visual interface for managing alerts and generating automations
- **Multi-House Support**: One bot can serve multiple houses with separate channels

### Architecture

```
GitHub Repository (Optional)
       ↓
Home Assistant Package
       ↓
   Alert Scripts
       ↓
  Telegram Bot → Main Group + Technical Group
```

---

## Implementation Guide

### Prerequisites

- Home Assistant with packages support
- Telegram account 
- Internet access for downloading files

### Step 1: Create Telegram Bot and Groups

1. **Create Bot**: 
   - Message @BotFather on Telegram
   - Send `/newbot` and follow prompts
   - Save the bot token (looks like `123456789:ABCdefGhIJklmNoPQRsTUVwxyZ`)

2. **Create Groups**:
   - Create "House Main Alerts" group
   - Create "House Technical Alerts" group  
   - Add your bot to both groups as admin
   - Get Chat IDs using @getidsbot (will look like `-1001234567890`)

### Step 2: Configure Home Assistant Telegram Integration

1. **Add Integration**:
   - Settings → Devices & Services → Add Integration
   - Search "Telegram Bot" → Configure
   - Platform: Broadcast
   - API Key: Your bot token

2. **Add Chat IDs**:
   - Click "Configure" on the Telegram Bot integration
   - Add both Chat IDs to the allowed chat IDs list

### Step 3: Update Configuration Files

**configuration.yaml** - Add these lines:
```yaml
homeassistant:
  packages: !include_dir_named packages

lovelace:
  mode: storage
  dashboards:
    alert-system:
      mode: yaml
      title: Alert System
      icon: mdi:script
      show_in_sidebar: true
      filename: lovelace/alert_system_dash.yaml
```

**secrets.yaml** - Add these entries:
```yaml
house_name: "YOURHOUSENAME"
telegram_main_alerts: "-1001234567890"
telegram_technical_alerts: "-1001234567891"
```

### Step 4: Create Directory Structure

Create these directories in your Home Assistant config:
```bash
mkdir -p /config/packages/
mkdir -p /config/lovelace/
```

### Step 5: Download Package Files

**Option A: Manual Download**
1. Download `alert_system.yaml` to `/config/packages/`
2. Download `alert_system_dash.yaml` to `/config/lovelace/`

**Option B: Create Update Script** (Recommended)

Create `/config/update_alerts.sh`:
```bash
#!/bin/bash
# Home Assistant Alert System Updater

echo "🔄 Updating Home Assistant Alert System..."

# Navigate to packages directory
cd /config/packages/ || exit 1

########################
# Update alert_system.yaml
########################
if [ -f "alert_system.yaml" ]; then
    cp alert_system.yaml alert_system.yaml.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ Backed up current alert_system.yaml"
fi

echo "📥 Downloading latest alert_system.yaml from GitHub..."
wget -O alert_system.yaml.tmp https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/packages/alert_system.yaml

if [ $? -eq 0 ]; then
    mv alert_system.yaml.tmp alert_system.yaml
    echo "✅ Successfully updated alert_system.yaml"
else
    echo "❌ Failed to download alert_system.yaml"
    rm -f alert_system.yaml.tmp
    exit 1
fi

########################
# Update alert_system-dash.yaml  
########################
cd /config/lovelace/ || exit 1

if [ -f "alert_system_dash.yaml" ]; then
    cp alert_system_dash.yaml alert_system_dash.yaml.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ Backed up current alert_system_dash.yaml"
fi

echo "📥 Downloading latest alert_system_dash.yaml from GitHub..."
wget -O alert_system_dash.yaml.tmp https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/lovelace/alert_system_dash.yaml

if [ $? -eq 0 ]; then
    mv alert_system_dash.yaml.tmp alert_system_dash.yaml
    echo "✅ Successfully updated alert_system_dash.yaml"
else
    echo "❌ Failed to download alert_system_dash.yaml"
    rm -f alert_system_dash.yaml.tmp
    exit 1
fi

echo "🔄 Restart Home Assistant to apply changes"
```

Make executable: `chmod +x /config/update_alerts.sh`

### Step 6: First Installation

Run the update script or manually place the files, then restart Home Assistant.

### Multi-House Setup

For additional houses:
1. **Repeat Steps 2-3**: Configure Telegram integration with same bot token
2. **Create new groups** for the additional house  
3. **Update secrets.yaml** with the new house name and Chat IDs
4. **Use same package files** - they automatically adapt to each house's secrets

---

## Testing Your Setup

### Basic Connectivity Test

Test both channels:
```yaml
action: script.test_alert
data:
  channel: "both"
```

### Individual Channel Tests

**Main channel only:**
```yaml
action: script.main_alert
data:
  message: "Main channel test"
```

**Technical channel only:**
```yaml
action: script.tech_alert
data:
  message: "Technical channel test"
```

### Full Feature Test

Test all features at once:
```yaml
action: script.send_alert
data:
  message: "Full feature test with <b>HTML</b> formatting"
  level: "warning"
  channel: "both"
  location: "Test Location"
```

### Expected Results

- **Both channels**: Identical messages in both Telegram groups
- **Single channels**: Message appears only in specified group
- **Formatting**: Bold text, emojis, and location display correctly
- **Header format**: `🚨 YOURHOUSENAME WARNING 14:30`

---

## Using Alert Scripts

### Core Alert Scripts

| Script | Purpose | Default Channel | Example Usage |
|--------|---------|----------------|---------------|
| `test_alert` | System verification | Both | System testing |
| `quick_alert` | Simple notifications | Main | "Dishwasher finished" |
| `send_alert` | Full-featured alerts | Configurable | Complete control |
| `system_alert` | Technical issues | Technical | "High CPU usage" |
| `security_alert` | Security events | Both (forced) | "Motion detected" |
| `device_alert` | Device notifications | Technical | "Battery low" |
| `bulk_alert` | Multiple alerts | Mixed | Status reports |
| `tech_alert` | Technical convenience | Technical | Quick tech alerts |
| `main_alert` | Household convenience | Main | Quick main alerts |

### Alert Script Parameters

**Common parameters across scripts:**
- **message**: Alert content (required)
- **level**: `info`, `warning`, or `critical` 
- **location**: Manual location override (optional)
- **entity_id**: For automatic location detection (optional)
- **channel**: `main`, `technical`, or `both`
- **chat_id**: Direct message to specific chat (optional)

**Automatic Location Detection:**
- When `entity_id` is provided but `location` is empty, location is automatically filled from the entity's Home Assistant area assignment
- Manual `location` always takes priority over auto-detected location
- Entities not assigned to areas will show no location

### Alert Levels

- **info** (ℹ️): General information, completions, status updates
- **warning** (⚠️): Issues requiring attention but not critical  
- **critical** (🚨): Urgent issues requiring immediate action

### Common Usage Examples

**Simple household notification:**
```yaml
action: script.quick_alert
data:
  message: "Dishwasher cycle completed"
```

**Technical alert with location:**
```yaml
action: script.tech_alert
data:
  message: "Disk space low"
  level: "warning"
  location: "Server Rack"
```

**Security alert (always both channels):**
```yaml
action: script.security_alert
data:
  message: "Motion detected when house is empty"
  location: "Living Room"
```

**Complete control with all options:**
```yaml
action: script.send_alert
data:
  message: "Custom alert with all options"
  level: "critical"
  channel: "both"
  location: "Kitchen"  # Manual location (takes priority)
  entity_id: "sensor.kitchen_temperature"  # For auto-location if location empty
  include_timestamp: true
```

**Automatic location detection:**
```yaml
action: script.send_alert
data:
  message: "Temperature sensor reading high"
  level: "warning"
  channel: "main"
  entity_id: "sensor.living_room_temperature"
  # Location automatically filled from entity's Home Assistant area
```

### Bulk Alerts for Status Reports

Perfect for daily/weekly status reports:
```yaml
action: script.bulk_alert
data:
  alerts:
    - message: "🌅 Daily Status Report"
      level: "info" 
      channel: "main"
    - message: "Temperature: {{ states('sensor.temperature') }}°C"
      level: "info"
      location: "Climate"
      channel: "main"
    - message: "System uptime: {{ states('sensor.uptime') }} days"
      level: "info"
      location: "Server"
      channel: "technical"
```

---

## Creating Automations with Alerts

### Basic Automation Template

```yaml
alias: "My Alert Automation"
description: "Send alert when condition is met"
trigger:
  - platform: state
    entity_id: sensor.your_sensor
    # Add your trigger conditions
condition: []
action:
  - action: script.send_alert
    data:
      message: "Your alert message here"
      level: "warning"
      channel: "main"
      location: "Location Name"
mode: single
```

### Practical Examples

**Low battery alert with automatic location:**
```yaml
alias: "Low Battery Alert"
trigger:
  - platform: numeric_state
    entity_id: sensor.phone_battery
    below: 20
action:
  - action: script.device_alert
    data:
      device_name: "{{ state_attr(trigger.entity_id, 'friendly_name') }}"
      message: "Battery low ({{ trigger.to_state.state }}%)"
      level: "warning"
      entity_id: "{{ trigger.entity_id }}"  # Auto-detects location from entity area
```

**Door left open alert with automatic location:**
```yaml
alias: "Front Door Open Too Long"
trigger:
  - platform: state
    entity_id: binary_sensor.front_door
    to: "on"
    for: "00:10:00"  # 10 minutes
action:
  - action: script.main_alert
    data:
      message: "Front door has been open for 10 minutes"
      level: "warning"
      entity_id: "{{ trigger.entity_id }}"  # Auto-detects location from entity area
```

**System monitoring:**
```yaml
alias: "High CPU Alert"
trigger:
  - platform: numeric_state
    entity_id: sensor.processor_use
    above: 80
    for: "00:05:00"
action:
  - action: script.system_alert
    data:
      message: "CPU usage high ({{ states('sensor.processor_use') }}%)"
      level: "critical"
```

**Away mode security with automatic location:**
```yaml
alias: "Motion When Away"
trigger:
  - platform: state
    entity_id: binary_sensor.living_room_motion  
    to: "on"
condition:
  - condition: state
    entity_id: group.all_people
    state: "not_home"
action:
  - action: script.security_alert
    data:
      message: "Motion detected when house is empty"
      entity_id: "{{ trigger.entity_id }}"  # Auto-detects location from entity area
```

### Setting Up Areas for Automatic Location

To take advantage of automatic location detection, assign your entities to Home Assistant areas:

1. **Go to Settings → Areas & Zones**
2. **Create areas**: "Living Room", "Kitchen", "Bedroom", etc.
3. **Assign devices to areas**: 
   - Settings → Devices & Services → Devices
   - Click on a device → Edit → Area
4. **Entities inherit area**: Entities automatically get the device's area assignment

**Example area assignments:**
- `sensor.living_room_temperature` → "Living Room" area
- `binary_sensor.front_door` → "Front Entrance" area  
- `sensor.bedroom_humidity` → "Bedroom" area

**Benefits:**
- Threshold alerts automatically show room context
- Security alerts show which area triggered  
- Device alerts show where the device is located
- Manual location still overrides when needed

### Using Templates in Messages

**Dynamic sensor values:**
```yaml
message: "Temperature is {{ states('sensor.temperature') }}°C"
```

**Conditional messages:**
```yaml
message: >
  {% if states('sensor.humidity')|float > 70 %}
    Humidity too high ({{ states('sensor.humidity') }}%)
  {% else %}
    Humidity normal ({{ states('sensor.humidity') }}%)
  {% endif %}
```

**Time-based messages:**
```yaml
message: >
  {% set time = now().strftime('%H:%M') %}
  Good {% if now().hour < 12 %}morning{% else %}evening{% endif %}! 
  Current time: {{ time }}
```

---

## Using the Lovelace Cards

### Accessing the Dashboard

1. **Sidebar**: Click "Alert System" in the Home Assistant sidebar
2. **URL**: Navigate to `/lovelace/alert-system`

### Threshold Alert Management

**Create alerts for sensors that exceed limits:**

1. **Find Entity ID**: 
   - Go to Developer Tools → States
   - Search for your sensor (e.g., `sensor.temperature`)
   - Copy the entity_id

2. **Configure Alert**:
   - **Entity ID**: `sensor.bedroom_temperature`
   - **Threshold Value**: `25`
   - **Condition**: `above` or `below`
   - **Message**: Custom message (optional)

3. **Create Alert**: Click "✅ Create Alert"

**Management Functions**:
- **📋 List All**: View all configured threshold alerts
- **🗑️ Remove Alert**: Enter entity ID to remove specific alert
- **🗑️ Clear All**: Remove all threshold alerts (with confirmation)
- **🧪 Test System**: Send test alert to verify functionality

### Binary Sensor Automation Generator

**Generate Home Assistant automation code for binary sensors:**

1. **Fill Form**:
   - **Binary Sensor**: `binary_sensor.front_door`
   - **Trigger State**: `on` (opened), `off` (closed), or `Device Offline`
   - **Alert Message**: `"Front door opened"`
   - **Alert Level**: `warning`
   - **Channel**: `main`
   - **Location**: `Front Entrance` (optional)

2. **Validate**: Click "🔍 Validate Form" to check for errors

3. **Copy YAML**: The automation YAML code is automatically generated below the form

4. **Create Automation**:
   - Go to Settings → Automations & Scenes
   - Create New Automation → Edit in YAML
   - Paste the generated code and save

**Generated automations automatically include:**
- **Entity context**: `entity_id` parameter for automatic location detection
- **Proper formatting**: Ready-to-use YAML structure
- **Error handling**: Validated entity IDs and required fields

**Common Binary Sensors**:
- **Doors**: `binary_sensor.front_door`, `binary_sensor.garage_door`  
- **Motion**: `binary_sensor.living_room_motion`
- **Windows**: `binary_sensor.bedroom_window`
- **Safety**: `binary_sensor.smoke_detector`

### Dashboard Sections

**System Status Panel**:
- Enable/disable threshold alerts
- Set default alert channel
- View system status and alert count

**Alert Management**:
- Create custom threshold alerts
- Remove specific alerts  
- Bulk operations (list all, clear all)

**Automation Generator**:
- Generate automation YAML for binary sensors
- Form validation and error checking
- Copy-paste ready code

---

## Essential Security

### Bot Token Security

- **Store in secrets.yaml only** - never in configuration files
- **Use same token for multiple houses** - simplifies management
- **Rotate periodically** - update token every 6-12 months
- **Backup securely** - store token backup outside of Home Assistant

### Telegram Group Security

- **Private groups only** - never use public groups
- **Bot admin permissions** - bot needs admin rights to send messages
- **Regular member audit** - review who has access to alert groups
- **Clear naming** - use descriptive group names for easy identification

### Home Assistant Security

- **File permissions**: Ensure `secrets.yaml` has restricted access (600)
- **Regular updates**: Keep Home Assistant updated for security patches
- **Network security**: Use HTTPS for external access
- **Limited API access**: If using HTTP API, restrict access appropriately

### Best Practices

- **No sensitive data in alerts** - avoid personal information in messages
- **Generic location names** - use "Living Room" not specific addresses  
- **Monitor alert patterns** - watch for unusual alert activity
- **Test regularly** - verify alerts are working monthly

---

## Maintenance & Updates

### Regular Maintenance Tasks

**Weekly**:
- Test alert system functionality
- Review Home Assistant logs for errors
- Verify Telegram bot connectivity

**Monthly**:
- Clean old backup files
- Review threshold alert configurations
- Update documentation if needed

**Quarterly**:
- Security review of bot permissions
- Backup configuration files
- Performance analysis

### Update Procedures

**Using Update Script**:
```bash
# Run update script
/config/update_alerts.sh

# Restart Home Assistant
ha core restart

# Test functionality
# Run basic connectivity test
```

**Manual Update**:
1. **Backup current files**:
   ```bash
   cp /config/packages/alert_system.yaml /config/packages/alert_system.yaml.backup.$(date +%Y%m%d)
   ```
2. **Download new version** to `/config/packages/`
3. **Restart Home Assistant**
4. **Run tests** to verify functionality

**Version Control**:
- Update script automatically creates timestamped backups
- Keep 3-5 recent backups for quick rollback
- Document major changes in comments

### Backup Strategy

**Automatic Backups**:
- Update script creates backups before each update
- Format: `alert_system.yaml.backup.YYYYMMDD_HHMMSS`

**Manual Backups**:
```bash
# Full package backup
tar -czf alert_system_backup_$(date +%Y%m%d).tar.gz /config/packages/alert_system.yaml /config/lovelace/alert_system_dash.yaml

# Secrets backup (sanitize personal info)
grep -E "(house_name|telegram_)" /config/secrets.yaml > alert_secrets_backup.yaml
```

**Rollback Procedure**:
```bash
# List available backups
ls -la /config/packages/alert_system.yaml.backup.*

# Restore from backup
cp alert_system.yaml.backup.20240315_143022 alert_system.yaml

# Restart Home Assistant
ha core restart
```

---

## Troubleshooting

### Common Issues

#### Scripts Not Loading

**Symptoms**: Missing scripts in Developer Tools → Actions

**Solutions**:
1. **Check configuration.yaml**: Ensure `packages: !include_dir_named packages` is present
2. **Verify file location**: Package file must be in `/config/packages/alert_system.yaml`
3. **Check YAML syntax**: Use YAML validator or check HA logs
4. **Restart required**: Full restart needed after package changes

**Diagnostic commands**:
```bash
# Check file exists and permissions
ls -la /config/packages/alert_system.yaml

# Validate YAML syntax
ha core check

# Check logs for errors
tail -f /config/home-assistant.log | grep -i "package\|error"
```

#### No Telegram Messages

**Symptoms**: Scripts run without errors but no messages received

**Solutions**:
1. **Verify Chat IDs**: Check Chat IDs in secrets.yaml match your groups
2. **Check bot permissions**: Bot must be admin in groups with send message rights
3. **Test Telegram integration**: Use Developer Tools to test `telegram_bot.send_message`
4. **Network connectivity**: Ensure HA can reach Telegram servers

**Test direct API call**:
```
https://api.telegram.org/bot<YOUR_BOT_TOKEN>/sendMessage?chat_id=<CHAT_ID>&text=Direct%20test
```

#### Template Errors

**Symptoms**: Template warnings in logs about undefined variables

**Common errors**:
```
Template variable warning: 'location' is undefined
Template variable warning: 'channel' is undefined
```

**Solutions**:
1. **Update package**: Latest version includes default filters
2. **Check script calls**: Use exact parameter names from documentation
3. **Review logs**: Template errors are warnings, not failures

#### Threshold Alerts Not Triggering

**Symptoms**: Sensors cross thresholds but no alerts sent

**Solutions**:
1. **Check threshold alerts enabled**: `input_boolean.threshold_alerts_enabled` must be `on`
2. **Verify entity configuration**: Use "📋 List All" to see configured alerts
3. **Check sensor values**: Ensure sensor reports numeric values
4. **Review automation logs**: Check if threshold automation is triggering

**Diagnostic**:
```yaml
# Test threshold system
action: script.test_threshold_alert
```

### Log Analysis

**Important log locations**:
```bash
# Main Home Assistant log
/config/home-assistant.log

# Check for specific errors
grep -i "telegram\|alert\|template" /config/home-assistant.log
```

**Key error patterns**:
- **Package errors**: `Package alert_system setup failed`
- **Template errors**: `Template variable warning`
- **Telegram errors**: `Error sending message`
- **YAML errors**: `YAML syntax error`

### Getting Help

**Information to include when asking for help**:
1. **Home Assistant version** and installation type
2. **Error messages** from logs (sanitize personal information)
3. **Configuration snippets** (remove tokens and Chat IDs)
4. **Steps that reproduce the issue**
5. **Expected vs actual behavior**

**Useful diagnostic commands**:
```bash
# System info
ha core info

# Configuration check
ha core check

# Recent logs
ha core logs

# Package file validation
python3 -c "import yaml; print('Valid YAML' if yaml.safe_load(open('/config/packages/alert_system.yaml')) else 'Invalid YAML')"
```

---

## Appendix

### Complete File Structure

```
/config/
├── configuration.yaml          # Include packages and lovelace config
├── secrets.yaml               # House name and Chat IDs
├── packages/
│   └── alert_system.yaml      # Main package file
├── lovelace/
│   └── alert_system_dash.yaml # Dashboard configuration
└── update_alerts.sh           # Update script (optional)
```

### Required Secrets Template

```yaml
# secrets.yaml template
house_name: "Main House"
telegram_main_alerts: "-1001234567890"
telegram_technical_alerts: "-1001234567891"
```

### Minimum Configuration Changes

**configuration.yaml additions**:
```yaml
homeassistant:
  packages: !include_dir_named packages

lovelace:
  mode: storage
  dashboards:
    alert-system:
      mode: yaml
      title: Alert System
      icon: mdi:script
      show_in_sidebar: true
      filename: lovelace/alert_system_dash.yaml
```

This completes the comprehensive setup and usage guide for the Home Assistant Alert System. The system provides powerful, flexible alerting capabilities with an intuitive interface for both technical and non-technical users.