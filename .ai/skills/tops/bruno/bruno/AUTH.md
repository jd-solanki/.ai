# Bruno Auth Reference

## How secrets flow: .env → environment → request

**Step 1 — `.env`** (gitignored, never committed):
```
HUBSPOT_TOKEN=pat-xxx-yyy
AKENEO_CLIENT_ID=abc123
AKENEO_CLIENT_SECRET=s3cr3t
AKENEO_USERNAME=ddi_user
AKENEO_PASSWORD=p@ssword
```

**Step 2 — `environments/<env>.yml`** — map process env to Bruno variables:
```yaml
name: prod

variables:
  - name: baseUrl
    value: https://api.example.com
    type: text
  - name: apiToken
    value: "{{process.env.HUBSPOT_TOKEN}}"
    type: text
    secret: true
  - name: clientId
    value: "{{process.env.AKENEO_CLIENT_ID}}"
    type: text
    secret: true
  - name: clientSecret
    value: "{{process.env.AKENEO_CLIENT_SECRET}}"
    type: text
    secret: true
```
> `secret: true` masks the value in Bruno UI — shows as blank. The value still works in requests. This is expected, not a bug.

**Step 3 — individual request** — reference the variable:
```yaml
auth:
  type: bearer
  token: "{{apiToken}}"
```

---

## Auth types

### Bearer Token
```yaml
auth:
  type: bearer
  token: "{{apiToken}}"
```

### Basic Auth
```yaml
auth:
  type: basic
  username: "{{clientId}}"
  password: "{{clientSecret}}"
```
> **Important:** Bruno does not auto-inject `Content-Type` when basic auth is combined with a JSON body. Add it explicitly:
```yaml
headers:
  - name: Content-Type
    value: application/json
```

### API Key
```yaml
auth:
  type: apikey
  key: X-API-Key
  value: "{{apiKey}}"
  placement: header   # or: query
```

### Inherit (from collection or folder level)
```yaml
auth:
  type: inherit
```

### No auth
Omit the `auth` key entirely.

### OAuth 2.0, AWS Signature v4, Digest, NTLM
Configured via Bruno UI. Fetch `https://docs.usebruno.com/auth/overview.md` for current YAML keys.

---

## Getting a token and sharing it across requests

Use `bru.setVar` in an `after-response` script — sets a session-wide runtime variable available in all subsequent requests via `{{ACCESS_TOKEN}}`:

```yaml
runtime:
  scripts:
    - type: after-response
      code: |-
        bru.setVar("ACCESS_TOKEN", res.body.access_token);
    - type: tests
      code: |-
        test("token present", () => expect(res.body.access_token).to.not.be.null);
```

Then in any other request:
```yaml
auth:
  type: bearer
  token: "{{ACCESS_TOKEN}}"
```

> Do NOT add `ACCESS_TOKEN` to `environments/<env>.yml`. If it references `{{process.env.*}}`, `bru.setVar` cannot override it and the token will never update.
