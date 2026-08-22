const VIDEO_ID_PATTERN = /(?:youtu\.be\/|v=|embed\/)([a-zA-Z0-9_-]{11})/;

export function extractYoutubeVideoId(url: string): string | null {
  const match = url.match(VIDEO_ID_PATTERN);
  return match?.[1] ?? null;
}

/** Official YouTube CDN thumbnail for a video URL or ID. */
export function youtubeThumbnail(
  urlOrId: string,
  quality: "maxresdefault" | "hqdefault" | "mqdefault" = "hqdefault",
): string {
  const id = urlOrId.length === 11 ? urlOrId : extractYoutubeVideoId(urlOrId);
  if (!id) {
    return "";
  }
  return `https://img.youtube.com/vi/${id}/${quality}.jpg`;
}

export function youtubeWatchUrl(videoId: string): string {
  return `https://www.youtube.com/watch?v=${videoId}`;
}
