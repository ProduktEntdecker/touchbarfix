# Linear Integration Guide - TouchBarFix Project
**Complete Workflow for Claude Code ↔ Linear Task Management**

*Last Updated: August 23, 2025 - Essential for all new Claude sessions*

---

## 🎯 **CRITICAL: Read This First**

**Linear has REPLACED daily .md todo files.** All task management now happens through Linear workspace integration with bi-directional assignment between human and AI.

## 🔧 **Integration Status: FULLY OPERATIONAL**

### **✅ What's Working:**
- Linear MCP integration configured in `/Users/floriansteiner/.config/mcp/servers.json`
- API key: `lin_api_LBNtToXYplT7tsn1eTaDZ22PIAzzQL9gf8qzZgCx`
- Workspace: **ProduktEntdecker** 
- Project: **TouchBarFix**
- **32+ active issues** imported and ready

### **🤖 Claude Capabilities:**
- ✅ **Read Linear issues** - Get details, status, priorities, assignees
- ✅ **Update issue status** - Todo → In Progress → Done
- ✅ **Add comments** - Progress updates, notes, completion details
- ✅ **Create new issues** - Full metadata (title, description, priority, labels)
- ✅ **Query and filter** - Search by priority, assignee, labels, project

---

## 💬 **Command Syntax for New Claude Sessions**

### **Working on Assigned Tasks:**
```
"work on PRO-15"
"work on PRO-40"  
"update PRO-23 to In Progress"
"add progress comment to PRO-8"
```

### **Creating New Tasks:**
```
"create Linear issue for implementing dark mode"
"create high-priority issue for fixing payment bug"
"add Linear task: App Store screenshot generation"
```

### **Status Queries:**
```
"show me all high-priority Linear issues"
"what's the status of marketing tasks in Linear?"
"list all Linear issues assigned to Florian"
```

---

## 🔄 **Bi-Directional Assignment Workflow**

### **Human → Claude Assignment:**
1. **Direct Command**: "work on PRO-15"
2. **Claude Response**: 
   - Reads issue details via Linear API
   - Updates status to "In Progress"  
   - Adds progress comment
   - Begins actual work implementation

### **Claude → Human Assignment:**
1. **Claude Creates Issue**: Using Linear API with human assignee
2. **Human Notification**: Issue appears in Linear workspace
3. **Human Acceptance**: Work begins, status updates flow back

---

## 📊 **Current TouchBarFix Linear Issues (32+)**

### **Issue Categories:**
- **Marketing** (PRO-1 to PRO-10): Reddit campaigns, content creation, SEO
- **Business** (PRO-11 to PRO-15): Sales monitoring, analytics, App Store prep
- **Development** (PRO-16 to PRO-30): Features, testing, infrastructure  
- **GitHub** (PRO-31 to PRO-32): Documentation, process improvements

### **Priority Levels:**
- **1 = Urgent** (Due Aug 23-27): Marketing launch, Zapier cancellation
- **2 = High**: App Store submission, Reddit campaigns
- **3 = Medium**: Content creation, community building
- **4 = Low**: Future features, v2.0 planning

---

## 🛠️ **Technical Implementation**

### **Linear API Access:**
```bash
# API Endpoint: https://api.linear.app/graphql
# Authentication: lin_api_LBNtToXYplT7tsn1eTaDZ22PIAzzQL9gf8qzZgCx
# Workspace ID: ProduktEntdecker
# Project: TouchBarFix
```

### **Common GraphQL Queries:**

**Get Issue Details:**
```graphql
query {
  issues(filter: { number: { eq: 15 } }) {
    nodes {
      id identifier title description 
      state { name } priority 
      assignee { name }
      labels { nodes { name } }
    }
  }
}
```

**Update Issue Status:**
```graphql
mutation {
  issueUpdate(id: "issue_uuid", input: { 
    stateId: "8f6cfcd3-9a00-4071-8652-51d94837abf0" 
  }) { success }
}
```

### **Workflow State IDs:**
- **Todo**: `cc5863d8-01cd-4d5b-a9b2-a7adeafd1fbc`
- **In Progress**: `8f6cfcd3-9a00-4071-8652-51d94837abf0`
- **Done**: `adf0279c-a325-47ba-a82b-d8fa768af697`

---

## 🚀 **Session Startup Protocol**

### **For New Claude Sessions - MANDATORY:**

1. **Read This Guide** (30 seconds)
2. **Understand Linear Context** (30 seconds)
3. **Ready for Commands** like "work on PRO-X"

### **When User Says "work on PRO-X":**
1. ✅ Query Linear API for issue details
2. ✅ Update status to "In Progress" 
3. ✅ Add progress comment
4. ✅ Begin actual work implementation
5. ✅ Update Linear with results

---

## 📈 **Success Metrics**

### **Integration Benefits Achieved:**
- ❌ **Eliminated**: Daily .md todo files
- ✅ **Corporate-grade**: Task management with priorities and deadlines
- ✅ **Bi-directional**: Both human and AI can assign tasks
- ✅ **Persistent**: Tasks survive between sessions
- ✅ **Trackable**: Full audit trail of work progress

### **Usage Examples (Recent):**
- **PRO-15** (App Store Prep): Completed - Created comprehensive submission guide
- **PRO-10** (Apple Notarization): Assigned to human
- **PRO-8** (Marketing Campaign): High priority, due Aug 23

---

## ⚡ **Quick Reference**

### **Essential Commands:**
- `work on PRO-[number]` - Start working on Linear issue
- `create Linear issue for [task]` - Create new task
- `show Linear status` - Get current project overview

### **Integration Files:**
- **MCP Config**: `/Users/floriansteiner/.config/mcp/servers.json`
- **This Guide**: `LINEAR-INTEGRATION-GUIDE.md`
- **Master Index**: `PROJECT-KNOWLEDGE-INDEX.md`

---

**🎯 BOTTOM LINE: Linear integration is LIVE and replaces all previous todo systems. New Claude sessions can immediately work on Linear issues using "work on PRO-X" commands.**

*This workflow enables enterprise-grade task management for the TouchBarFix solopreneur business while maintaining speed and simplicity.*