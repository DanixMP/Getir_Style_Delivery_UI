"""
Neshan API client (search, routing, distance matrix, map tiles).

Server-side so the API key never reaches the browser and CORS is avoided.
Docs:
  https://platform.neshan.org/docs/api/search-category/search/
  https://platform.neshan.org/docs/api/routing-category/routing/
  https://platform.neshan.org/docs/api/routing-category/distance-matrix/
  https://platform.neshan.org/docs/api/static-map-category/static-map/
"""
import logging
import math

import requests
from django.conf import settings

logger = logging.getLogger(__name__)

_SEARCH_URL = 'https://api.neshan.org/v1/search'
_REVERSE_URL = 'https://api.neshan.org/v5/reverse'
_DIRECTION_URL = 'https://api.neshan.org/v4/direction'
_DISTANCE_MATRIX_URL = 'https://api.neshan.org/v1/distance-matrix'
_STATIC_TILE_URL = 'https://api.neshan.org/v5/static'
_TIMEOUT = 10
_TILE_SIZE = 256


def _headers() -> dict:
    api_key = getattr(settings, 'NESHAN_API_KEY', '')
    return {'Api-Key': api_key}


def _api_key_ok() -> bool:
    if not getattr(settings, 'NESHAN_API_KEY', ''):
        logger.warning('NESHAN_API_KEY is not configured.')
        return False
    return True


def search_places(term: str, lat: float, lng: float) -> list[dict]:
    """
    Location-based search. Returns up to 30 results:
    [{title, address, neighbourhood, region, lat, lng}, ...]
    """
    if not _api_key_ok() or not term.strip():
        return []
    try:
        resp = requests.get(
            _SEARCH_URL,
            headers=_headers(),
            params={'term': term.strip(), 'lat': lat, 'lng': lng},
            timeout=_TIMEOUT,
        )
        body = resp.json()
        items = body.get('items') or []
        results = []
        for item in items:
            loc = item.get('location') or {}
            lat_val = loc.get('y')
            lng_val = loc.get('x')
            if lat_val is None or lng_val is None:
                continue
            results.append({
                'title': item.get('title', ''),
                'address': item.get('address', ''),
                'neighbourhood': item.get('neighbourhood', ''),
                'region': item.get('region', ''),
                'type': item.get('type', ''),
                'category': item.get('category', ''),
                'lat': float(lat_val),
                'lng': float(lng_val),
            })
        return results
    except Exception as exc:  # pragma: no cover - network dependent
        logger.warning('Neshan search failed: %s', exc)
        return []


def _clean_admin_prefix(value: str, prefix: str) -> str:
    value = (value or '').strip()
    if value.startswith(prefix):
        return value[len(prefix) :].strip()
    return value


def _resolve_city_from_reverse(body: dict) -> str:
    """Best-effort city label from Neshan reverse payload."""
    city = (body.get('city') or '').strip()
    if city:
        return city

    village = (body.get('village') or '').strip()
    if village:
        return village

    formatted = (body.get('formatted_address') or '').strip()
    if '،' in formatted:
        first = formatted.split('،', 1)[0].strip()
        if first:
            return first
    if ',' in formatted:
        first = formatted.split(',', 1)[0].strip()
        if first:
            return first

    county = _clean_admin_prefix(body.get('county') or '', 'شهرستان ')
    if county:
        return county

    return _clean_admin_prefix(body.get('state') or '', 'استان ')


def reverse_geocode(lat: float, lng: float) -> dict | None:
    """
    Convert coordinates to a readable address via Neshan Reverse Geocoding v5.
    Returns {formatted_address, city, state, neighbourhood, place, route_name, lat, lng}
    or None on failure.
    """
    if not _api_key_ok():
        return None
    try:
        resp = requests.get(
            _REVERSE_URL,
            headers=_headers(),
            params={'lat': lat, 'lng': lng},
            timeout=_TIMEOUT,
        )
        body = resp.json()
        if body.get('status') not in (None, 'OK'):
            logger.warning('Neshan reverse failed: %s', body)
            return None
        return {
            'formatted_address': body.get('formatted_address', ''),
            'city': _resolve_city_from_reverse(body),
            'state': body.get('state') or '',
            'neighbourhood': body.get('neighbourhood') or '',
            'place': body.get('place') or '',
            'route_name': body.get('route_name') or '',
            'village': body.get('village') or '',
            'county': body.get('county') or '',
            'lat': lat,
            'lng': lng,
        }
    except Exception as exc:  # pragma: no cover - network dependent
        logger.warning('Neshan reverse geocode failed: %s', exc)
        return None


def _decode_polyline(encoded: str) -> list[tuple[float, float]]:
    """Google/Neshan encoded polyline → [(lat, lng), ...]."""
    if not encoded:
        return []
    points: list[tuple[float, float]] = []
    index = 0
    lat = 0
    lng = 0
    length = len(encoded)
    while index < length:
        result = 0
        shift = 0
        while True:
            b = ord(encoded[index]) - 63
            index += 1
            result |= (b & 0x1F) << shift
            shift += 5
            if b < 0x20:
                break
        dlat = ~(result >> 1) if (result & 1) else (result >> 1)
        lat += dlat

        result = 0
        shift = 0
        while True:
            b = ord(encoded[index]) - 63
            index += 1
            result |= (b & 0x1F) << shift
            shift += 5
            if b < 0x20:
                break
        dlng = ~(result >> 1) if (result & 1) else (result >> 1)
        lng += dlng

        points.append((lat / 1e5, lng / 1e5))
    return points


