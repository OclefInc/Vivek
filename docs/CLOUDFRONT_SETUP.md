# CloudFront Setup Guide for S3 Video Streaming

## Step-by-Step CloudFront Distribution Creation (Updated for Current AWS Console)

### Step 1: Access CloudFront Console
1. Log into AWS Console at https://console.aws.amazon.com
2. In the search bar at the top, type "CloudFront"
3. Click **CloudFront** (it shows "Content delivery network (CDN)")
4. You'll see the CloudFront Distributions page
5. Click the orange **Create distribution** button

---

### Step 2: Origin Section

You'll see a form with sections. Start at the top:

#### Origin domain
- Click in the empty field
- A dropdown will appear showing your S3 buckets
- Select: **thevivekproject.s3.us-west-1.amazonaws.com**
- (It will show in the dropdown list automatically)

#### Origin path - optional
- Leave this **BLANK**

#### Name
- Auto-fills to something like `thevivekproject.s3.us-west-1.amazonaws.com`
- Leave as-is or change if you want

#### Origin access
- You'll see radio buttons
- Select: **Origin access control settings (recommended)**
- A new dropdown appears: "Origin access control"
- Click **Create new OAC** (blue link on the right)

**In the popup:**
- Name: `thevivekproject-OAC` (or leave default)
- Description: (optional)
- Signing behavior: Keep **Sign requests (recommended)** selected
- Click **Create**

#### Origin shield
- Leave as: **No**

#### Additional settings (collapsed section)
- Don't expand, leave defaults

---

### Step 3: Default Cache Behavior Section

Scroll down to "Default cache behavior"

#### Path pattern
- Shows: `Default (*)`
- Leave as-is

#### Compress objects automatically
- Select: **Yes**

#### Viewer protocol policy
- Select: **Redirect HTTP to HTTPS**

#### Allowed HTTP methods
- Select: **GET, HEAD, OPTIONS**

#### Restrict viewer access
- Select: **No**

#### Cache key and origin requests

You'll see radio buttons:
- Select: **Cache policy and origin request policy (recommended)**

Two new dropdowns appear:

