---
name: user-context-maximizer
description: Maximize session value by capturing user preferences, detecting when /new is needed with clear explanations, and preserving context across sessions. Use when you want intelligent session management, proactive preference learning, and seamless continuity between AI conversations. Ideal for long-running projects and users who want increasingly personalized assistance.
author: Acib ABBADE
version: 1.0.0
license: MIT
homepage: https://github.com/acibabbadecastro/user-context-maximizer
---

# User Context Maximizer

## Overview

Intelligent system for maximizing AI session value through:
- **Preference Learning** - Captures and applies user patterns automatically
- **Smart /new Detection** - Detects when reset is beneficial and **explains why**
- **Context Preservation** - Syncs state in real-time for seamless restoration
- **Flexible Export** - Offers multiple options to save session data

## When to Use

This skill automatically activates for:
- Long sessions (8+ hours) - suggests /new with explanation
- Performance degradation - detects and responds
- Context switches - captures new project information
- Session end - offers data export options

## Quick Start

```bash
# Check if /new would be beneficial
./scripts/smart-new-detector.sh --check

# View session export options
./scripts/data-export.sh --show
```

## How It Works

### 1. Continuous Learning
The system observes your interactions and learns:
- Communication style (direct vs exploratory)
- Preferred formats (tables, code, summaries)
- Working patterns (hours, decision style)
- Technical preferences (stack, tools, workflows)

### 2. Learning "Bait" System
Strategic questions at optimal moments:
- New project started → Ask about preferences
- Under pressure → Ask how to respond
- Good flow → Ask what works best

### 3. Smart Detection
Monitors session health:
- Duration tracking
- Error rate monitoring  
- Performance metrics
- Context size tracking

When thresholds are met, **explains benefits** of /new rather than just suggesting it.

### 4. Data Export Options
At session end or /new:
```
💾 Session captured!

📤 Export to:
1. 📧 Email (summary + files)
2. 💾 Drive/USB (complete backup)
3. 📝 PDF (professional report)
4. 🤖 Next session (auto-preserve)
```

## Scripts

| Script | Purpose |
|--------|---------|
| `smart-new-detector.sh` | Detects /new need and explains benefits |
| `learning-bait.sh` | Asks strategic questions to learn preferences |
| `data-export.sh` | Offers multiple export options |

## Integration

Works with:
- **Preference systems** - Stores learned patterns
- **Backup tools** - Syncs to your storage
- **Session managers** - Preserves context

## Customization

Edit detection thresholds in scripts:
- `SESSION_HOURS_WARNING=6`
- `SESSION_HOURS_URGENT=10`
- `SYNC_INTERVAL=300` (seconds)

## Version

1.0.0 - 2026-04-27

## License

MIT - See LICENSE file
