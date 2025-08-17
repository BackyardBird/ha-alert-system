# Home Assistant Multi-House Alert System
## Complete Documentation & Implementation Guide

---

## Table of Contents

1. [Overview of Functionality and Architecture](#1-overview-of-functionality-and-architecture)
2. [Details of Everything](#2-details-of-everything)
3. [Implementation Guide](#3-implementation-guide)
4. [Troubleshooting Guide](#4-troubleshooting-guide)
5. [Advanced Customization](#5-advanced-customization)
6. [Maintenance & Updates](#6-maintenance--updates)
7. [Security Considerations](#7-security-considerations)
8. [Multi-House Management](#8-multi-house-management)

---

## 1. Overview of Functionality and Architecture

### 1.1 System Overview

The Home Assistant Alert System is a centralized, dual-channel notification system designed for multi-house deployments. It provides intelligent routing of alerts via Telegram, separating household notifications from technical system alerts.

### 1.2 Architecture Components

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Repository                         │
│              (Single Source of Truth)                       │
│                 alert_system.yaml                          │
└─────────────────────┬───────────────────────────────────────┘
                      │
          ┌───────────┼───────────┐
          │           │           │
          ▼           ▼           ▼
    ┌─────────┐ ┌─────────┐ ┌─────────┐
    │ House1  │ │ House2  │ │ House3  │
    │         │ │         │ │         │
    └─────────┘ └─────────┘ └─────────┘
          │           │           │
          ▼           ▼           ▼
    ┌─────────┐ ┌─────────┐ ┌─────────┐
    │Main+Tech│ │Main+Tech│ │Main+Tech│
    │Telegram │ │Telegram │ │Telegram │
    │Channels │ │Channels │ │Channels │
    └─────────┘ └─────────┘ └─────────┘
```

### 1.3 Core Components

- **GitHub Repository**: Central code repository with versioned alert system
- **Local Update Scripts**: Automated sync from GitHub to each house
- **Telegram Bot**: Single bot serving all houses
- **Dual Channels**: Main (household) + Technical (system) alerts per house
- **9 Alert Scripts**: Specialized scripts for different notification types

### 1.4 High-Level Alert Types

#### **Household Alerts (Main Channel)**
- **Purpose**: Family-friendly notifications for daily life
- **Recipients**: All household members
- **Examples**: "Dishwasher finished", "Pool temperature ready"

#### **Technical Alerts (Technical Channel)**
- **Purpose**: System administration and device management
- **Recipients**: Technical staff, system administrators
- **Examples**: "Low disk space", "Device offline", "System updates"

#### **Security Alerts (Both Channels)**
- **Purpose**: Safety and security events requiring immediate attention
- **Recipients**: Everyone (forced to both channels)
- **Examples**: "Motion detected when away", "Smoke detector activated"

### 1.5 Message Format Standard

```
🚨 HOUSE1 CRITICAL  14:30
🔒 SECURITY: Motion detected when away
📍 Living room
```

**Format Structure:**
- **Line 1**: [Emoji] [HOUSE] [LEVEL] [Timestamp]
- **Line 2**: [Prefix] [Message Content]
- **Line 3**: [Location] (if specified)

---

## 2. Details of Everything

### 2.1 Complete Alert Script Reference

| Script | Purpose | Default Channel | Required Parameters | Optional Parameters |
|--------|---------|----------------|-------------------|-------------------|
| `script.test_alert` | System verification | Both | None | `channel`, `chat_id` |
| `script.quick_alert` | Simple notifications | Main | `message` | `chat_id` |
| `script.send_alert` | Full-featured alerts | Configurable | `message` | `level`, `location`, `channel`, `chat_id`, `include_timestamp` |
| `script.system_alert` | Technical issues | Technical | `message` | `level`, `channel`, `chat_id` |
| `script.security_alert` | Security events | Both (forced) | `message` | `location`, `chat_id` |
| `script.device_alert` | Device notifications | Technical | `device_name`, `message` | `level`, `channel`, `chat_id` |
| `script.bulk_alert` | Multiple alerts | Mixed | `alerts` (list) | None |
| `script.tech_alert` | Technical convenience | Technical | `message` | `level`, `location` |
| `script.main_alert` | Household convenience | Main | `message` | `level`, `location` |

### 2.2 Alert Levels and Visual Indicators

#### **Info Level (ℹ️)**
- **Color**: Blue info icon
- **Use**: General information, completions, status updates
- **Examples**: "Backup completed", "Temperature normal"

#### **Warning Level (⚠️)**
- **Color**: Yellow warning triangle
- **Use**: Issues requiring attention but not critical
- **Examples**: "Low battery", "Door open too long"

#### **Critical Level (🚨)**
- **Color**: Red alarm light
- **Use**: Urgent issues requiring immediate action
- **Examples**: "Water leak", "Security breach", "System failure"

### 2.3 Channel Routing Logic

#### **Main Channel Routing**
```yaml
# Routes to main channel
- script.quick_alert
- script.main_alert  
- script.send_alert (with channel: "main")
- script.security_alert (also goes to technical)
```

#### **Technical Channel Routing**
```yaml
# Routes to technical channel
- script.system_alert
- script.device_alert
- script.tech_alert
- script.send_alert (with channel: "technical")
- script.security_alert (also goes to main)
```

#### **Both Channels Routing**
```yaml
# Routes to both channels
- script.security_alert (forced)
- script.send_alert (with channel: "both")
- script.test_alert (default)
```

#### **Invalid Channel Handling**
- **Fallback**: Technical channel
- **Warning Message**: Includes original message + error details
- **Purpose**: Ensures no messages are lost due to configuration errors

### 2.4 House-Specific Configuration

#### **House1 Configuration**
```yaml
house_name: "House1"
telegram_main_alerts: "-100XXXXXXXXX"
telegram_technical_alerts: "-100YYYYYYYYY"
```

#### **House2 Configuration**
```yaml
house_name: "House2"
telegram_main_alerts: "-100ZZZZZZZZZ"
telegram_technical_alerts: "-AAAAAAAAA"
```

#### **House3 Configuration**
```yaml
house_name: "House3"
telegram_main_alerts: "-100BBBBBBBBB"
telegram_technical_alerts: "-CCCCCCCCC"
```

### 2.5 Telegram Bot Configuration

#### **Bot Details**
- **Username**: @YOUR_BOT_NAME
- **Token**: `YOUR_BOT_TOKEN`
- **Type**: Broadcast (send-only)
- **Platform**: GUI Integration (not YAML)

#### **Group Setup Requirements**
- **Bot must be admin** in all groups
- **Required permissions**: Send Messages, Delete Messages
- **Group privacy**: Bot can read messages (disabled in BotFather)

### 2.6 Template System Details

#### **Variable Handling**
- **All templates use default filters** to prevent undefined variable errors
- **HTML escaping** applied to user content (`{{ message | e }}`)
- **Timestamp formatting**: 24-hour format (HH:MM)

#### **Error Handling**
- **Template warnings**: Logged but don't stop execution
- **Invalid channels**: Fallback to technical channel with warning
- **Missing parameters**: Default values applied automatically

---

## 3. Implementation Guide

### 3.1 Prerequisites

#### **Required Accounts & Services**
- GitHub account with public repository access
- Telegram account with bot creation capability
- SSH access to all Home Assistant installations
- Home Assistant OS or Container installation (packages support)

#### **Required Telegram Setup**
1. **Create Telegram Bot** via @BotFather
2. **Create 6 Telegram Groups** (2 per house):
   - House1 Alerts, House1 Technical Alerts
   - House2 Alerts, House2 Technical Alerts  
   - House3 Alerts, House3 Technical Alerts
3. **Add bot as admin** to all groups
4. **Get Chat IDs** using @getidsbot

### 3.2 Required Files Structure

```
GitHub Repository: YOUR_REPO_NAME/
├── packages/
│   └── alert_system.yaml           # Main package file
├── README.md                       # Repository documentation
└── UPDATE_INSTRUCTIONS.md          # Update procedures

Each House: /config/
├── configuration.yaml              # Contains packages: !include_dir_named packages
├── secrets.yaml                   # House-specific secrets
├── packages/
│   └── alert_system.yaml          # Downloaded from GitHub
├── update_alerts.sh               # Update script
└── UPDATE_INSTRUCTIONS.md         # Local copy of instructions
```

### 3.3 Step-by-Step Implementation

#### **Step 1: Create GitHub Repository**

1. **Create repository** (public)
2. **Create directory structure**:
   ```bash
   mkdir packages
   # Upload alert_system.yaml to packages/
   ```
3. **Upload package file** to `packages/alert_system.yaml`

#### **Step 2: Set Up House1 (Test Environment)**

1. **Configure Telegram Bot Integration**:
   - Settings > Devices & Services > Add Integration > Telegram Bot
   - Platform: Broadcast
   - API Key: `YOUR_BOT_TOKEN`
   - Add Chat IDs: `YOUR_MAIN_CHAT_ID`, `YOUR_TECH_CHAT_ID`

2. **Update configuration.yaml**:
   ```yaml
   homeassistant:
     packages: !include_dir_named packages
   ```

3. **Create secrets.yaml entries**:
   ```yaml
   house_name: "House1"
   telegram_main_alerts: "YOUR_MAIN_CHAT_ID"
   telegram_technical_alerts: "YOUR_TECH_CHAT_ID"
   ```

4. **Create update script** `/config/update_alerts.sh`:
   ```bash
   #!/bin/bash
   echo "🔄 Updating Home Assistant Alert System..."
   cd /config/packages/
   if [ -f "alert_system.yaml" ]; then
       cp alert_system.yaml alert_system.yaml.backup.$(date +%Y%m%d_%H%M%S)
       echo "✅ Backed up current version"
   fi
   wget -O alert_system.yaml.tmp https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/packages/alert_system.yaml
   if [ $? -eq 0 ]; then
       mv alert_system.yaml.tmp alert_system.yaml
       echo "✅ Successfully updated alert_system.yaml"
       echo "🔄 Restart Home Assistant to apply changes"
   else
       echo "❌ Failed to download update"
       rm -f alert_system.yaml.tmp
       exit 1
   fi
   ```

5. **Make script executable**:
   ```bash
   chmod +x /config/update_alerts.sh
   ```

6. **Download initial package**:
   ```bash
   /config/update_alerts.sh
   ```

7. **Restart Home Assistant and test**

#### **Step 3: Deploy to House2**

1. **Configure Telegram Bot Integration** (same API key)
2. **Add House2 Chat IDs**: `HOUSE2_MAIN_ID`, `HOUSE2_TECH_ID`
3. **Update configuration.yaml** (same as House1)
4. **Create House2 secrets.yaml**:
   ```yaml
   house_name: "House2"
   telegram_main_alerts: "HOUSE2_MAIN_ID"
   telegram_technical_alerts: "HOUSE2_TECH_ID"
   ```
5. **Copy update script** from House1
6. **Download package and test**

#### **Step 4: Deploy to House3**

1. **Configure Telegram Bot Integration** (same API key)
2. **Add House3 Chat IDs**: `HOUSE3_MAIN_ID`, `HOUSE3_TECH_ID`
3. **Update configuration.yaml** (same as others)
4. **Create House3 secrets.yaml**:
   ```yaml
   house_name: "House3"
   telegram_main_alerts: "HOUSE3_MAIN_ID"
   telegram_technical_alerts: "HOUSE3_TECH_ID"
   ```
5. **Copy update script** from House1
6. **Download package and test**

### 3.4 Testing Protocol

#### **Basic Connectivity Test**
```yaml
action: script.test_alert
data:
  channel: "both"
```

#### **Channel Routing Test**
```yaml
# Main channel only
action: script.main_alert
data:
  message: "Main channel test"

# Technical channel only
action: script.tech_alert
data:
  message: "Technical channel test"

# Both channels (security)
action: script.security_alert
data:
  message: "Security test"
  location: "Test area"
```

#### **Full Feature Test**
```yaml
action: script.send_alert
data:
  message: "Full feature test with <b>HTML</b> and special chars: !@#$%"
  level: "warning"
  channel: "both"
  location: "Test location"
```

---

## 4. Troubleshooting Guide

### 4.1 Common Issues and Solutions

#### **Scripts Not Loading After Update**

**Symptoms**: Missing scripts in Developer Tools > Actions

**Diagnosis**:
```bash
# Check package file exists
ls -la /config/packages/alert_system.yaml

# Check configuration syntax
ha core check

# Check Home Assistant logs
tail -f /config/home-assistant.log | grep -i "package\|error"
```

**Solutions**:
1. **Verify packages directory**: Ensure `packages: !include_dir_named packages` in configuration.yaml
2. **Check YAML syntax**: Use online YAML validator
3. **Restart Home Assistant**: Full restart required after package changes
4. **Check file permissions**: `chmod 644 /config/packages/alert_system.yaml`

#### **No Messages Received**

**Symptoms**: Scripts run without errors but no Telegram messages

**Diagnosis**:
```yaml
# Test direct API call
https://api.telegram.org/botYOUR_BOT_TOKEN/sendMessage?chat_id=YOUR_CHAT_ID&text=Direct%20test

# Test HA telegram service
action: telegram_bot.send_message
data:
  target: YOUR_CHAT_ID
  message: "HA service test"
```

**Solutions**:
1. **Check Chat IDs**: Verify correct Chat IDs in secrets.yaml
2. **Check GUI integration**: Settings > Devices & Services > Telegram Bot
3. **Verify bot permissions**: Bot must be admin in all groups
4. **Check network connectivity**: `ping raw.githubusercontent.com`

#### **Template Variable Warnings**

**Symptoms**: Template warnings in logs about undefined variables

**Common Warnings**:
```
Template variable warning: 'location' is undefined
Template variable warning: 'channel' is undefined
Template variable warning: 'chat_id' is undefined
```

**Solutions**:
1. **Update package**: Latest version includes `| default()` filters
2. **Check parameter passing**: Ensure all scripts pass required parameters
3. **Verify script calls**: Use exact parameter names from documentation

#### **HTML Parsing Errors**

**Symptoms**: `Can't parse entities: unsupported start tag` errors

**Example Error**:
```
Error sending message: Can't parse entities: unsupported start tag "" at byte offset 77
```

**Solutions**:
1. **Update package**: Latest version includes HTML escaping (`| e` filter)
2. **Avoid HTML characters**: Don't use `<>` in message content
3. **Use plain text**: Test with simple messages first

#### **Invalid Channel Handling**

**Symptoms**: No message when using invalid channel names

**Expected Behavior**: Should fallback to technical channel with warning

**Solutions**:
1. **Update package**: Latest version includes fallback logic
2. **Check channel parameter**: Use only `main`, `technical`, or `both`
3. **Review fallback message**: Should appear in technical channel

### 4.2 Diagnostic Commands

#### **System Health Check**
```bash
# Check Home Assistant status
ha core info

# Check supervisor logs
ha supervisor logs

# Check core logs
ha core logs

# Validate configuration
ha core check
```

#### **Package Diagnostics**
```bash
# Check package file syntax
python3 -c "import yaml; print('✅ Valid YAML' if yaml.safe_load(open('/config/packages/alert_system.yaml')) else '❌ Invalid YAML')"

# Check file size and permissions
ls -la /config/packages/alert_system.yaml

# Check include directory
ls -la /config/packages/

# Check configuration loading
grep -A 10 -B 5 packages /config/configuration.yaml
```

#### **Telegram Connectivity**
```bash
# Test bot token
curl "https://api.telegram.org/botYOUR_BOT_TOKEN/getMe"

# Test chat ID
curl "https://api.telegram.org/botYOUR_BOT_TOKEN/sendMessage?chat_id=YOUR_CHAT_ID&text=Test"

# Check network connectivity
ping -c 3 api.telegram.org
```

### 4.3 Log Analysis

#### **Important Log Locations**
```bash
# Main Home Assistant log
/config/home-assistant.log

# Previous log (after restart)
/config/home-assistant.log.1

# Supervisor logs
ha supervisor logs
```

#### **Key Error Patterns**
```bash
# Package loading errors
grep -i "package.*error" /config/home-assistant.log

# Template errors
grep -i "template.*undefined" /config/home-assistant.log

# Telegram errors
grep -i "telegram.*error" /config/home-assistant.log

# YAML syntax errors
grep -i "yaml.*error" /config/home-assistant.log
```

---

## 5. Advanced Customization

### 5.1 Creating Custom Alert Types

#### **Example: Pool Alert Script**
```yaml
  pool_alert:
    alias: "Pool Alert"
    description: "Pool-specific notifications"
    fields:
      message:
        description: "Pool alert message"
        required: true
      pool_location:
        description: "Pool area location"
        default: "Pool Area"
      level:
        description: "Alert level"
        default: "info"
    sequence:
      - action: script.send_alert
        data:
          message: "🏊 POOL: {{ message }}"
          level: "{{ level }}"
          location: "{{ pool_location }}"
          channel: "main"
```

#### **Example: Weather Alert Script**
```yaml
  weather_alert:
    alias: "Weather Alert"
    description: "Weather-related notifications"
    fields:
      weather_condition:
        description: "Weather condition"
        required: true
      severity:
        description: "Weather severity"
        default: "warning"
      affected_areas:
        description: "Areas affected"
        required: false
    sequence:
      - action: script.send_alert
        data:
          message: "🌦️ WEATHER: {{ weather_condition }}"
          level: "{{ severity }}"
          location: "{{ affected_areas | default('All Areas') }}"
          channel: "both"
```

### 5.2 Custom Message Formatting

#### **Adding Custom Prefixes**
```yaml
# In script sequence, modify message content:
message: "🚗 VEHICLE: {{ message }}"     # Vehicle-related
message: "🌡️ CLIMATE: {{ message }}"     # HVAC/temperature
message: "💡 LIGHTING: {{ message }}"    # Lighting systems
message: "🔋 POWER: {{ message }}"       # Electrical/UPS
message: "🌐 NETWORK: {{ message }}"     # Network/connectivity
```

#### **Custom Emoji Sets**
```yaml
# Alternative emoji sets for different houses or preferences:
level_emoji: >
  {% if level == 'critical' %}🔴
  {% elif level == 'warning' %}🟡
  {% else %}🟢{% endif %}

# Or seasonal themes:
level_emoji: >
  {% if level == 'critical' %}🎃
  {% elif level == 'warning' %}🍂
  {% else %}🌿{% endif %}
```

### 5.3 Advanced Channel Routing

#### **Time-Based Routing**
```yaml
# Send to different channels based on time of day
      - variables:
          current_hour: "{{ now().hour }}"
          night_mode: "{{ current_hour < 7 or current_hour > 22 }}"
          target_channel: >
            {% if night_mode and level != 'critical' %}
              technical
            {% else %}
              main
            {% endif %}
```

#### **Conditional Channel Selection**
```yaml
# Route based on Home Assistant state
      - variables:
          house_occupied: "{{ is_state('group.all_people', 'home') }}"
          target_channel: >
            {% if house_occupied %}
              main
            {% else %}
              technical
            {% endif %}
```

### 5.4 Enhanced Error Handling

#### **Retry Logic for Failed Messages**
```yaml
  reliable_alert:
    sequence:
      - repeat:
          count: 3
          sequence:
            - action: telegram_bot.send_message
              data:
                target: "{{ main_chat | int }}"
                message: "{{ message }}"
              continue_on_error: true
            - delay:
                seconds: 5
```

#### **Multiple Delivery Methods**
```yaml
  redundant_alert:
    sequence:
      # Primary: Telegram
      - action: script.send_alert
        data:
          message: "{{ message }}"
          channel: "{{ channel }}"
        continue_on_error: true
      # Backup: Email notification
      - action: notify.email
        data:
          message: "Backup alert: {{ message }}"
        continue_on_error: true
      # Last resort: Persistent notification
      - action: persistent_notification.create
        data:
          message: "Critical alert backup: {{ message }}"
          title: "Alert System Backup"
```

### 5.5 Integration with Home Assistant Features

#### **Using with Input Selectors**
```yaml
# Add input selector for alert preferences
input_select:
  alert_mode:
    name: "Alert Mode"
    options:
      - "Normal"
      - "Quiet Hours"
      - "Emergency Only"
    initial: "Normal"

# Use in scripts
      - condition: template
        value_template: "{{ states('input_select.alert_mode') != 'Emergency Only' or level == 'critical' }}"
```

#### **Location Detection from Entities**
```yaml
# Automatically detect location from entity area
      - variables:
          auto_location: "{{ area_name(trigger.entity_id) if trigger is defined else location }}"
      - action: script.send_alert
        data:
          location: "{{ auto_location }}"
```

---

## 6. Maintenance & Updates

### 6.1 Update Workflow

#### **Development Cycle**
1. **Make changes** in GitHub repository
2. **Test on House1** (designated test environment)
3. **Verify functionality** with comprehensive test suite
4. **Deploy to House2** after House1 validation
5. **Deploy to House3** after both others confirmed
6. **Document changes** in commit messages and changelog

#### **Update Deployment Steps**
```bash
# Step 1: House1 (Test Environment)
ssh house1-ha
/config/update_alerts.sh
ha core restart
# Run test suite, verify functionality

# Step 2: House2 (Production 1)
ssh house2-ha
/config/update_alerts.sh
ha core restart
# Run basic tests

# Step 3: House3 (Production 2)  
ssh house3-ha
/config/update_alerts.sh
ha core restart
# Run basic tests
```

### 6.2 Backup Procedures

#### **Automatic Backups**
The update script automatically creates timestamped backups:
```bash
# Backup location
/config/packages/alert_system.yaml.backup.YYYYMMDD_HHMMSS

# View available backups
ls -la /config/packages/alert_system.yaml.backup.*

# Restore from backup
cp alert_system.yaml.backup.20250816_143022 alert_system.yaml
```

#### **Manual Backup Strategy**
```bash
# Create manual backup before major changes
cp /config/packages/alert_system.yaml /config/packages/alert_system.yaml.manual.$(date +%Y%m%d)

# Backup entire packages directory
tar -czf /config/packages_backup_$(date +%Y%m%d).tar.gz /config/packages/

# Backup secrets (sanitized)
grep -E "(house_name|telegram_)" /config/secrets.yaml > /config/alert_secrets_backup.yaml
```

### 6.3 Version Management

#### **GitHub Version Control**
```bash
# View version history
git log --oneline --decorate packages/alert_system.yaml

# Tag major releases
git tag -a v1.0 -m "Stable release with dual-channel support"
git push origin v1.0

# Compare versions
git diff v1.0..HEAD packages/alert_system.yaml
```

#### **Rollback Procedures**

**Quick Rollback (Local Backup)**:
```bash
# Find suitable backup
ls -la /config/packages/alert_system.yaml.backup.*

# Restore
cp alert_system.yaml.backup.YYYYMMDD_HHMMSS alert_system.yaml
ha core restart
```

**GitHub Version Rollback**:
```bash
# Download specific version
wget -O alert_system.yaml https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/COMMIT_HASH/packages/alert_system.yaml

# Or use git tag
wget -O alert_system.yaml https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/v1.0/packages/alert_system.yaml
```

### 6.4 Health Monitoring

#### **System Health Checks**
```yaml
# Add to automations.yaml
automation:
  - alias: "Alert System Health Check"
    trigger:
      - platform: time
        at: "08:00:00"
    action:
      - action: script.test_alert
        data:
          channel: "technical"
      - delay:
          minutes: 5
      # Check if test was successful by monitoring logs
```

#### **Update Notifications**
```yaml
# Monitor GitHub for updates
automation:
  - alias: "Alert System Update Available"
    trigger:
      - platform: webhook
        webhook_id: "github_alert_system_update"
    action:
      - action: script.tech_alert
        data:
          message: "New alert system update available on GitHub"
          level: "info"
```

### 6.5 Maintenance Schedule

#### **Weekly Tasks**
- ✅ Test alert system on all houses
- ✅ Check Home Assistant logs for errors
- ✅ Verify GitHub repository accessibility

#### **Monthly Tasks**
- ✅ Review and clean old backup files
- ✅ Update documentation if needed
- ✅ Test rollback procedures
- ✅ Review alert system usage patterns

#### **Quarterly Tasks**
- ✅ Comprehensive security review
- ✅ Update Telegram bot token if needed
- ✅ Review Chat IDs and group memberships
- ✅ Performance analysis and optimization

---

## 7. Security Considerations

### 7.1 Token and Credential Management

#### **Telegram Bot Token Security**
- **Centralized Token**: Single bot token shared across all houses
- **Token Rotation**: Plan for periodic token updates
- **Access Control**: Only store in secrets.yaml, never in code
- **Backup Strategy**: Secure backup of tokens outside of Git

**Token Update Procedure**:
```bash
# When rotating tokens:
# 1. Generate new token in @BotFather
# 2. Update secrets.yaml on all houses:
#    telegram_bot_token: "NEW_TOKEN_HERE"
# 3. Update GUI integrations on all houses
# 4. Test connectivity before deactivating old token
```

#### **Chat ID Privacy**
- **Exposure Risk**: Chat IDs visible in GitHub commits and logs
- **Mitigation**: Chat IDs are not sensitive security tokens
- **Best Practice**: Use consistent naming for easy identification
- **Documentation**: Maintain secure record of Chat ID mappings

#### **GitHub Repository Security**
- **Public Repository**: Required for raw.githubusercontent.com access
- **No Secrets**: Never commit tokens, passwords, or personal data
- **Access Control**: Limit write access to repository
- **Audit Trail**: Monitor repository access and changes

### 7.2 Access Control

#### **Telegram Group Security**
```yaml
# Security checklist for each Telegram group:
- Bot is admin with minimal required permissions
- Group is private (not searchable)
- Only authorized users have access
- Regular audit of group members
- Clear group naming convention
```

#### **Home Assistant Security**
```yaml
# Configuration security:
- secrets.yaml protected with appropriate file permissions (600)
- Regular Home Assistant updates
- Secure network configuration
- Limited API access if using HTTP integration
```

#### **Network Security**
```yaml
# Network considerations:
- HTTPS for all external communications
- VPN access for administrative tasks
- Firewall rules for Home Assistant instances
- Regular security updates for host systems
```

### 7.3 Data Privacy

#### **Message Content**
- **Transmission**: All messages encrypted via Telegram's protocol
- **Storage**: No persistent storage of message content in HA
- **Logging**: Avoid sensitive data in alert messages
- **Retention**: Messages stored according to Telegram's policies

#### **Personal Information**
- **Location Data**: Generic location names, avoid specific addresses
- **Device Names**: Use friendly names, avoid sensitive identifiers
- **User Information**: No personal data in automated messages

### 7.4 Incident Response

#### **Compromise Detection**
```yaml
# Signs of potential compromise:
- Unexpected alert messages
- Messages from unknown Chat IDs
- Bot removed from groups unexpectedly
- Unusual Home Assistant log entries
```

#### **Response Procedures**
```bash