---
name: bruno
description: Create and manage Bruno API collections using OpenCollection YAML format. Use when adding new API requests to a Bruno collection, creating environments, writing pre/post scripts, or scaffolding a new collection. Triggers on: "add Bruno request", "create Bruno collection", "write a .yml for Bruno", "OpenCollection YAML", "bruno request".
---

# Bruno

## Quick start — fetch docs first

Use **WebFetch** directly (context7 does not index Bruno docs):

| Topic | URL |
|---|---|
| Structure reference | `https://docs.usebruno.com/opencollection-yaml/structure-reference.md` |
| Samples | `https://docs.usebruno.com/opencollection-yaml/samples.md` |
| Variables | `https://docs.usebruno.com/variables/overview.md` |
| Auth | `https://docs.usebruno.com/auth/overview.md` |
| JS API reference | `https://docs.usebruno.com/testing/script/javascript-reference.md` |
| Secrets / .env | `https://docs.usebruno.com/secrets-management/dotenv-file` |
| Full doc index | `https://docs.usebruno.com/llms.txt` |

Read existing requests before writing new ones: `find api/<service> -name "*.yml" | head -10`

## Project layout

```
api/
└── <service>/
    ├── opencollection.yml
    ├── .env.example                 # var names only, no values
    ├── environments/<env>.yml
    └── <resource>/<verb>-<noun>.yml
```

**`opencollection.yml`:**
```yaml
opencollection: 1.0.0
info:
  name: <service-name>
bundled: false
extensions:
  bruno:
    ignore: [node_modules, .git, .env]
```

## Request templates

**GET with path param** (see [AUTH.md](AUTH.md) for auth options):
```yaml
info:
  name: Get Deal by ID
  type: http
  seq: 1

http:
  method: GET
  url: "{{baseUrl}}/crm/v3/objects/deals/:dealId"
  params:
    - name: dealId
      value: "60074085675"
      type: path
  auth:
    type: bearer
    token: "{{hubspotToken}}"

settings:
  encodeUrl: true
  timeout: 0
  followRedirects: true
  maxRedirects: 3
```

**POST with JSON body + runtime script** (token request pattern):
```yaml
info:
  name: Get Token
  type: http
  seq: 1

http:
  method: POST
  url: "{{baseUrl}}/api/oauth/v1/token"
  headers:
    - name: Content-Type
      value: application/json
  auth:
    type: basic
    username: "{{clientId}}"
    password: "{{clientSecret}}"
  body:
    type: json
    data: |-
      {
          "grant_type": "password",
          "username": "{{akeneoUsername}}",
          "password": "{{akeneoPassword}}"
      }

runtime:
  scripts:
    - type: after-response
      code: |-
        bru.setVar("ACCESS_TOKEN", res.body.access_token);
    - type: tests
      code: |-
        test("token present", () => expect(res.body.access_token).to.not.be.null);

settings:
  encodeUrl: true
  timeout: 0
  followRedirects: true
  maxRedirects: 3
```

→ GraphQL requests: see [GRAPHQL.md](GRAPHQL.md)
→ All auth types: see [AUTH.md](AUTH.md)
→ Variable types & when to use: see [VARIABLES.md](VARIABLES.md)

## Body types

Always `body.type` + `body.data`. Never `body.mode`, never `body.json`.

| Use case | `body.type` | `body.data` shape |
|---|---|---|
| JSON payload | `json` | JSON string (`\|-`) |
| URL-encoded form | `form-urlencoded` | array of `{name, value}` |
| File upload | `multipart-form` | array of `{name, value}` or `{name, value, type: file}` |
| Plain text | `text` | raw string |
| XML | `xml` | XML string (`\|-`) |

**Multipart example:**
```yaml
body:
  type: multipart-form
  data:
    - name: product
      value: '{"identifier": "LR116-PR", "attribute": "Main_Image", "scope": null, "locale": null}'
    - name: file
      value: /path/to/image.jpeg
      type: file
```

## Key rules

- **`enabled: true` is the default — omit it**
- Scripts: `runtime.scripts[]` with `type: before-request | after-response | tests` — never `script:` (that is the legacy `.bru` format)
- Cross-request tokens: `bru.setVar("TOKEN", res.body.token)` in `after-response`. Do NOT put them in the environment file.
- Basic auth + JSON body: Bruno omits `Content-Type` automatically — add it explicitly as a header
- Auth per-request under `http.auth` — not at collection level
- File names: `<verb>-<noun>.yml` in kebab-case; `seq` = next number in the folder
