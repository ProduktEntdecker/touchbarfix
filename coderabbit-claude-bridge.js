#!/usr/bin/env node
/**
 * CodeRabbit-Claude Bridge
 * A custom integration that allows Claude Code to interact with CodeRabbit reviews
 * without relying on potentially buggy MCP servers.
 */

const { Octokit } = require('@octokit/rest');
const fs = require('fs');
const path = require('path');

class CodeRabbitClaudeBridge {
    constructor() {
        this.octokit = null;
        this.defaultRepo = 'ProduktEntdecker/touchbarfix';
    }

    /**
     * Initialize GitHub API with authentication
     */
    async init() {
        // Try to get token from environment or config
        let token = process.env.GITHUB_TOKEN;
        
        if (!token) {
            const configPath = path.join(process.env.HOME, '.config', 'mcp', '.env');
            if (fs.existsSync(configPath)) {
                const config = fs.readFileSync(configPath, 'utf8');
                const tokenMatch = config.match(/GITHUB_TOKEN=(.+)/);
                if (tokenMatch) {
                    token = tokenMatch[1].trim();
                }
            }
        }

        if (!token || token === 'YOUR_GITHUB_TOKEN_HERE') {
            throw new Error('GitHub token not found. Please set GITHUB_TOKEN environment variable or configure ~/.config/mcp/.env');
        }

        this.octokit = new Octokit({
            auth: token,
        });

        // Verify authentication
        try {
            const { data: user } = await this.octokit.rest.users.getAuthenticated();
            console.log(`✅ Authenticated as: ${user.login}`);
            return true;
        } catch (error) {
            throw new Error(`Authentication failed: ${error.message}`);
        }
    }

    /**
     * Get all pull requests for a repository
     */
    async getPullRequests(owner, repo, state = 'open') {
        const [repoOwner, repoName] = this.parseRepo(owner, repo);
        
        try {
            const { data: prs } = await this.octokit.rest.pulls.list({
                owner: repoOwner,
                repo: repoName,
                state: state,
                sort: 'updated',
                direction: 'desc',
            });

            return prs.map(pr => ({
                number: pr.number,
                title: pr.title,
                state: pr.state,
                author: pr.user.login,
                branch: pr.head.ref,
                url: pr.html_url,
                created: pr.created_at,
                updated: pr.updated_at,
            }));
        } catch (error) {
            throw new Error(`Failed to fetch PRs: ${error.message}`);
        }
    }

    /**
     * Get all reviews for a specific pull request
     */
    async getReviews(owner, repo, prNumber) {
        const [repoOwner, repoName] = this.parseRepo(owner, repo);

        try {
            const { data: reviews } = await this.octokit.rest.pulls.listReviews({
                owner: repoOwner,
                repo: repoName,
                pull_number: prNumber,
            });

            return reviews.map(review => ({
                id: review.id,
                user: review.user?.login || 'Unknown',
                state: review.state,
                body: review.body,
                submitted_at: review.submitted_at,
                isCodeRabbit: review.user?.login === 'coderabbitai' || review.user?.login?.includes('coderabbit'),
            }));
        } catch (error) {
            throw new Error(`Failed to fetch reviews: ${error.message}`);
        }
    }

    /**
     * Get review comments (line-by-line comments)
     */
    async getReviewComments(owner, repo, prNumber) {
        const [repoOwner, repoName] = this.parseRepo(owner, repo);

        try {
            const { data: comments } = await this.octokit.rest.pulls.listReviewComments({
                owner: repoOwner,
                repo: repoName,
                pull_number: prNumber,
            });

            return comments.map(comment => ({
                id: comment.id,
                user: comment.user?.login || 'Unknown',
                body: comment.body,
                path: comment.path,
                line: comment.line,
                position: comment.position,
                created_at: comment.created_at,
                updated_at: comment.updated_at,
                isCodeRabbit: comment.user?.login === 'coderabbitai' || comment.user?.login?.includes('coderabbit'),
            }));
        } catch (error) {
            throw new Error(`Failed to fetch review comments: ${error.message}`);
        }
    }

