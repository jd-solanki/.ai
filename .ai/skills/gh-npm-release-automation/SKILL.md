---
name: gh-npm-release-automation
description: Guidance for automating npm package releases via GitHub Actions — versioning, npm publish with provenance, and GitHub release changelog generation. Use when setting up or modifying npm publish workflows, release pipelines, version bumping, or GitHub release automation.
---

# GitHub + npm Release Automation

## First publish (manual)

npm requires the first publish to be done manually to establish the package name and ownership. After that, all future releases are automated via GitHub Actions.

```bash
npm publish --access public
```

## Automated releases via GitHub Actions

Once the package exists on npm, pushing a `v*` tag from your machine triggers the full release pipeline automatically:

```
pnpm release        # bumps version, commits, tags & pushes
      ↓
GitHub Actions workflow triggers on v* tag
      ↓
tests → build → npm publish → GitHub release with changelog
```

### 1. Version bump with bumpp

[`bumpp`](https://github.com/antfu/bumpp) bumps `package.json`, commits, tags, and pushes in one step:

```json
// package.json
"scripts": {
  "release": "bumpp"
},
```

Run `pnpm release` and pick the version increment interactively.

### 2. GitHub Actions workflow

Trigger on `v*` tags pushed by `bumpp`:

```yaml
on:
  push:
    tags:
      - 'v*'

permissions:
  contents: write   # required for creating GitHub releases
  id-token: write   # required for npm provenance
```

### 3. npm provenance

npm provenance uses GitHub's OIDC token to cryptographically attest that a package was built from a specific repo, commit, and workflow run. It adds a verified provenance badge on the npm package page.

```yaml
- uses: actions/setup-node@v6
  with:
    registry-url: https://registry.npmjs.org  # required — writes .npmrc for auth

- run: npm publish --provenance --access public
  env:
    NODE_AUTH_TOKEN: ${{secrets.NPM_TOKEN}}
```

`setup-node` with `registry-url` auto-configures `.npmrc` to read `NODE_AUTH_TOKEN`. Without `registry-url`, the env var has nothing to hook into and publish fails unauthenticated.

### 4. Changelog automation via changelogithub

[`changelogithub`](https://github.com/antfu/changelogithub) reads Conventional Commits between tags and creates (or updates) a GitHub release with a formatted changelog. Run it as the **last step** — after `npm publish` — so a failed publish doesn't create a dangling GitHub release:

```yaml
- uses: actions/checkout@v6
  with:
    fetch-depth: 0  # full tag history required; shallow clone produces empty changelog

- name: Generate changelog
  run: npx changelogithub
  env:
    GITHUB_TOKEN: ${{secrets.GITHUB_TOKEN}}
```

`contents: write` permission (see above) is required for creating GitHub releases — the default `contents: read` is not enough.

**Conventional Commits matter** — `changelogithub` groups entries by type (`feat`, `fix`, `chore`, etc.) and surfaces breaking changes (`feat!:` / `chore!:`) at the top. Commits that don't follow the convention are omitted from the changelog.

Preview before pushing a tag:

```bash
npx changelogithub --dry
```

## Reference

- [EXAMPLE_WORKFLOW.yml](EXAMPLE_WORKFLOW.yml) — complete pnpm-based publish workflow with provenance, tests, and changelog generation
