# New Claude Session Quick Start - TouchBarFix
**Essential 60-Second Setup for Any New Claude Instance**

*Created: August 23, 2025 - Solves the "work on PRO-X" command issue*

---

## 🚨 **CRITICAL: Read This in Any New Terminal/Session**

If a user says **"work on PRO-X"** and you're a new Claude instance, this file shows you exactly what to do.

---

## ⚡ **60-Second Quick Start**

### **Step 1: Understand the Project (30 seconds)**
```bash
# You're working on TouchBarFix - a MacBook Touch Bar fix app
# Linear workspace: ProduktEntdecker, Project: TouchBarFix  
# 30+ active issues in Linear (replaces GitHub Issues)
```

### **Step 2: Work on Linear Issues (30 seconds)**
```bash
# When user says "work on PRO-41":
./work-on 41

# Other useful commands:
node linear-bridge.js list              # Show all issues
node linear-bridge.js get-issue 41      # Get issue details  
node linear-bridge.js update-status 41 "Done"  # Update status
node linear-bridge.js add-comment 41 "Progress update"  # Add comment
```

---

## 🎯 **Common Commands for New Sessions**

### **"work on PRO-X" → Solution:**
```bash
cd ~/GitHub/touchbarfix  # or wherever the project is
./work-on 41  # This handles everything automatically
```

### **"show me Linear issues" → Solution:**
```bash
node linear-bridge.js list
```

### **"update PRO-X status" → Solution:**
```bash
node linear-bridge.js update-status 41 "In Progress"
# Available statuses: Todo, In Progress, Done, Backlog
```

---

## 📋 **What These Scripts Do**

### **`./work-on PRO-X` Script:**
1. ✅ Gets issue details from Linear API
2. ✅ Updates status to "In Progress"  
3. ✅ Adds "Started working" comment
4. ✅ Shows next steps for implementation

### **`linear-bridge.js` Script:**  
- Direct Linear GraphQL API interface
- Bypasses MCP server complexity
- Works in any Claude Code session
- Full CRUD operations on Linear issues

---

## 🔧 **Why This Solution Exists**

**Problem:** MCP servers require special integration that new Claude sessions don't automatically have.

**Solution:** Direct API bridge scripts that work via simple bash commands.

**Result:** Any new Claude instance can immediately work with Linear issues using familiar command syntax.

---

## 📚 **For Deeper Understanding**

If you have more than 60 seconds, read these files **in order**:

1. **`PROJECT-KNOWLEDGE-INDEX.md`** - Complete project overview
2. **`LINEAR-INTEGRATION-GUIDE.md`** - Full Linear workflow details  
3. **`CLAUDE.md`** - Project-specific instructions

**But if the user wants you to work on a Linear issue RIGHT NOW, just use the bridge scripts above.** ⚡

---

## 🎉 **Success Test**

After reading this file, you should be able to:

- ✅ Execute `./work-on 41` when user says "work on PRO-41"
- ✅ List all Linear issues with `node linear-bridge.js list`
- ✅ Update issue status and add comments
- ✅ Understand you're working on TouchBarFix app business

**If this works, you're ready to be productive immediately!** 🚀

---

*This file solves the "New Instance of Claude Code doesn't know about Linear Integration" problem (PRO-41) and ensures seamless handoffs between Claude sessions.*