    /**
     * Get issue comments (general PR comments)
     */
    async getIssueComments(owner, repo, prNumber) {
        const [repoOwner, repoName] = this.parseRepo(owner, repo);

        try {
            const { data: comments } = await this.octokit.rest.issues.listComments({
                owner: repoOwner,
                repo: repoName,
                issue_number: prNumber,
            });

            return comments.map(comment => ({
                id: comment.id,
                user: comment.user?.login || 'Unknown',
                body: comment.body,
                created_at: comment.created_at,
                updated_at: comment.updated_at,
                isCodeRabbit: comment.user?.login === 'coderabbitai' || comment.user?.login?.includes('coderabbit'),
            }));
        } catch (error) {
            throw new Error(`Failed to fetch issue comments: ${error.message}`);
        }
    }

    /**
     * Get comprehensive CodeRabbit feedback for a PR
     */
    async getCodeRabbitFeedback(owner, repo, prNumber) {
        const [repoOwner, repoName] = this.parseRepo(owner, repo);

        console.log(`🔍 Fetching CodeRabbit feedback for PR #${prNumber} in ${repoOwner}/${repoName}`);

        const [reviews, reviewComments, issueComments] = await Promise.all([
            this.getReviews(repoOwner, repoName, prNumber),
            this.getReviewComments(repoOwner, repoName, prNumber),
            this.getIssueComments(repoOwner, repoName, prNumber),
        ]);

        // Filter CodeRabbit feedback
        const codeRabbitReviews = reviews.filter(r => r.isCodeRabbit);
        const codeRabbitReviewComments = reviewComments.filter(c => c.isCodeRabbit);
        const codeRabbitIssueComments = issueComments.filter(c => c.isCodeRabbit);

        return {
            prNumber,
            repository: `${repoOwner}/${repoName}`,
            summary: {
                total_reviews: codeRabbitReviews.length,
                total_review_comments: codeRabbitReviewComments.length,
                total_issue_comments: codeRabbitIssueComments.length,
            },
            reviews: codeRabbitReviews,
            reviewComments: codeRabbitReviewComments,
            issueComments: codeRabbitIssueComments,
        };
    }

    /**
     * Create a comment on a PR
     */
    async createComment(owner, repo, prNumber, body) {
        const [repoOwner, repoName] = this.parseRepo(owner, repo);

        try {
            const { data: comment } = await this.octokit.rest.issues.createComment({
                owner: repoOwner,
                repo: repoName,
                issue_number: prNumber,
                body: body,
            });

            console.log(`✅ Comment created: ${comment.html_url}`);
            return comment;
        } catch (error) {
            throw new Error(`Failed to create comment: ${error.message}`);
        }
    }

    /**
     * Parse repository string into owner and repo
     */
    parseRepo(owner, repo) {
        if (repo === undefined) {
            // If only one argument provided, treat it as "owner/repo" format
            if (owner.includes('/')) {
                return owner.split('/');
            } else {
                // Use default repo with provided owner as repo name
                return [this.defaultRepo.split('/')[0], owner];
            }
        }
        return [owner, repo];
    }

    /**
     * Format CodeRabbit feedback for display
     */
    formatFeedback(feedback) {
        let output = '';
        
        output += `\n📊 CodeRabbit Feedback Summary for PR #${feedback.prNumber}\n`;
        output += `Repository: ${feedback.repository}\n`;
        output += `─────────────────────────────────────\n`;
        
        if (feedback.summary.total_reviews === 0 && 
            feedback.summary.total_review_comments === 0 && 
            feedback.summary.total_issue_comments === 0) {
            output += `❌ No CodeRabbit feedback found for this PR\n`;
            output += `   Make sure CodeRabbit app is installed and has reviewed this PR\n`;
            return output;
        }

        output += `📈 Statistics:\n`;
        output += `   • Reviews: ${feedback.summary.total_reviews}\n`;
        output += `   • Line Comments: ${feedback.summary.total_review_comments}\n`;
        output += `   • General Comments: ${feedback.summary.total_issue_comments}\n\n`;

        // Display reviews
        if (feedback.reviews.length > 0) {
            output += `🔍 Reviews:\n`;
            feedback.reviews.forEach((review, index) => {
                output += `   ${index + 1}. State: ${review.state}\n`;
                if (review.body) {
                    output += `      Summary: ${review.body.substring(0, 200)}${review.body.length > 200 ? '...' : ''}\n`;
                }
                output += `      Submitted: ${new Date(review.submitted_at).toLocaleString()}\n\n`;
            });
        }

        // Display line-by-line comments
        if (feedback.reviewComments.length > 0) {
            output += `📝 Line-by-Line Comments:\n`;
            feedback.reviewComments.forEach((comment, index) => {
                output += `   ${index + 1}. File: ${comment.path}:${comment.line}\n`;
                output += `      Comment: ${comment.body.substring(0, 300)}${comment.body.length > 300 ? '...' : ''}\n`;
                output += `      Created: ${new Date(comment.created_at).toLocaleString()}\n\n`;
            });
        }

        // Display general comments
        if (feedback.issueComments.length > 0) {
            output += `💬 General Comments:\n`;
            feedback.issueComments.forEach((comment, index) => {
                output += `   ${index + 1}. ${comment.body.substring(0, 300)}${comment.body.length > 300 ? '...' : ''}\n`;
                output += `      Created: ${new Date(comment.created_at).toLocaleString()}\n\n`;
            });
        }

        return output;
    }
}

