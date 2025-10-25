"""
Client Manager Service

Manages database and API client connections.
"""

import os
import re

from postgrest import SyncPostgrestClient
from supabase import Client, create_client

from ..config.logfire_config import search_logger


def get_supabase_client() -> Client:
    """
    Get a Supabase client instance.

    For local PostgREST (archon-postgrest), creates a direct PostgREST client.
    For cloud Supabase, uses the standard supabase-py wrapper.

    Returns:
        Supabase client instance (or PostgREST client for local)
    """
    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_SERVICE_KEY")

    if not url or not key:
        raise ValueError(
            "SUPABASE_URL and SUPABASE_SERVICE_KEY must be set in environment variables"
        )

    try:
        # Check if this is local PostgREST (not cloud Supabase)
        if "archon-postgrest" in url:
            # Use PostgREST client directly for local database
            search_logger.debug(f"Local PostgREST detected, connecting to {url}")

            # Create PostgREST client with service_role token
            client = SyncPostgrestClient(
                base_url=url,
                schema="public",
                headers={
                    "apikey": key,
                    "Authorization": f"Bearer {key}"
                }
            )
            search_logger.debug("PostgREST client initialized for local database")
            return client
        else:
            # Use standard Supabase client for cloud
            client = create_client(url, key)

            # Extract project ID from URL for logging
            match = re.match(r"https://([^.]+)\.supabase\.co", url)
            if match:
                project_id = match.group(1)
                search_logger.debug(f"Supabase client initialized - project_id={project_id}")

            return client
    except Exception as e:
        search_logger.error(f"Failed to create Supabase client: {e}")
        raise
