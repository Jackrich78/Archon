#!/usr/bin/env python3
"""
Generate JWT tokens for PostgREST authentication.

This script creates JWT tokens for the anon and service_role roles
using the generated JWT secret.
"""

import sys
import jwt
from datetime import datetime, timedelta

def generate_jwt_token(secret: str, role: str) -> str:
    """
    Generate a JWT token for PostgREST.

    Args:
        secret: JWT secret key
        role: Database role (anon or service_role)

    Returns:
        JWT token string
    """
    # Token expires in 10 years (effectively permanent for local dev)
    expiration = datetime.utcnow() + timedelta(days=3650)

    payload = {
        "role": role,
        "exp": int(expiration.timestamp())
    }

    token = jwt.encode(payload, secret, algorithm="HS256")
    return token

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python generate_jwt_tokens.py <JWT_SECRET>")
        sys.exit(1)

    jwt_secret = sys.argv[1]

    anon_token = generate_jwt_token(jwt_secret, "anon")
    service_token = generate_jwt_token(jwt_secret, "service_role")

    print("ANON_TOKEN:")
    print(anon_token)
    print()
    print("SERVICE_ROLE_TOKEN:")
    print(service_token)
