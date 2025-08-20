// Simple endpoint to retrieve collected emails
// Access this at: https://touchbarfix.com/api/get-emails?key=touchbar2025

export default async function handler(req, res) {
  // Simple auth check
  if (req.query.key !== 'touchbar2025') {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  
  // For now, return instructions since we need persistent storage
  return res.status(200).json({
    message: 'Email collection active',
    instructions: 'Check Vercel Function logs for email signups',
    alternative: 'Use Vercel KV or PostgreSQL for persistent storage',
    emails: [] // This would contain actual emails with proper database
  });
}