def _route_geometry(route: dict) -> list[dict]:
    """
    Road-following geometry by stitching per-step polylines.
    Falls back to overview_polyline when steps are missing.
    """
    merged: list[tuple[float, float]] = []
    for leg in route.get('legs') or []:
        for step in leg.get('steps') or []:
            for lat, lng in _decode_polyline(step.get('polyline') or ''):
                if not merged or merged[-1] != (lat, lng):
                    merged.append((lat, lng))
    if not merged:
        for lat, lng in _decode_polyline(
            (route.get('overview_polyline') or {}).get('points', ''),
        ):
            if not merged or merged[-1] != (lat, lng):
                merged.append((lat, lng))
    return [{'lat': lat, 'lng': lng} for lat, lng in merged]


def get_route(origin_lat, origin_lng, dest_lat, dest_lng, vehicle='motorcycle') -> dict | None:
    """
    Return {duration_seconds, duration_text, distance_meters, distance_text,
    polyline, geometry} for the best route, or None on failure.
    """
    if not _api_key_ok():
        return None
    try:
        resp = requests.get(
            _DIRECTION_URL,
            headers=_headers(),
            params={
                'type': vehicle,
                'origin': f'{origin_lat},{origin_lng}',
                'destination': f'{dest_lat},{dest_lng}',
            },
            timeout=_TIMEOUT,
        )
        body = resp.json()
        routes = body.get('routes') or []
        if not routes:
            logger.warning('Neshan returned no routes: %s', body)
            return None
        route = routes[0]
        leg = (route.get('legs') or [{}])[0]
        return {
            'duration_seconds': int(leg.get('duration', {}).get('value', 0)),
            'duration_text': leg.get('duration', {}).get('text', ''),
            'distance_meters': int(leg.get('distance', {}).get('value', 0)),
            'distance_text': leg.get('distance', {}).get('text', ''),
            'polyline': route.get('overview_polyline', {}).get('points', ''),
            'geometry': _route_geometry(route),
        }
    except Exception as exc:  # pragma: no cover - network dependent
        logger.warning('Neshan direction failed: %s', exc)
        return None


def get_distance_matrix(
    origin_lat, origin_lng, dest_lat, dest_lng, vehicle='motorcycle',
) -> dict | None:
    """
    Return {duration_seconds, duration_text, distance_meters, distance_text}
    for one origin→destination pair with live traffic, or None on failure.
    """
    if not _api_key_ok():
        return None
    try:
        resp = requests.get(
            _DISTANCE_MATRIX_URL,
            headers=_headers(),
            params={
                'type': vehicle,
                'origins': f'{origin_lat},{origin_lng}',
                'destinations': f'{dest_lat},{dest_lng}',
            },
            timeout=_TIMEOUT,
        )
        body = resp.json()
        rows = body.get('rows') or []
        if not rows:
            return None
        elements = (rows[0].get('elements') or [])
        if not elements or elements[0].get('status') != 'Ok':
            return None
        el = elements[0]
        return {
            'duration_seconds': int(el.get('duration', {}).get('value', 0)),
            'duration_text': el.get('duration', {}).get('text', ''),
            'distance_meters': int(el.get('distance', {}).get('value', 0)),
            'distance_text': el.get('distance', {}).get('text', ''),
        }
    except Exception as exc:  # pragma: no cover - network dependent
        logger.warning('Neshan distance matrix failed: %s', exc)
        return None


def _tile_center(z: int, x: int, y: int) -> tuple[float, float]:
    """Web-Mercator tile center for flutter_map XYZ coordinates."""
    n = 2 ** z
    lng = x / n * 360.0 - 180.0
    lat_rad = math.atan(math.sinh(math.pi * (1 - 2 * y / n)))
    lat = math.degrees(lat_rad)
    return lat, lng


def get_map_tile(z: int, x: int, y: int) -> bytes | None:
    """
    Fetch a 256×256 Neshan raster tile via the Static Map API.
    Native clients cannot call Neshan tile endpoints directly with a service key.
    """
    if not _api_key_ok() or not (0 <= z <= 19):
        return None
    lat, lng = _tile_center(z, x, y)
    try:
        resp = requests.get(
            _STATIC_TILE_URL,
            headers=_headers(),
            params={
                'style': 'light',
                'zoom': z,
                'width': _TILE_SIZE,
                'height': _TILE_SIZE,
                'latitude': lat,
                'longitude': lng,
            },
            timeout=_TIMEOUT,
        )
        if resp.status_code != 200:
            logger.warning(
                'Neshan tile failed z=%s x=%s y=%s: %s',
                z, x, y, resp.status_code,
            )
            return None
        return resp.content
    except Exception as exc:  # pragma: no cover - network dependent
        logger.warning('Neshan tile fetch failed: %s', exc)
        return None
