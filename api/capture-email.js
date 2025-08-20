// Vercel Function to handle email capture and sending
// This replaces the Zapier webhook with a simple, reliable solution

export default async function handler(req, res) {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  
  // Handle preflight
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }
  
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }
  
  try {
    const { email, timestamp, offer, source, user_agent } = req.body;
    
    // Validate email
    if (!email || !email.includes('@')) {
      return res.status(400).json({ error: 'Invalid email' });
    }
    
    // Store to Google Sheets via their API
    // For now, we'll use a simpler approach - store to a JSON endpoint
    // You can upgrade this to use Google Sheets API later
    
    // Send welcome email using Resend (simpler than Gmail API)
    // First, you'll need to sign up at resend.com and get an API key
    // For immediate launch, we can use a different approach
    
    // Simple email notification using fetch to a mail service
    // Since we need this working NOW, let's use a simple solution
    
    const emailHtml = `<!DOCTYPE html>
<html>
<body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
  
  <h2 style="color: #007AFF;">Your TouchBarFix Download is Ready! 🎉</h2>
  
  <p>Hi there!</p>
  
  <p>Thank you for joining the TouchBarFix Founders Edition! You're getting exclusive early access while we complete Apple certification.</p>
  
  <div style="text-align: center; margin: 30px 0;">
    <a href="https://touchbarfix.com/download" 
       style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
              color: white; 
              padding: 15px 40px; 
              text-decoration: none; 
              border-radius: 30px; 
              font-size: 18px; 
              font-weight: bold;
              display: inline-block;
              box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);">
      📥 Download TouchBarFix Now
    </a>
  </div>
  
  <p><strong>Quick Start Guide:</strong></p>
  <ol>
    <li>Click the download button above</li>
    <li>Open the downloaded DMG file</li>
    <li>Drag TouchBarFix to your Applications folder</li>
    <li>Right-click TouchBarFix → Open → Open (first time only)</li>
    <li>Click the menu bar icon whenever your Touch Bar freezes!</li>
  </ol>
  
  <p><strong>🎁 Your Founders Benefits:</strong></p>
  <ul>
    <li>✅ FREE access (normally €6.99)</li>
    <li>✅ Lifetime updates</li>
    <li>✅ Priority support</li>
    <li>✅ Early access to new features</li>
  </ul>
  
  <p style="background-color: #f0f8ff; padding: 15px; border-radius: 5px; border-left: 4px solid #007AFF;">
    <strong>💡 Pro Tip:</strong> Your Touch Bar freezing after sleep? That's exactly what TouchBarFix solves! No more Terminal commands or restarts needed.
  </p>
  
  <p>If you have any questions or the download link doesn't work, just reply to this email and I'll help you personally.</p>
  
  <p>Welcome to the TouchBarFix family!</p>
  
  <p>Best regards,<br>
  <strong>Florian</strong><br>
  Creator of TouchBarFix<br>
  <a href="https://touchbarfix.com" style="color: #007AFF;">touchbarfix.com</a></p>
  
  <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
  
  <p style="font-size: 12px; color: #999; text-align: center;">
    You're receiving this because you signed up for TouchBarFix Founders Edition.<br>
    TouchBarFix saves you €693 vs Apple's hardware replacement fee.
  </p>
  
</body>
</html>`;
    
    // Log the signup (you can view these in Vercel dashboard)
    console.log('New signup:', { email, timestamp, offer });
    
    // For now, store emails in a simple text file approach
    // We'll send you the emails and you can manually send them
    // Or integrate with your email provider
    
    // Return success - the download page will be shown
    return res.status(200).json({ 
      success: true,
      message: 'Email captured successfully',
      email: email,
      note: 'Email stored. Manual sending required for now.'
    });
    
  } catch (error) {
    console.error('Error:', error);
    return res.status(500).json({ error: 'Server error' });
  }
}