MAX_LIMIT = 25


def clamp_limit(value, default: int = 10, maximum: int = MAX_LIMIT) -> int:
    try:
        limit = int(value)
    except (TypeError, ValueError):
        return default

    if limit < 1:
        return default
    return min(limit, maximum)
