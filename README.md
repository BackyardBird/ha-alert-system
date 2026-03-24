# Home Assistant Multi-House Alert System

[![Home Assistant](https://img.shields.io/badge/Home%20Assistant-2026.3+-blue.svg)](https://www.home-assistant.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A centralized, dual-channel notification system for Home Assistant designed for multi-house deployments. This system provides intelligent routing of alerts via Telegram, separating household notifications from technical system alerts.

## Key Features

### Multi-House Architecture
- **Single GitHub Repository** as source of truth for all houses
- **Automated Updates** via self-updating script deployment
- **House-Specific Configuration** with unique Telegram channels per location

### Dual-Channel Notifications
- **Main Channel**: Family-friendly notifications for daily life
- **Technical Channel**: System administration and device management alerts
- **Security Alerts**: Forced to both channels for maximum visibility

### Alert Scripts
- `script.send_alert` - Full-featured alerts with all options
- `script.system_alert` - Technical system alerts
- `script.security_alert` - Security events (both channels)
- `script.bulk_alert` - Send multiple alerts at once
- `script.test_alert` - System verification

### Smart Threshold Monitoring
- **Automatic threshold alerts** for any sensor with auto-generated messages
- **Device availability monitoring** (online/offline detection)
- **Offline-only monitoring** without requiring a threshold
- **Per-device offline delays** with global fallback
- **Visual dashboard** for managing alert rules

### Blueprint for Custom Automations
- **UI-driven form** for creating alert automations
- **Entity picker**, trigger state, message, level, channel, location, duration
- **No YAML editing required** - fill in the form and save

## Message Format

All alerts follow a consistent format:

```
HOUSE1 WARNING  14:30
Front door has been open for 10 minutes
>> Living Room
```

**Format Structure:**
- **Line 1**: [HOUSE] [LEVEL] [Timestamp]
- **Line 2**: [Message Content]
- **Line 3**: [>> Location] (if specified or auto-detected)

## Quick Start

### Prerequisites
- Home Assistant 2026.3+ with packages support
- Telegram Bot Token (from @BotFather)
- 2 Telegram groups per house (Main + Technical channels)

### Installation

1. **Fork this repository** or download the files

2. **Set up Telegram Bot Integration** in Home Assistant:
   - Settings > Devices & Services > Add Integration > Telegram Bot
   - Platform: Broadcast
   - Add your bot token and chat IDs

3. **Configure your Home Assistant**:

   Add to `configuration.yaml`:
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

   Update `secrets.yaml`:
   ```yaml
   house_name: "YOUR_HOUSE_NAME"
   telegram_main_alerts: "YOUR_MAIN_CHAT_ID"
   telegram_technical_alerts: "YOUR_TECHNICAL_CHAT_ID"
   ```

4. **Download the package files**:
   ```bash
   # Download the update script
   wget -O /config/update_alerts.sh https://raw.githubusercontent.com/BackyardBird/ha-alert-system/main/update_alerts.sh
   chmod +x /config/update_alerts.sh

   # Download all files
   /config/update_alerts.sh
   ```

5. **Restart Home Assistant** and test:
   ```yaml
   action: script.test_alert
   data:
     channel: "both"
   ```

## Usage Examples

### Basic Alerts
```yaml
# Simple notification to main channel
action: script.send_alert
data:
  message: "Dishwasher finished"
  level: "info"
  channel: "main"

# System alert (defaults to technical channel)
action: script.system_alert
data:
  message: "Low disk space: 95% full"
  level: "warning"

# Security alert (always goes to both channels)
action: script.security_alert
data:
  message: "Motion detected when away"
  location: "Living Room"
```

### Advanced Features
```yaml
# Full-featured alert with auto-location
action: script.send_alert
data:
  message: "Temperature sensor reading high"
  level: "warning"
  channel: "main"
  entity_id: "sensor.living_room_temperature"
  # Location automatically detected from entity's HA area

# Multiple alerts at once
action: script.bulk_alert
data:
  alerts:
    - message: "Morning report - all systems normal"
      level: "info"
      channel: "main"
    - message: "Backup completed successfully"
      level: "info"
      channel: "technical"
```

### Threshold Monitoring
```yaml
# Add threshold alert
action: script.add_threshold_alert
data:
  entity_id: "sensor.living_room_temperature"
  threshold: "25"
  condition: "above"
  offline_min: "10"

# Add offline-only monitoring (no threshold)
action: script.add_threshold_alert
data:
  entity_id: "sensor.garage_door"
  offline_min: "5"
```

### Custom Automations via Blueprint

Go to **Settings > Automations > Create Automation > Use Blueprint** and select "Send Alert on Entity State Change". Fill in the form - no YAML needed.

## Architecture

```
GitHub Repository (Single Source of Truth)
       |
    update_alerts.sh (self-updating)
       |
    +--+--+--+
    |  |  |  |
    v  v  v  v
  House1  House2  House3 ...
    |       |       |
    v       v       v
  Main +  Main +  Main +
  Tech    Tech    Tech
  Groups  Groups  Groups
```

## Documentation

**[Complete Setup and Usage Guide](Home%20Assistant%20Alert%20System%20Setup%20and%20Usage%20Guide.md)**

The full documentation includes:
- **Detailed Implementation Guide** - Step-by-step setup for multiple houses
- **Complete Script Reference** - All alert scripts with parameters
- **Troubleshooting Guide** - Common issues and solutions
- **Advanced Customization** - Creating custom alert types
- **Security Considerations** - Token management and best practices
- **Maintenance & Updates** - Keeping your system current

## System Components

### Core Files
- **`packages/alert_system.yaml`** - Main package with scripts, helpers, and automations
- **`blueprints/automation/alert_system/send_alert.yaml`** - Blueprint for custom alert automations
- **`lovelace/alert_system_dash.yaml`** - Management dashboard
- **`update_alerts.sh`** - Self-updating deployment script
- **Configuration files** - secrets.yaml and configuration.yaml examples

### Features
- 5 alert scripts with flexible routing and formatting
- Threshold monitoring with auto-generated messages
- Offline-only device monitoring
- Blueprint for creating custom alert automations
- HTML message formatting
- Fallback error handling for invalid channels
- Bulk alert processing
- Automatic location detection from HA entity areas

## Testing

The repository includes a comprehensive test suite in `test scenarios` covering:
- Individual script functionality
- Channel routing verification
- Alert level formatting
- Threshold monitoring
- Offline detection
- Error condition handling
- Edge cases and special characters

## Updates & Maintenance

### Automatic Updates
```bash
# Run on each house to get latest version (script updates itself too)
/config/update_alerts.sh
```

### Backup Strategy
- Automatic timestamped backups created before each update
- Version control through GitHub
- Rollback via backup restoration

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
