"""JWT query-param authentication for Channels WebSocket connections."""
from urllib.parse import parse_qs

from channels.db import database_sync_to_async
from channels.middleware import BaseMiddleware
from django.contrib.auth.models import AnonymousUser
from rest_framework_simplejwt.exceptions import InvalidToken, TokenError
from rest_framework_simplejwt.tokens import AccessToken


@database_sync_to_async
def _user_from_token(raw_token: str):
    from django.contrib.auth import get_user_model

    User = get_user_model()
    try:
        validated = AccessToken(raw_token)
        return User.objects.get(pk=validated['user_id'])
    except (TokenError, InvalidToken, User.DoesNotExist, KeyError):
        return AnonymousUser()


class JWTQueryParamMiddleware(BaseMiddleware):
    """Authenticate via ?token=<access_jwt> — matches the Flutter clients."""

    async def __call__(self, scope, receive, send):
        query = parse_qs(scope.get('query_string', b'').decode())
        token_list = query.get('token')
        if token_list:
            scope['user'] = await _user_from_token(token_list[0])
        else:
            scope.setdefault('user', AnonymousUser())
        return await super().__call__(scope, receive, send)