/**
 * Command line interface
 */
async function main() {
    const args = process.argv.slice(2);
    const command = args[0];

    if (!command) {
        console.log(`
CodeRabbit-Claude Bridge v1.0.0
Usage: node coderabbit-claude-bridge.js <command> [options]

Commands:
  list-prs [owner/repo]           List pull requests
  get-feedback <pr-number> [owner/repo]  Get CodeRabbit feedback
  get-reviews <pr-number> [owner/repo]   Get all reviews
  get-comments <pr-number> [owner/repo]  Get all comments
  comment <pr-number> <message> [owner/repo]  Add comment to PR

Examples:
  node coderabbit-claude-bridge.js list-prs
  node coderabbit-claude-bridge.js get-feedback 123
  node coderabbit-claude-bridge.js get-feedback 123 owner/repo
  node coderabbit-claude-bridge.js comment 123 "Thanks for the review!"
        `);
        return;
    }

    const bridge = new CodeRabbitClaudeBridge();
    
    try {
        await bridge.init();

        switch (command) {
            case 'list-prs': {
                const repo = args[1] || bridge.defaultRepo;
                const [owner, repoName] = repo.includes('/') ? repo.split('/') : [repo.split('/')[0], repo];
                const prs = await bridge.getPullRequests(owner, repoName);
                
                console.log(`\n📋 Pull Requests in ${owner}/${repoName}:\n`);
                prs.forEach(pr => {
                    console.log(`#${pr.number}: ${pr.title}`);
                    console.log(`   Branch: ${pr.branch} | Author: ${pr.author} | Updated: ${new Date(pr.updated).toLocaleDateString()}`);
                    console.log(`   URL: ${pr.url}\n`);
                });
                break;
            }

            case 'get-feedback': {
                const prNumber = parseInt(args[1]);
                const repo = args[2] || bridge.defaultRepo;
                const [owner, repoName] = repo.includes('/') ? repo.split('/') : [bridge.defaultRepo.split('/')[0], repo];
                
                if (!prNumber) {
                    console.error('❌ PR number is required');
                    process.exit(1);
                }

                const feedback = await bridge.getCodeRabbitFeedback(owner, repoName, prNumber);
                console.log(bridge.formatFeedback(feedback));
                break;
            }

            case 'get-reviews': {
                const prNumber = parseInt(args[1]);
                const repo = args[2] || bridge.defaultRepo;
                const [owner, repoName] = repo.includes('/') ? repo.split('/') : [bridge.defaultRepo.split('/')[0], repo];
                
                const reviews = await bridge.getReviews(owner, repoName, prNumber);
                console.log(`\n📝 Reviews for PR #${prNumber}:\n`);
                reviews.forEach((review, index) => {
                    console.log(`${index + 1}. ${review.user} (${review.state})`);
                    if (review.body) console.log(`   ${review.body.substring(0, 200)}...`);
                    console.log('');
                });
                break;
            }

            case 'comment': {
                const prNumber = parseInt(args[1]);
                const message = args[2];
                const repo = args[3] || bridge.defaultRepo;
                const [owner, repoName] = repo.includes('/') ? repo.split('/') : [bridge.defaultRepo.split('/')[0], repo];
                
                if (!prNumber || !message) {
                    console.error('❌ PR number and message are required');
                    process.exit(1);
                }

                await bridge.createComment(owner, repoName, prNumber, message);
                break;
            }

            default:
                console.error(`❌ Unknown command: ${command}`);
                process.exit(1);
        }

    } catch (error) {
        console.error(`❌ Error: ${error.message}`);
        process.exit(1);
    }
}

if (require.main === module) {
    main();
}

module.exports = CodeRabbitClaudeBridge;