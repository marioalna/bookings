# 11 - Deployment

## Docker

### Multi-stage Dockerfile

**File:** `Dockerfile`

The Dockerfile uses a 3-stage build:

```
Stage 1: base
  - Ruby 3.3.6-slim
  - System packages: curl, libjemalloc2, libvips, sqlite3
  - Sets RAILS_ENV=production, BUNDLE_DEPLOYMENT=1

Stage 2: build (thrown away)
  - Adds build tools: build-essential, git, pkg-config
  - Installs gems via bundler
  - Precompiles bootsnap (faster boot times)
  - Precompiles assets (Propshaft + Tailwind)
  - Uses SECRET_KEY_BASE_DUMMY=1 for asset precompilation

Stage 3: final
  - Copies gems and app from build stage
  - Creates non-root rails user (UID 1000)
  - Exposes port 80
  - Entrypoint: /rails/bin/docker-entrypoint
  - CMD: ./bin/thrust ./bin/rails server
```

### Key Details

- **jemalloc2** is installed for memory allocation optimization
- **libvips** is used for image processing (Active Storage)
- **Thruster** (`./bin/thrust`) wraps the Rails server to add HTTP asset caching, compression, and X-Sendfile acceleration
- The entrypoint script prepares the database on first run

### Building

```bash
docker build -t sociedad .
docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value> --name sociedad sociedad
```

## Kamal

### Configuration

Kamal deployment is configured via the `kamal` gem (included in Gemfile). The `.kamal/` directory contains hook samples:

```
.kamal/
  hooks/
    docker-setup.sample
    post-deploy.sample
    post-proxy-reboot.sample
    pre-build.sample
    pre-connect.sample
    pre-deploy.sample
    pre-proxy-reboot.sample
  secrets
```

**Note:** No `config/deploy.yml` was found in the repository. The Kamal configuration may be managed elsewhere or needs to be created. The hook samples are the standard Kamal templates.

### `.kamal/secrets`

Contains environment-specific secrets (not committed to version control).

## SQLite in Production

This application uses SQLite for all environments (development, test, and production). Rails 8 introduced solid adapters that replace Redis:

| Service | Adapter | Purpose |
|---------|---------|---------|
| Cache | `solid_cache` | Application caching (replaces Redis) |
| Jobs | `solid_queue` | Background job processing (replaces Redis/Sidekiq) |
| WebSockets | `solid_cable` | Action Cable (replaces Redis) |

All three use SQLite databases, keeping the infrastructure simple with no external dependencies beyond the filesystem.

### Considerations

- SQLite writes are serialized (single writer), which limits write throughput
- The database file must be on persistent storage (not ephemeral container filesystem)
- Backups are simple file copies of the `.sqlite3` files

## Assets

### Pipeline

```
Propshaft (asset pipeline)
  + Tailwind CSS v4 (via tailwindcss-rails gem)
  + Importmap (JS modules)
  + Active Storage (file uploads)
```

### Tailwind CSS

Using `tailwindcss-rails` gem (v4.1.0) with `tailwindcss-ruby` (v4.0.9). Tailwind is compiled at build time and watched in development via `bin/dev` (Foreman).

### Importmap

No JS bundler is used. All JavaScript is served as ES modules via importmap. The only external JS dependency is `@rails/request.js` for making fetch requests with Rails CSRF tokens.

### Image Processing

Uses `image_processing` gem with `libvips` backend for Active Storage variants (e.g., resizing resource photos).

## Web Server

### Puma

Puma is the application server (standard Rails default, >= 6.0).

### Thruster

Thruster is a lightweight HTTP proxy from Basecamp that sits in front of Puma to add:
- HTTP asset caching with appropriate cache headers
- Gzip/Brotli compression
- X-Sendfile acceleration for file downloads

The CMD in the Dockerfile runs: `./bin/thrust ./bin/rails server`