**Cache policy:**
- Click dropdown
- Select: **CachingOptimized**
- (We'll use this for now, custom policy is advanced)

**Origin request policy - optional:**
- Click dropdown
- Select: **CORS-S3Origin**

**Response headers policy - optional:**
- Click dropdown
- Select: **SimpleCORS** or **CORS-with-preflight-and-SecurityHeadersPolicy**

---

### Step 4: Function Associations - Optional
- Leave this section collapsed/empty

---

### Step 5: Settings Section

Scroll down to the "Settings" section

#### Price class
- Select: **Use all edge locations (best performance)**
- (Or select "Use only North America and Europe" to save costs)

#### AWS WAF web ACL - optional
- Leave as: **Do not enable security protections**

#### Alternate domain name (CNAME) - optional
- Leave **BLANK** for now
- (You can add a custom domain later)

#### Custom SSL certificate - optional
- Leave as: **Default CloudFront Certificate (*.cloudfront.net)**

#### Supported HTTP versions
- Keep checkboxes for: **HTTP/2** and **HTTP/3** ✅
- (Both should be checked)

#### Default root object - optional
- Leave **BLANK**

#### Standard logging
- Select: **Off**
- (Or turn On if you want access logs)

#### IPv6
- Select: **On** (recommended)

#### Description - optional
- Add something like: "Video streaming for Vivek Project"
- (Or leave blank)

---

### Step 6: Create!

Scroll to the bottom and click the orange **Create distribution** button

---

### Step 7: Wait for Deployment

You'll be redirected to the distribution details page.

- **Status** will show: "Deploying" with a spinning icon
- **Last modified** shows: "Deploying"
- ⏱️ **Wait 5-15 minutes** until status changes to "Enabled"
- You can refresh the page to check

---

### Step 8: Copy the S3 Bucket Policy

⚠️ **IMPORTANT:** After creation, you'll see an orange banner at the top:

> **"The S3 bucket policy needs to be updated"**
> The S3 bucket policy must allow CloudFront origin access to access your content...

1. Click **Copy policy** button in the banner
2. Open a new tab: AWS S3 Console
3. Go to your bucket: **thevivekproject**
4. Click the **Permissions** tab
5. Scroll to **Bucket policy** section
6. Click **Edit** button
7. **Paste** the copied policy (replacing any existing policy)
8. Click **Save changes**

The policy should look like:
```json
{
  "Version": "2008-10-17",
  "Id": "PolicyForCloudFrontPrivateContent",
  "Statement": [
    {
      "Sid": "AllowCloudFrontServicePrincipal",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudfront.amazonaws.com"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::thevivekproject/*",
      "Condition": {
        "StringEquals": {
          "AWS:SourceArn": "arn:aws:cloudfront::YOUR_ACCOUNT:distribution/YOUR_DIST_ID"
        }
      }
    }
  ]
}
```

---

### Step 9: Get Your CloudFront Domain

Back in CloudFront console:

1. Look at your distribution details
2. Find **Distribution domain name**: something like `d1234abcd5678.cloudfront.net`
3. **Copy this domain** - you'll need it for Rails configuration

---

### Step 10: Test It Works

1. Take your CloudFront domain: `d1234abcd5678.cloudfront.net`
2. Get a video key from S3 (example: `abc123xyz/video.mp4`)
3. Build test URL: `https://d1234abcd5678.cloudfront.net/abc123xyz/video.mp4`
4. Open in browser - video should play
5. If you get Access Denied, recheck Step 8 (bucket policy)

---

### Step 11: Configure Rails to Use CloudFront---

### Step 11: Configure Rails to Use CloudFront

Now tell Rails to use CloudFront instead of direct S3 URLs.

#### Option A: Environment Variable (Recommended)

1. Add to your `.env` file:
```bash
CLOUDFRONT_DOMAIN=d1234abcd5678.cloudfront.net
```
(Replace with your actual CloudFront domain from Step 9)

2. Create file: `config/initializers/active_storage_cloudfront.rb`
```ruby
# Use CloudFront for Active Storage URLs
if ENV['CLOUDFRONT_DOMAIN'].present?
  Rails.application.config.to_prepare do
    ActiveStorage::Blob.class_eval do
      def url(expires_in: ActiveStorage.service_urls_expire_in, disposition: :attachment, **options)
        # Use CloudFront domain instead of S3
        "https://#{ENV['CLOUDFRONT_DOMAIN']}/#{key}"
      end
    end
  end
end
```

3. Restart your Rails server: `touch tmp/restart.txt`

#### Option B: Update storage.yml (Alternative)

Edit `config/storage.yml` - add the `public` option:
```yaml
amazon:
  service: S3
  access_key_id: <%= ENV['AWS_ACCESS_KEY_ID'] %>
  secret_access_key: <%= ENV['AWS_SECRET_KEY'] %>
  region: us-west-1
  bucket: thevivekproject
  public: true  # Add this line
```

Then you still need the initializer from Option A.

---

### Step 12: Verify Everything Works

1. Restart Rails: `touch tmp/restart.txt` or `bin/dev`
2. Open your app in browser
3. Go to a lesson with a video
4. **Right-click the video** → **Inspect Element**
5. Look at the `<video src=` URL
6. Should see: `https://d1234abcd5678.cloudfront.net/...` (not `s3.amazonaws.com`)
7. Try scrubbing the video - should be instant!

---

### Step 13: Verify Scrubbing Works

1. Play a video
2. Open **Chrome DevTools** (F12)
3. Go to **Network** tab
4. Scrub to the middle of the video
5. Look for video requests
6. Check the **Status** column: should show **206** (Partial Content)
7. Check **Response Headers**: should see `X-Cache: Hit from cloudfront`

✅ If you see 206 status = scrubbing is working perfectly!
❌ If you see 200 status = something is wrong with Range headers

---

## Benefits You'll Get

✅ **Faster loading** - Videos served from edge locations near users
✅ **Better scrubbing** - CloudFront properly handles Range requests
✅ **Lower costs** - S3 data transfer is expensive, CloudFront is cheaper
✅ **Higher limits** - CloudFront has higher bandwidth limits than S3
✅ **Better caching** - Videos cached at edge locations
✅ **HTTP/2 & HTTP/3** - Modern protocols for better performance

## Cost Estimate

CloudFront pricing (approximate):
- First 10 TB/month: $0.085/GB
- Data transfer OUT: Usually cheaper than S3 direct
- Requests: $0.0075 per 10,000 HTTPS requests

For 100GB video streaming/month: ~$8.50 vs ~$9.00 from S3 direct

## Troubleshooting

**Videos not loading:**
- Check S3 bucket policy was updated with CloudFront policy
- Verify distribution status is "Enabled"
- Check CORS is still configured on S3 bucket

**Scrubbing still slow:**
- Verify `Range` header is being sent (check Network tab)
- Check CloudFront cache policy includes Range header
- Ensure videos are encoded with `-movflags +faststart`

**Old content showing:**
- Create CloudFront invalidation: `/path/to/video.mp4`
- Or wait for TTL to expire (default 24 hours)
