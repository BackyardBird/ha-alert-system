# Home Assistant Multi-House Alert System

A centralized, dual-channel notification system for Home Assistant using Telegram, designed for multi-house deployments.

## Features

- **Dual-Channel Routing**: Separate main (household) and technical (system) alert channels
- **Multi-House Support**: Single codebase deployed across multiple locations
- **9 Alert Types**: Specialized scripts for different notification scenarios
- **Centralized Management**: GitHub-based updates with local sync scripts
- **Intelligent Routing**: Context-aware channel selection with fallback handling

## Quick Start

1. **Create Telegram Bot** via @BotFather
2. **Set up Telegram groups** (main + technical per house)
3. **Configure Home Assistant** with GUI Telegram Bot integration
4. **Deploy alert system** package to each house
5. **Test and customize** for your specific needs

## Alert Types

| Script | Purpose | Default Channel |
|--------|---------|----------------|
| `script.test_alert` | System verification | Both |
| `script.quick_alert` | Simple notifications | Main |
| `script.send_alert` | Full-featured alerts | Configurable |
| `script.system_alert` | Technical issues | Technical |
| `script.security_alert` | Security events | Both (forced) |
| `script.device_alert` | Device notifications | Technical |
| `script.bulk_alert` | Multiple alerts | Mixed |
| `script.tech_alert` | Technical convenience | Technical |
| `script.main_alert` | Household convenience | Main |

## Installation

See the complete documentation in the repository for detailed setup instructions.

## Security

- Store all sensitive tokens in Home Assistant secrets.yaml
- Never commit credentials to Git repositories
- Use proper Telegram group permissions
- Regular security audits recommended

## License

MIT License - Use at your own risk
