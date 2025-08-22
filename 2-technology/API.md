# API Documentation (Public Endpoints)

Last updated: 2025-08-20

These endpoints are hosted via Vercel serverless functions under `/api`.

## POST /api/capture-email
- Purpose: Capture an email address for delivering the download link/updates.
- Auth: None (browser form). CORS restricted to `https://touchbarfix.com` (recommended).
- Rate limiting: Recommended at Edge/Middleware (e.g., 10/min IP).

Request
```
POST /api/capture-email
Content-Type: application/json
{
  "email": "user@example.com",
  "timestamp": "2025-08-20T12:34:56.000Z",
  "offer": "founders_edition_free",
  "source": "https://touchbarfix.com",
  "user_agent": "..." // optional, truncated
}
```

Response (200)
```
{
  "success": true,
  "message": "Email captured successfully"
}
```

Validation
- Email must be syntactically valid and <= 254 chars.
- Body size capped (e.g., 1–5 KB).
- Reject additional unexpected fields.

Storage and Emailing
- Use Vercel KV/Postgres for persistent storage with consent metadata.
- Send double opt-in via Resend/Postmark/SES (store confirmation token).

## GET /api/get-emails (Admin-Only or Removed)
- Current simple version uses a hardcoded key; remove or replace with proper admin auth backed by env secrets and a database.
- If kept, strictly protect with authentication and IP allowlists.

## Environment Variables (examples)
- `RESEND_API_KEY` – transactional email provider key
- `DATABASE_URL` – Postgres connection URL or `KV_REST_API_URL`/`KV_REST_API_TOKEN`
- `ADMIN_API_KEY` – if an admin endpoint is necessary

## Error Responses
- 400 – validation failed (invalid email, oversized body)
- 401/403 – unauthorized (for admin endpoints)
- 405 – method not allowed
- 429 – rate limited
- 500 – internal error

