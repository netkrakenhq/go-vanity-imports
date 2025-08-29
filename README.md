# Go Vanity Imports with Jekyll

This repository provides a **simple generator for Go vanity import paths**.

Point your domain, declare your modules, and let the tool generate the required
`go-import` and `go-source` meta tags - keeping your import paths clean while
your code stays hosted wherever you prefer (GitHub, GitLab, or any other VCS).

---

## Features

- serve Go vanity imports from any custom domain (via CNAME)
- configure all vanity paths centrally in `_data/vanity.yml`
- generate the required `go-import` and `go-source` automatically
- support multiple sources and per-path overrides via regex
- deploy with a simple GitHub Actions `deploy-pages.yaml` workflow
- avoid maintaining dozens of static HTML files manually

---

## Usage

Example: install a Go module

```bash
go get go.netkraken.com/tentacle@latest
```

In code:

```go
import "go.netkraken.com/tentacle"
```

Other modules can be declared in `_data/vanity.yml`, for example:

- Platform → `go.netkraken.com/platform`
- Atlas    → `go.netkraken.com/atlas`
- Tentacle → `go.netkraken.com/tentacle`

---

## How it works

- **Domain**: `go.netkraken.com` is configured with a CNAME pointing to GitHub Pages
- **Data source**: vanity paths and sources are declared in `_data/vanity.yml`
- **Generator**: a custom Jekyll plugin builds pages with the required meta tags
- **Deployment**: GitHub Actions builds the site with Jekyll and deploys it to GitHub Pages

---

## Development

Run locally:

```bash
bundle install
bundle exec jekyll serve --trace
```

Add a new module:

1. Edit `_data/vanity.yml` and add a new entry
2. Commit and push
   → the GitHub Actions workflow will rebuild and deploy automatically

---

## License

Licensed under the Apache License 2.0 (see [LICENSE](./LICENSE)).