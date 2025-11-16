from app import cache, logger
from typing import Optional
import time
import re

def upload(key: str, url: str) -> Optional[str]:
	cachedValue = cache.get(key)
	if cachedValue:
		logger.debug(f"Using cached poster URL: {cachedValue}")
		return cachedValue
	
	try:
		if not url:
			logger.debug("No URL provided, skipping poster")
			return None
		
		if url.startswith('https://plex.temidara.rocks'):
			logger.debug(f"Using public Plex URL for poster: {url}")
			cache.set(key, url, int(time.time()) + (72 * 60 * 60))
			return url
		
		if url.startswith('http://') or url.startswith('https://'):
			match = re.search(r'https?://[^/]+(/.+)', url)
			if match:
				path = match.group(1)
				public_url = f"https://plex.temidara.rocks{path}"
				logger.info(f"Converted Plex URL: {url[:80]}... -> {public_url[:80]}...")
				cache.set(key, public_url, int(time.time()) + (72 * 60 * 60))
				return public_url
		
		logger.warning(f"Could not parse URL: {url}")
		return None
		
	except Exception as e:
		logger.error(f"Failed to process image URL: {e}")
		return None
