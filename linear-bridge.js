#!/usr/bin/env node

/**
 * Linear Bridge - Connect Claude Code to Linear API
 * 
 * This script bridges the gap between Claude Code's bash capabilities
 * and the Linear GraphQL API, enabling commands like "work on PRO-X"
 * 
 * Usage:
 *   node linear-bridge.js get-issue 41
 *   node linear-bridge.js update-status 41 "In Progress"
 *   node linear-bridge.js add-comment 41 "Started working on this issue"
 *   node linear-bridge.js create-issue "Fix bug" "Bug description" --priority=high
 */

const https = require('https');

const API_KEY = 'lin_api_LBNtToXYplT7tsn1eTaDZ22PIAzzQL9gf8qzZgCx';
const API_ENDPOINT = 'api.linear.app';

// Workflow state IDs (from previous session)
const STATES = {
  'Todo': 'cc5863d8-01cd-4d5b-a9b2-a7adeafd1fbc',
  'In Progress': '8f6cfcd3-9a00-4071-8652-51d94837abf0', 
  'Done': 'adf0279c-a325-47ba-a82b-d8fa768af697',
  'Backlog': 'c2a8f29b-6e7c-4b4f-afd9-b66cf2f139f8'
};

function makeGraphQLRequest(query, variables = {}) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify({ query, variables });
    
    const options = {
      hostname: API_ENDPOINT,
      path: '/graphql',
      method: 'POST',
      headers: {
        'Authorization': API_KEY,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(data)
      }
    };

    const req = https.request(options, (res) => {
      let responseData = '';
      
      res.on('data', (chunk) => {
        responseData += chunk;
      });
      
      res.on('end', () => {
        try {
          const parsed = JSON.parse(responseData);
          if (parsed.errors) {
            reject(new Error(`GraphQL Error: ${JSON.stringify(parsed.errors)}`));
          } else {
            resolve(parsed.data);
          }
        } catch (error) {
          reject(new Error(`JSON Parse Error: ${error.message}`));
        }
      });
    });

    req.on('error', (error) => {
      reject(new Error(`Request Error: ${error.message}`));
    });

    req.write(data);
    req.end();
  });
}

async function getIssue(issueNumber) {
  const query = `
    query GetIssue($number: Float!) {
      issues(filter: { number: { eq: $number } }) {
        nodes {
          id
          identifier
          title
          description
          state { name }
          priority
          assignee { name }
          labels { nodes { name } }
          createdAt
          updatedAt
        }
      }
    }
  `;
  
  try {
    const data = await makeGraphQLRequest(query, { number: parseInt(issueNumber) });
    const issue = data.issues.nodes[0];
    
    if (!issue) {
      console.log(`❌ Issue PRO-${issueNumber} not found`);
      return;
    }
    
    console.log(`📋 **${issue.identifier}: ${issue.title}**`);
    console.log(`Status: ${issue.state.name}`);
    console.log(`Assigned to: ${issue.assignee?.name || 'Unassigned'}`);
    console.log(`Priority: ${issue.priority || 'Normal'}`);
    console.log(`Labels: ${issue.labels.nodes.map(l => l.name).join(', ') || 'None'}`);
    console.log(`\n**Description:**`);
    console.log(issue.description || 'No description');
    
    return issue;
  } catch (error) {
    console.error('❌ Error fetching issue:', error.message);
  }
}

async function updateIssueStatus(issueNumber, newStatus) {
  if (!STATES[newStatus]) {
    console.log(`❌ Invalid status: ${newStatus}`);
    console.log(`Available statuses: ${Object.keys(STATES).join(', ')}`);
    return;
  }
  
  // First get the issue to get its ID
  const issue = await getIssue(issueNumber);
  if (!issue) return;
  
  const query = `
    mutation UpdateIssueStatus($issueId: String!, $stateId: String!) {
      issueUpdate(id: $issueId, input: { stateId: $stateId }) {
        success
      }
    }
  `;
  
  try {
    await makeGraphQLRequest(query, { 
      issueId: issue.id, 
      stateId: STATES[newStatus] 
    });
    console.log(`✅ Updated PRO-${issueNumber} status to "${newStatus}"`);
  } catch (error) {
    console.error('❌ Error updating status:', error.message);
  }
}

async function addComment(issueNumber, comment) {
  // First get the issue to get its ID
  const issue = await getIssue(issueNumber);
  if (!issue) return;
  
  const query = `
    mutation AddComment($issueId: String!, $body: String!) {
      commentCreate(input: { issueId: $issueId, body: $body }) {
        success
      }
    }
  `;
  
  try {
    await makeGraphQLRequest(query, { 
      issueId: issue.id, 
      body: comment 
    });
    console.log(`✅ Added comment to PRO-${issueNumber}`);
  } catch (error) {
    console.error('❌ Error adding comment:', error.message);
  }
}

async function listIssues() {
  const query = `
    query ListIssues {
      issues(filter: { state: { name: { neq: "Done" } } }, orderBy: updatedAt) {
        nodes {
          identifier
          title
          state { name }
          priority
          assignee { name }
          updatedAt
        }
      }
    }
  `;
  
  try {
    const data = await makeGraphQLRequest(query);
    console.log(`📋 **Open TouchBarFix Issues**\n`);
    
    data.issues.nodes.forEach(issue => {
      const priority = issue.priority === 1 ? '🚨 Urgent' : 
                     issue.priority === 2 ? '🔥 High' : 
                     issue.priority === 3 ? '📋 Medium' : '💤 Low';
      
      console.log(`${issue.identifier}: ${issue.title}`);
      console.log(`  Status: ${issue.state.name} | ${priority} | ${issue.assignee?.name || 'Unassigned'}`);
      console.log('');
    });
  } catch (error) {
    console.error('❌ Error listing issues:', error.message);
  }
}

// Main CLI handler
async function main() {
  const [,, command, ...args] = process.argv;
  
  switch (command) {
    case 'get-issue':
    case 'get':
      if (!args[0]) {
        console.log('Usage: node linear-bridge.js get-issue <number>');
        return;
      }
      await getIssue(args[0]);
      break;
      
    case 'update-status':
    case 'status':
      if (!args[0] || !args[1]) {
        console.log('Usage: node linear-bridge.js update-status <number> "<status>"');
        console.log('Available statuses: Todo, In Progress, Done, Backlog');
        return;
      }
      await updateIssueStatus(args[0], args[1]);
      break;
      
    case 'add-comment':
    case 'comment':
      if (!args[0] || !args[1]) {
        console.log('Usage: node linear-bridge.js add-comment <number> "<comment>"');
        return;
      }
      await addComment(args[0], args[1]);
      break;
      
    case 'list':
    case 'ls':
      await listIssues();
      break;
      
    default:
      console.log(`
🔗 **Linear Bridge for TouchBarFix**

Available commands:
  get-issue <number>              Get details for PRO-<number>
  update-status <number> <status> Update issue status
  add-comment <number> <comment>  Add progress comment
  list                           List all open issues

Examples:
  node linear-bridge.js get-issue 41
  node linear-bridge.js update-status 41 "In Progress"  
  node linear-bridge.js add-comment 41 "Started working on this"
  node linear-bridge.js list

Status options: Todo, In Progress, Done, Backlog
      `);
  }
}

if (require.main === module) {
  main().catch(console.error);
}

module.exports = { getIssue, updateIssueStatus, addComment, listIssues };