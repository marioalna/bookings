# Sociedad (BookingsApp) - Technical Documentation

## How to Use This Documentation

This documentation provides a comprehensive technical reference for the Sociedad application. Each guide covers a specific aspect of the system. Read them in order for a full understanding, or jump to a specific guide as needed.

## Table of Contents

| # | Guide | Description |
|---|-------|-------------|
| 01 | [Overview](01-overview.md) | Business context, tech stack, design decisions, and dev commands |
| 02 | [Architecture](02-architecture.md) | Layers, multi-tenancy, request flow, and Turbo Streams |
| 03 | [Data Model](03-data-model.md) | Schema, relationships, validations, and constants |
| 04 | [Authentication & Authorization](04-authentication-and-authorization.md) | Login, sessions, password reset, and roles |
| 05 | [Service Layer](05-service-layer.md) | The 7 service classes in `app/middleware/bookings/` |
| 06 | [Controllers](06-controllers.md) | Each controller, actions, and duplication analysis |
| 07 | [Frontend](07-frontend.md) | Stimulus controllers, Turbo, and interaction flows |
| 08 | [Views & Components](08-views-and-components.md) | Layouts, TailwindFormBuilder, helpers, and ViewComponent |
| 09 | [Internationalization](09-internationalization.md) | i18n configuration, key structure, and known issues |
| 10 | [Testing](10-testing.md) | Test structure, fixtures, helpers, and coverage gaps |
| 11 | [Deployment](11-deployment.md) | Docker, Kamal, SQLite in production |
| 12 | [Bugs & Tech Debt](12-bugs-and-tech-debt.md) | 15 identified issues with severity and proposed fixes |
| 13 | [Guide for AI Agents](13-guide-for-ai-agents.md) | Quick reference for AI agents working on this codebase |

## Key Entry Points

- **New to the project?** Start with [01-overview.md](01-overview.md)
- **Need to understand data flow?** Read [02-architecture.md](02-architecture.md) and [05-service-layer.md](05-service-layer.md)
- **Working on a bug?** Check [12-bugs-and-tech-debt.md](12-bugs-and-tech-debt.md) first
- **AI agent?** Go directly to [13-guide-for-ai-agents.md](13-guide-for-ai-agents.md)
