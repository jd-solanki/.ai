# Bruno GraphQL Reference

## GraphQL request template

```yaml
info:
  name: Filter Products by SKUs
  type: graphql
  seq: 1

graphql:
  method: POST
  url: "{{baseUrl}}/shop-api"
  body:
    query: |-
      query GetProductsBySkus($skus: [String!]!) {
          customProductVariants(options: { filter: { sku: { in: $skus } } }) {
              items {
                  sku
                  featuredAsset {
                      preview
                  }
              }
          }
      }
    variables: |-
      {
          "skus": ["HAR326-4", "GPW-6"]
      }
  auth:
    type: bearer
    token: "{{apiToken}}"

settings:
  encodeUrl: true
  timeout: 0
  followRedirects: true
  maxRedirects: 5
```

## Key rules

- `info.type: graphql` — not `http`
- Top-level key is `graphql:` — not `http:`
- Body fields: `query:` for the query string, `variables:` for variables as a JSON string — never `data:` or `vars:`
- `variables:` must be a valid JSON string — use `|-` block scalar
- Auth goes under `graphql.auth` — same syntax as HTTP auth types
- `auth: inherit` works here too — inherits from collection or folder level
- No `body.type` needed — the `graphql:` key implies the body type
