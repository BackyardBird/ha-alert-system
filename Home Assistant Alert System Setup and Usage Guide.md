# Home Assistant Alert System
## Complete Setup & Usage Guide

---

## Quick Setup Checklist

**Everything you need to do to get the alert system working:**

1. **Create Telegram Bot** via @BotFather - Get bot token
2. **Create Telegram Groups** (2 groups: Main Alerts + Technical Alerts) - Get Chat IDs
3. **Configure Home Assistant Telegram Integration** - Add bot token and Chat IDs
4. **Update configuration.yaml** - Add packages directory and Lovelace dashboard
5. **Create directories** - `/config/packages/` and `/config/lovelace/`
6. **Download package files** - Run `update_alerts.sh`
7. **Configure secrets.yaml** - Add house name and Chat IDs
8. **Restart Home Assistant** and test

**For multiple houses:** Repeat steps 2-3 and 7 for each additional house using the same bot token.

---

## Table of Contents

1. [System Overview](#system-overview)
2. [Implementation Guide](#implementation-guide)
3. [Testing Your Setup](#testing-your-setup)
4. [Using Alert Scripts](#using-alert-scripts)
5. [Creating Automations with Alerts](#creating-automations-with-alerts)
6. [Using the Dashboard](#using-the-dashboard)
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

- **5 Alert Scripts**: From simple `send_alert` to `bulk_alert` for status reports
- **Threshold Monitoring**: Automatic alerts when sensors exceed configured limits, with auto-generated messages
- **Offline Monitoring**: Monitor device availability without requiring a threshold
- **Blueprint**: UI-driven form for creating custom alert automations
- **Lovelace Dashboard**: Visual interface for managing threshold alerts
- **Multi-House Support**: One bot can serve multiple houses with separate channels

### Architecture

```
GitHub Repository
       |
  update_alerts.sh (self-updating)
       |
Home Assistant Package
       |
   Alert Scripts + Threshold Monitor
       |
  Telegram Bot - Main Group + Technical Group
```

---

## Implementation Guide

### Prerequisites

- Home Assistant 2026.3+ with packages support
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
   - Settings > Devices & Services > Add Integration
   - Search "Telegram Bot" > Configure
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

```bash
mkdir -p /config/packages/
mkdir -p /config/lovelace/
```

### Step 5: Download Package Files

```bash
# Download the update script
wget -O /config/update_alerts.sh https://raw.githubusercontent.com/BackyardBird/ha-alert-system/main/update_alerts.sh
chmod +x /config/update_alerts.sh

# Download all files (package, dashboard, blueprint)
/config/update_alerts.sh
```

### Step 6: Restart and Test

Restart Home Assistant, then run a test:
```yaml
action: script.test_alert
data:
  channel: "both"
```

### Multi-House Setup

For additional houses:
1. **Repeat Steps 2-3**: Configure Telegram integration with same bot token
2. **Create new groups** for the additional house
3. **Update secrets.yaml** with the new house name and Chat IDs
4. **Use same package files** - they automatically adapt to each house's secrets

---

## Testing Your Setup

### Basic Connectivity Test

```yaml
action: script.test_alert
data:
  channel: "both"
```

### Individual Channel Tests

**Main channel only:**
```yaml
action: script.send_alert
data:
  message: "Main channel test"
  level: "info"
  channel: "main"
```

**Technical channel only:**
```yaml
action: script.send_alert
data:
  message: "Technical channel test"
  level: "info"
  channel: "technical"
```

### Full Feature Test

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
- **Formatting**: Bold text and location display correctly
- **Header format**: `YOURHOUSENAME WARNING 14:30`

---

## Using Alert Scripts

### Available Scripts

| Script | Purpose | Default Channel |
|--------|---------|----------------|
| `send_alert` | Full-featured alerts | Configurable |
| `system_alert` | Technical issues | Technical |
| `security_alert` | Security events | Both (forced) |
| `bulk_alert` | Multiple alerts | Mixed |
| `test_alert` | System verification | Both |

### Alert Script Parameters

**`send_alert` parameters:**
- **message**: Alert content (required)
- **level**: `info`, `warning`, or `critical` (default: info)
- **channel**: `main`, `technical`, or `both` (default: main)
- **location**: Manual location override (optional)
- **entity_id**: For automatic location detection (optional)
- **include_timestamp**: true/false (default: true)
- **chat_id**: Direct message to specific chat (optional)
- **cooldown_min**: Minutes to mute repeats of this alert (default: 0 = no limit)
- **dedup_key**: Which alerts count as "the same" for the cooldown (optional)

**Automatic Location Detection:**
- When `entity_id` is provided but `location` is empty, location is automatically filled from the entity's Home Assistant area assignment
- Manual `location` always takes priority over auto-detected location

### Repeat Alert Suppression

A sensor hovering at its threshold crosses it repeatedly, and a flaky device drops offline
and recovers over and over. Each crossing is a separate Telegram message unless a cooldown
is set.

**How it works.** The first alert is always sent immediately. `send_alert` then records the
alert's key in `sensor.alert_cooldown_registry` with an expiry time; any further alert with
the same key is dropped until that expiry passes. Expired entries are pruned automatically
on the next write, and because the registry is a trigger-based template sensor, Home
Assistant restores it across a restart - a reboot does not silently re-open every cooldown
window.

**Grouping.** Alerts share a cooldown when they share a `dedup_key`. If you do not pass one:

| Situation | Key used |
|-----------|----------|
| `entity_id` provided | `entity_id/level` |
| No `entity_id` | `message/level` |

**Pass `dedup_key` explicitly whenever the message contains a changing value.** A message
like `"Level now 4.9%"` differs on every send, so the default key would never match and
nothing would ever be suppressed.

**Built-in alerts.** Threshold breaches and device offline/online alerts use
`input_number.alert_cooldown_minutes`, adjustable on the dashboard. The helper deliberately
has no `initial:` value, so your setting survives restarts; until it is set for the first
time the callers fall back to 60 minutes. They are
keyed per entity and per threshold, so `sensor.tank below 5` and `sensor.tank above 90`
mute independently, as do a device's offline and online alerts. Set the helper to `0` to
restore the pre-6.1 alert-on-every-crossing behaviour.

**Example - alert on the first drop, then at most once a day:**

```yaml
action: script.send_alert
data:
  message: "Rainbarrel below 5% (now {{ states('sensor.rainbarrel_pct') }}%)"
  level: warning
  channel: main
  entity_id: sensor.rainbarrel_pct
  cooldown_min: 1440
  dedup_key: "sensor.rainbarrel_pct/below/5"
```

The Send Alert blueprint exposes the same thing as **Minimum Time Between Alerts**.

**Monitoring.** `sensor.alert_cooldowns_active` counts what is currently muted and decays
on its own as windows expire. The registry's `entries` attribute lists each muted key with
its expiry. A suppressed run shows up in the `script.send_alert` trace as a `stop` step
naming the key and window.

**Cooldown vs. duration.** They solve different problems and combine well. The blueprint's
*Duration Before Alert* waits for the entity to hold its state before alerting at all, which
delays the first alert. *Minimum Time Between Alerts* lets the first alert through
immediately and mutes the repeats.

**Limits.** Suppression is best-effort: two alerts with the same key firing in the same
instant can both get through, since the registry is updated via an event. `send_alert` runs
in `queued` mode, which serialises bursts and makes this unlikely.

### Alert Levels

- **info**: General information, completions, status updates
- **warning**: Issues requiring attention but not critical
- **critical**: Urgent issues requiring immediate action

### Usage Examples

**Simple notification to main channel:**
```yaml
action: script.send_alert
data:
  message: "Dishwasher cycle completed"
  level: "info"
  channel: "main"
```

**Technical alert with location:**
```yaml
action: script.send_alert
data:
  message: "Disk space low"
  level: "warning"
  channel: "technical"
  location: "Server Rack"
```

**Security alert (always both channels):**
```yaml
action: script.security_alert
data:
  message: "Motion detected when house is empty"
  location: "Living Room"
```

**Alert with auto-location from entity:**
```yaml
action: script.send_alert
data:
  message: "Temperature sensor reading high"
  level: "warning"
  channel: "main"
  entity_id: "sensor.living_room_temperature"
```

### Bulk Alerts for Status Reports

```yaml
action: script.bulk_alert
data:
  alerts:
    - message: "Daily Status Report"
      level: "info"
      channel: "main"
    - message: "Temperature: {{ states('sensor.temperature') }}C"
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

### Option 1: Blueprint (Recommended)

The easiest way to create alert automations:

1. Go to **Settings > Automations > Create Automation > Use Blueprint**
2. Select **"Send Alert on Entity State Change"**
3. Fill in the form:
   - **Entity**: Pick from your entity list
   - **Trigger State**: What state triggers the alert (e.g. "on", "off", "unavailable")
   - **Message**: Your alert message
   - **Level**: info, warning, or critical
   - **Channel**: main, technical, or both
   - **Location**: Optional (auto-detects from entity area if empty)
   - **Duration**: How long the state must persist before alerting (prevents flapping)
4. Save and enable

### Option 2: YAML Automations

**Basic template:**
```yaml
alias: "My Alert Automation"
trigger:
  - platform: state
    entity_id: sensor.your_sensor
    to: "on"
action:
  - action: script.send_alert
    data:
      message: "Your alert message"
      level: "warning"
      channel: "main"
      entity_id: "{{ trigger.entity_id }}"
mode: single
```

**Low battery alert:**
```yaml
alias: "Low Battery Alert"
trigger:
  - platform: numeric_state
    entity_id: sensor.phone_battery
    below: 20
action:
  - action: script.send_alert
    data:
      message: "{{ state_attr(trigger.entity_id, 'friendly_name') }} battery low ({{ trigger.to_state.state }}%)"
      level: "warning"
      channel: "technical"
      entity_id: "{{ trigger.entity_id }}"
```

**Door left open:**
```yaml
alias: "Front Door Open Too Long"
trigger:
  - platform: state
    entity_id: binary_sensor.front_door
    to: "on"
    for: "00:10:00"
action:
  - action: script.send_alert
    data:
      message: "Front door has been open for 10 minutes"
      level: "warning"
      channel: "main"
      entity_id: "{{ trigger.entity_id }}"
```

**High CPU alert:**
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

**Away mode security:**
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
      entity_id: "{{ trigger.entity_id }}"
```

### Setting Up Areas for Automatic Location

Assign your entities to Home Assistant areas for automatic location detection:

1. **Go to Settings > Areas & Zones**
2. **Create areas**: "Living Room", "Kitchen", "Bedroom", etc.
3. **Assign devices to areas**: Settings > Devices & Services > Devices > Click device > Edit > Area
4. **Entities inherit area** from their device

### Using Templates in Messages

**Dynamic sensor values:**
```yaml
message: "Temperature is {{ states('sensor.temperature') }}C"
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

---

## Using the Dashboard

### Accessing the Dashboard

- **Sidebar**: Click "Alert System" in the Home Assistant sidebar
- **URL**: Navigate to `/lovelace/alert-system`

### Threshold Alert Management

**Create alerts for sensors that exceed limits:**

1. **Find Entity ID**: Developer Tools > States, search for your sensor
2. **Configure Alert**:
   - **Entity ID**: `sensor.bedroom_temperature`
   - **Threshold Value**: `25` (leave empty for offline-only monitoring)
   - **Condition**: `above`, `below`, or `offline only`
   - **Offline Delay**: Custom per-device delay (optional)
3. **Click "Create Alert"**

Messages are auto-generated from entity metadata - no need to type a message.

**Management Functions**:
- **List All**: View all configured alerts with friendly names
- **Remove Alert**: Enter entity ID to remove specific alert
- **Clear All**: Remove all threshold alerts (with confirmation)
- **Test System**: Send test alert to verify functionality

### Storage Format

Threshold data is stored in `input_text` helpers using this format:
```
entity:threshold:condition:offline_min
```

For offline-only monitoring:
```
entity:::offline_min
```

Multiple entries separated by `|`:
```
sensor.temp:25:above:10|sensor.humidity:70:above|sensor.garage:::5
```

---

## Essential Security

### Bot Token Security

- **Store in secrets.yaml only** - never in configuration files
- **Use same token for multiple houses** - simplifies management
- **Rotate periodically** - update token every 6-12 months

### Telegram Group Security

- **Private groups only** - never use public groups
- **Bot admin permissions** - bot needs admin rights to send messages
- **Regular member audit** - review who has access to alert groups

### Home Assistant Security

- **File permissions**: Ensure `secrets.yaml` has restricted access
- **Regular updates**: Keep Home Assistant updated for security patches
- **No sensitive data in alerts** - avoid personal information in messages

---

## Maintenance & Updates

### Update Procedure

```bash
# Run update script (updates itself, package, dashboard, and blueprint)
/config/update_alerts.sh

# Restart Home Assistant
ha core restart

# Or reload without restart:
# Developer Tools > YAML > Reload Scripts + Reload Automations
```

### Backup Strategy

- **Automatic backups** created before each update (timestamped)
- **Rollback**: Restore from backup files in `/config/packages/`

```bash
# List available backups
ls -la /config/packages/alert_system.yaml.backup.*

# Restore from backup
cp /config/packages/alert_system.yaml.backup.TIMESTAMP /config/packages/alert_system.yaml
ha core restart
```

---

## Troubleshooting

### Scripts Not Loading

**Symptoms**: Missing scripts in Developer Tools > Actions

**Solutions**:
1. Check `configuration.yaml` has `packages: !include_dir_named packages`
2. Verify file is at `/config/packages/alert_system.yaml`
3. Run `ha core check` to validate YAML
4. Full restart required after package changes

### No Telegram Messages

**Symptoms**: Scripts run without errors but no messages received

**Solutions**:
1. Verify Chat IDs in secrets.yaml match your groups
2. Check bot has admin permissions in groups
3. Test Telegram integration directly via Developer Tools
4. Check network connectivity to Telegram servers

### Threshold Alerts Not Triggering

**Symptoms**: Sensors cross thresholds but no alerts sent

**Solutions**:
1. Check `input_boolean.threshold_alerts_enabled` is `on`
2. Use "List All" dashboard button to verify alert configuration
3. Ensure sensor reports numeric values
4. **Reload automations** (Developer Tools > YAML > Reload Automations) - the threshold monitor is an automation, not a script
5. Check automation logs for the "Threshold Alert Monitor" automation

### Template Errors

**Symptoms**: Template warnings in logs

**Solutions**:
1. Update to latest package version
2. Use exact parameter names from documentation
3. Template errors are usually warnings, not failures

### Getting Help

**Information to include when asking for help**:
1. Home Assistant version
2. Error messages from logs (sanitize personal information)
3. Configuration snippets (remove tokens and Chat IDs)
4. Steps that reproduce the issue

---

## Appendix

### Complete File Structure

```
/config/
├── configuration.yaml                              # Include packages and lovelace
├── secrets.yaml                                    # House name and Chat IDs
├── update_alerts.sh                                # Self-updating deployment script
├── packages/
│   └── alert_system.yaml                           # Main package file
├── lovelace/
│   └── alert_system_dash.yaml                      # Dashboard configuration
└── blueprints/
    └── automation/
        └── alert_system/
            └── send_alert.yaml                     # Alert automation blueprint
```

### Required Secrets

```yaml
house_name: "Main House"
telegram_main_alerts: "-1001234567890"
telegram_technical_alerts: "-1001234567891"
```
