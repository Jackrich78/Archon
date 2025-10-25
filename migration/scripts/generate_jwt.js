// Simple JWT generator for PostgREST tokens
const crypto = require('crypto');

function base64UrlEncode(str) {
  return Buffer.from(str)
    .toString('base64')
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=/g, '');
}

function generateJWT(secret, role, expiryYears = 10) {
  const header = {
    alg: 'HS256',
    typ: 'JWT'
  };

  const now = Math.floor(Date.now() / 1000);
  const expiry = now + (expiryYears * 365 * 24 * 60 * 60);

  const payload = {
    role: role,
    exp: expiry
  };

  const encodedHeader = base64UrlEncode(JSON.stringify(header));
  const encodedPayload = base64UrlEncode(JSON.stringify(payload));
  const signatureInput = `${encodedHeader}.${encodedPayload}`;

  const signature = crypto
    .createHmac('sha256', secret)
    .update(signatureInput)
    .digest('base64')
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=/g, '');

  return `${signatureInput}.${signature}`;
}

const secret = process.argv[2];
if (!secret) {
  console.error('Usage: node generate_jwt.js <SECRET>');
  process.exit(1);
}

const anonToken = generateJWT(secret, 'anon');
const serviceToken = generateJWT(secret, 'service_role');

console.log('ANON_TOKEN:');
console.log(anonToken);
console.log();
console.log('SERVICE_ROLE_TOKEN:');
console.log(serviceToken);
