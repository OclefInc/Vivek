# S3 Configuration for Better Video Scrubbing

## Required S3 Settings

For optimal video scrubbing performance with S3-hosted videos, configure your bucket with these settings:

### 1. CORS Configuration

Add this CORS policy to your S3 bucket (in AWS Console → S3 → Your Bucket → Permissions → CORS):

```json
[
  {
    "AllowedHeaders": [
      "*"
    ],
    "AllowedMethods": [
      "GET",
      "HEAD"
    ],
    "AllowedOrigins": [
      "*"
    ],
    "ExposeHeaders": [
      "Content-Range",
      "Content-Length",
      "Content-Type",
      "Accept-Ranges",
      "ETag"
    ],
    "MaxAgeSeconds": 3000
  }
]
```

### 2. CloudFront (Optional but Recommended)

For even better performance, use CloudFront CDN:

1. Create a CloudFront distribution pointing to your S3 bucket
2. Enable "Cache Based on Selected Request Headers" → "Whitelist"
3. Add these headers:
   - Range
   - Origin
   - Access-Control-Request-Method
   - Access-Control-Request-Headers

4. Update storage.yml to use CloudFront URL:
```yaml
amazon:
  service: S3
  access_key_id: <%= ENV['AWS_ACCESS_KEY_ID'] %>
  secret_access_key: <%= ENV['AWS_SECRET_KEY'] %>
  region: us-west-1
  bucket: thevivekproject
  # Add CloudFront domain:
  # public_url: https://your-distribution.cloudfront.net
```

### 3. Video Encoding Best Practices

For best scrubbing performance, ensure videos are:

- **Encoded with MP4 (H.264)** - Best browser support
- **Progressive download enabled** - moov atom at beginning of file
- **Reasonable bitrate** - 2-5 Mbps for 720p, 5-8 Mbps for 1080p

Use this ffmpeg command to optimize:
```bash
ffmpeg -i input.mp4 -c:v libx264 -preset slow -crf 22 \
  -movflags +faststart -c:a aac -b:a 128k output.mp4
```

The `-movflags +faststart` is crucial - it moves metadata to the beginning for instant seeking.

### What These Changes Do:

1. **CORS Headers** - Allow browser to make byte-range requests
2. **Accept-Ranges Header** - Tells browser video supports seeking
3. **Content-Range** - Returns specific byte ranges when scrubbing
4. **preload="metadata"** - Loads video duration/metadata immediately
5. **Longer URL expiration** - Prevents re-authentication during playback
6. **faststart encoding** - Enables instant seeking without downloading entire file

### Testing Scrubbing

After configuration, test that scrubbing works by:
1. Load a video
2. Immediately try scrubbing to middle/end
3. Check Network tab for "206 Partial Content" responses
4. Verify no full file downloads when seeking
