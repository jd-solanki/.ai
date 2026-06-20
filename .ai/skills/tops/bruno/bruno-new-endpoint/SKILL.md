---
name: bruno-new-endpoint
description: Create a new Bruno API endpoint file from API documentation
disable-model-invocation: true
---

# New Endpoint

Infer the target API and operation from the conversation context. If not clear, ask: "Which API and endpoint should I create a Bruno request for?"

1. Use context7 CLI to fetch API documentation — extract endpoint path, HTTP method, required headers, request body schema, and auth type.
2. Find existing Bruno request `.yml` files in the project and read a few to understand local conventions (variable naming, auth style, `seq` numbering).
3. Invoke the `/bruno` skill to create the `.yml` file. Include realistic placeholder values in the request body.
