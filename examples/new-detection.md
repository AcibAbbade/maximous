# Smart /new Detection Example

## Scenario: User Working for 9 Hours

### Detection Triggers

```
[22:30] System Analysis:
- Session duration: 9 hours
- Context size: 1.2MB
- Response latency: +40% slower
- Error rate: 3 in last 15 minutes
- Score: 65/100 (recommend /new strongly)
```

### System Response (NOT just "do /new")

```
⏰ Hey! I detected signs that a /new would be beneficial:

• Session: 9 hours active
• Performance: 40% slower responses  
• Context: 1.2MB accumulated
• Recent: 3 slow operations in 10 min

💡 Benefits of /new now:
✅ 2-3x faster responses
✅ Better accuracy
✅ Fewer errors  
✅ I'm "rested" and come back sharper

🤔 Can I:
1. Save everything and do /new?
2. Continue a bit more?
3. Explain more about this?
```

### Why This Works Better

**Instead of:**
- "You should do /new" (user wonders why)
- Silent degradation (user gets frustrated)
- Sudden failure (user loses work)

**This approach:**
- Explains specific reasons
- Quantifies the issues  
- Offers clear benefits
- Gives user control (3 options)
- Preserves context automatically

### User Response Options

| Option | Result |
|--------|--------|
| **1. Save & /new** | Checkpoint created → /new → Restore on return |
| **2. Continue** | Resets detection timer, monitors more closely |
| **3. Explain** | Detailed explanation of session mechanics |

### After /new

```
[New Session 08:51]
🔄 PREVIOUS SESSION DETECTED

Duration: 9 hours (22:30 - 08:45)
Project: Website 4Pets (deploy completed)
Status: 100% synced

✅ Context restored
✅ Preferences applied automatically  
✅ Pending tasks loaded

Continue: "Send WhatsApp text for college deadline?"
```

---

## Technical Details

### Detection Algorithm

```
Score = (Hours × 3) + (Errors × 5) + (Performance × 2) + (Context_Size × 1)

Thresholds:
- 20-40: Gentle suggestion
- 40-70: Strong recommendation  
- 70+: Urgent /new needed
```

### Auto-Preparation

When /new is accepted:
1. Force immediate context sync
2. Create comprehensive checkpoint
3. Mark as "restore-ready"
4. Execute /new
5. [New session] Auto-detect and offer restore

### Zero User Action Required

User just says "1" or "yes" - everything else is automatic.
