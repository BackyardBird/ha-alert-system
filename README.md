# Home Assistant Multi-House Alert System

[![Home Assistant](https://img.shields.io/badge/Home%20Assistant-2024.1+-blue.svg)](https://www.home-assistant.io/)
[![GitHub release](https://img.shields.io/github/release/YOUR_USERNAME/ha-alert-system.svg)](https://github.com/YOUR_USERNAME/ha-alert-system/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A centralized, dual-channel notification system for Home Assistant designed for multi-house deployments. This system provides intelligent routing of alerts via Telegram, separating household notifications from technical system alerts.

## ✨ Key Features

### 🏠 **Multi-House Architecture**
- **Single GitHub Repository** as source of truth for all houses
- **Automated Updates** via script deployment to multiple Home Assistant instances
- **House-Specific Configuration** with unique Telegram channels per location

### 📱 **Dual-Channel Notifications**
- **Main Channel**: Family-friendly notifications for daily life
- **Technical Channel**: System administration and device management alerts
- **Security Alerts**: Forced to both channels for maximum visibility

### 🤖 **9 Specialized Alert Scripts**
- `script.send_alert` - Full-featured alerts with all options
- `script.quick_alert` - Simple notifications to main channel
- `script.system_alert` - Technical system alerts
- `script.security_alert` - Security events (both channels)
- `script.device_alert` - Device-specific notifications
- `script.bulk_alert` - Send multiple alerts at once
- `script.tech_alert` - Technical channel convenience script
- `script.main_alert` - Main channel convenience script
- `script.test_alert` - System verification

### 📊 **Smart Threshold Monitoring**
- **Automatic threshold alerts** for any sensor
- **Device availability monitoring** (online/offline detection)
- **Visual dashboard** for managing threshold rules
- **Multiple condition support** (above/below thresholds)

### ⚙️ **Binary Sensor Automation Generator**
- **Visual form interface** for creating automations
- **YAML code generation** for binary sensor triggers
- **Copy-paste ready** automation code

## 🎯 Message Format

All alerts follow a consistent, professional format:

```
🚨 HOUSE1 CRITICAL  14:30
🔒 SECURITY: Motion detected when away
📍 Living room
```

**Format Structure:**
- **Line 1**: [Emoji] [HOUSE] [LEVEL] [Timestamp]  
- **Line 2**: [Prefix] [Message Content]
- **Line 3**: [Location] (if specified)

## 🚀 Quick Start

### Prerequisites
- Home Assistant with packages support
- Telegram Bot Token (from @BotFather)
- 2 Telegram groups per house (Main + Technical channels)

### Installation

1. **Fork this repository** or download the files

2. **Set up Telegram Bot Integration** in Home Assistant:
   - Settings → Devices & Services → Add Integration → Telegram Bot
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
   # Make the update script executable
   chmod +x /config/update_alerts.sh
   
   # Download the alert system
   /config/update_alerts.sh
   ```

5. **Restart Home Assistant** and test:
   ```yaml
   action: script.test_alert
   data:
     channel: "both"
   ```

## 💡 Usage Examples

### Basic Alerts
```yaml
# Simple notification
action: script.quick_alert
data:
  message: "Dishwasher finished"

# System alert
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
# Full-featured alert
action: script.send_alert
data:
  message: "Pool temperature reached target"
  level: "info"
  channel: "main"
  location: "Pool Area"

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
# Add threshold monitoring via script
action: script.add_threshold_alert
data:
  entity_id: "sensor.living_room_temperature"
  threshold: "25"
  condition: "above"
  custom_message: "Living room is too hot"
```

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│          GitHub Repository              │
│        (Single Source of Truth)        │
└─────────────┬───────────────────────────┘
              │
    ┌─────────┼─────────┐
    │         │         │
    ▼         ▼         ▼
┌───────┐ ┌───────┐ ┌───────┐
│House1 │ │House2 │ │House3 │
│  HA   │ │  HA   │ │  HA   │
└───┬───┘ └───┬───┘ └───┬───┘
    │         │         │
    ▼         ▼         ▼
┌───────┐ ┌───────┐ ┌───────┐
│Main + │ │Main + │ │Main + │
│ Tech  │ │ Tech  │ │ Tech  │
│Groups │ │Groups │ │Groups │
└───────┘ └───────┘ └───────┘
```

## 📚 Documentation

**[📖 Complete Setup and Usage Guide](Alert%20System%20Setup%20and%20Usage%20Guide.md)**

The full documentation includes:
- **Detailed Implementation Guide** - Step-by-step setup for multiple houses
- **Complete Script Reference** - All 9 alert scripts with parameters
- **Troubleshooting Guide** - Common issues and solutions
- **Advanced Customization** - Creating custom alert types
- **Security Considerations** - Token management and best practices
- **Maintenance & Updates** - Keeping your system current

## 🔧 System Components

### Core Files
- **`packages/alert_system.yaml`** - Main package with all scripts and helpers
- **`update_alerts.sh`** - Automated update script from GitHub
- **`lovelace/alert_system_dash.yaml`** - Management dashboard
- **Configuration files** - secrets.yaml and configuration.yaml examples

### Features Included
- ✅ **9 Alert Scripts** with different routing and formatting
- ✅ **Threshold Monitoring** with automatic device availability detection
- ✅ **Binary Sensor Automation Generator** with visual interface
- ✅ **HTML Message Formatting** with emoji and structure
- ✅ **Fallback Error Handling** for invalid channels
- ✅ **Bulk Alert Processing** for multiple notifications
- ✅ **Template Variable Safety** with proper defaults

## 🧪 Testing

The repository includes a comprehensive test suite in `test scenarios` with 25+ test cases covering:
- Individual script functionality
- Channel routing verification
- Alert level formatting
- Error condition handling
- Edge cases and special characters

## 📈 Updates & Maintenance

### Automatic Updates
```bash
# Run on each house to get latest version
/config/update_alerts.sh
```

### Backup Strategy
- **Automatic backups** created before each update
- **Version control** through GitHub tags
- **Rollback procedures** for quick recovery

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Test thoroughly on your Home Assistant instance
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Home Assistant community for inspiration and best practices
- Telegram Bot API for reliable message delivery
- Contributors and testers who helped refine this system

---

**⭐ If this project helped you, please give it a star!**

**❓ Having issues?** Check the [full documentation](Alert%20System%20Setup%20and%20Usage%20Guide.md) or open an issue.