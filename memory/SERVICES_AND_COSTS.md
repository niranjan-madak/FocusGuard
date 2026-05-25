# SERVICES_AND_COSTS — FocusGuard

## Services Overview

FocusGuard uses **zero external services**. The application is fully self-contained and offline-capable.

**Total Monthly Cost:** $0  
**Total Annual Cost:** $0  

---

## Service Categories

### Hosting & Deployment

**Current Solution:** None (desktop app)  
**Cost:** $0  

**Rationale:** Desktop application distributed via direct download. No hosting required.

---

### Database

**Current Solution:** None (in-memory state)  
**Cost:** $0  

**Rationale:** Timer state is stored in memory. No persistence required for current feature set.

---

### Authentication

**Current Solution:** None (no user accounts)  
**Cost:** $0  

**Rationale:** Single-user desktop application with no multi-user features.

---

### File Storage

**Current Solution:** Local assets bundled with app  
**Cost:** $0  

**Rationale:** Icons and assets are bundled in the application. No cloud storage needed.

---

### Email

**Current Solution:** None  
**Cost:** $0  

**Rationale:** No email features (no notifications, no user accounts).

---

### Monitoring & Observability

**Current Solution:** None  
**Cost:** $0  

**Rationale:** No telemetry or analytics currently implemented.

---

### Analytics

**Current Solution:** None  
**Cost:** $0  

**Rationale:** No user tracking or analytics. Privacy-focused design.

---

### CI/CD

**Current Solution:** Manual builds  
**Cost:** $0  

**Rationale:** Builds are run manually by developer. No automated pipeline.

---

### Fonts

**Current Solution:** `google_fonts` Flutter package (bundled via pub.dev — no CDN at runtime)  
**Cost:** $0  

**Rationale:** Fonts are compiled into the app at build time. Zero network dependency at runtime.

---

## Free Services Reference

### Services Currently Used

None. FocusGuard is fully self-contained with zero external service calls at runtime.

---

### Services Not Used (But Available)

#### Hosting & Deployment — Frontend

| Service | Free Tier | Limits | Best For |
|---------|-----------|--------|----------|
| Vercel | 100GB bandwidth, unlimited deploys | 1 member on free | Next.js / React apps |
| Netlify | 100GB bandwidth, 300 build min/month | 1 member, limited build minutes | Static + serverless |
| Cloudflare Pages | Unlimited bandwidth, unlimited sites | 500 builds/month | Static + edge |
| GitHub Pages | Static sites, custom domain, 1GB size | Static only | Docs, portfolios |

**Not Applicable:** FocusGuard is a desktop app, not a web app.

---

#### Hosting & Deployment — Backend

| Service | Free Tier | Limits | Best For |
|---------|-----------|--------|----------|
| Railway | $5 credit/month, 512MB RAM | Limited compute | Small APIs |
| Render | 750 hours/month web services | Sleeps after 15min inactivity | Hobby projects |
| Fly.io | 3 shared-cpu VMs, 256MB RAM each | Limited resources | Containerized apps |
| Koyeb | 2 services, 512MB RAM, global edge | No sleep on free tier | Always-on free APIs |
| Deno Deploy | 100k req/day, edge functions, KV store | Daily request limit | Deno / edge apps |

**Not Applicable:** FocusGuard has no backend.

---

#### Database

| Service | Free Tier | Limits | Best For |
|---------|-----------|--------|----------|
| Supabase | 500MB PostgreSQL, 50MB storage, Auth included | Pauses after 1 week inactivity | Full-stack apps |
| Neon | 0.5GB PostgreSQL, serverless, branching | Auto-suspend when inactive | Dev environments |
| PlanetScale | 5GB MySQL, 1B row reads/month | Verify current free tier | MySQL workloads |
| Turso | 500 DBs, 9GB total, 1B row reads/month | Per-database limits | Low-latency reads |
| MongoDB Atlas | 512MB shared cluster (M0), no expiry | Limited storage | Document model |
| Firebase Firestore | 1GB storage, 50k reads/day, 20k writes/day | Daily operation limits | Real-time apps |
| Redis (Upstash) | 10k commands/day, 256MB, global | Daily command limit | Cache, sessions |

**Not Applicable:** FocusGuard uses in-memory state.

---

#### Authentication

| Service | Free Tier | Limits | Best For |
|---------|-----------|--------|----------|
| Supabase Auth | Unlimited users, OAuth, magic links, MFA | Included with Supabase free | Full-stack apps |
| Clerk | 10k monthly active users, OAuth, MFA | MAU limit | Next.js / React |
| Auth.js (NextAuth) | Open source, self-hosted, no limits | Requires self-hosting | Full control |
| Firebase Auth | Unlimited users, phone/email/OAuth | None on free tier | Mobile + web |
| Keycloak | Open source, self-hosted, enterprise features | Requires self-hosting | Enterprise, B2B |

**Not Applicable:** FocusGuard has no authentication.

---

#### File Storage

| Service | Free Tier | Limits | Best For |
|---------|-----------|--------|----------|
| Cloudflare R2 | 10GB storage, unlimited egress | 1M write ops/month | Public downloads |
| Supabase Storage | 1GB storage, 2GB bandwidth | Storage/bandwidth limit | App file uploads |
| Backblaze B2 | 10GB storage, 1GB/day download | Daily download limit | Cheap long-term storage |
| GitHub Releases | Unlimited for public repos | No size limit per release | Software installers |

**Not Applicable:** FocusGuard bundles assets locally.

---

#### Email (Transactional)

| Service | Free Tier | Limits | Best For |
|---------|-----------|--------|----------|
| Resend | 3,000 emails/month, 1 domain | Monthly send limit | Modern apps |
| Brevo (Sendinblue) | 300 emails/day, unlimited contacts | Daily send limit | Transactional + marketing |
| Nodemailer | Open source, self-configured SMTP | Requires SMTP server | Full control |

**Not Applicable:** FocusGuard has no email features.

---

#### Monitoring & Observability

| Service | Free Tier | Limits | Best For |
|---------|-----------|--------|----------|
| Grafana Cloud | 14-day retention, 10k metrics/month, 50GB logs | Metric/log limits | Full observability |
| UptimeRobot | 50 monitors, 5-minute checks, email alerts | Monitor count limit | Uptime monitoring |
| Sentry | 5k errors/month, 1 user, replays | Monthly error limit | Error tracking |
| Highlight.io | 500 sessions/month, open source self-hostable | Session limit | Session replay |
| OpenTelemetry | Open source standard, self-hosted | Requires self-hosting | Custom observability |

**Not Applicable:** FocusGuard has no monitoring.

---

#### Analytics

| Service | Free Tier | Limits | Best For |
|---------|-----------|--------|----------|
| Plausible (self-hosted) | Open source, no limits | Requires server | GDPR-compliant |
| Umami | Open source, self-hosted | Requires server | Privacy-first |
| PostHog | 1M events/month, feature flags, session replay, A/B | Monthly event limit | Product analytics |
| Google Analytics 4 | Unlimited, free | GDPR compliance needed | General analytics |

**Not Applicable:** FocusGuard has no analytics (privacy-focused).

---

#### CI/CD

| Service | Free Tier | Limits | Best For |
|---------|-----------|--------|----------|
| GitHub Actions | Unlimited public, 2k min/month private | Build minutes | GitHub repos |
| GitLab CI/CD | 400 min/month, built-in registry | Build minutes | GitLab repos |
| Jenkins | Open source, self-hosted, unlimited | Requires self-hosting | Full control |

**Not Applicable:** FocusGuard uses manual builds (could add GitHub Actions in future).

---

## Cost Optimization

### Current Strategy

**Philosophy:** Zero external services, maximum privacy, minimal cost.

**Benefits:**
- $0 monthly cost
- No vendor lock-in
- No data sharing with third parties
- No service dependency risks
- Simple deployment

**Trade-offs:**
- No analytics/telemetry
- No automatic updates
- Manual release process
- No crash reporting

---

### Future Service Considerations

### If Adding Analytics

**Recommendation:** Self-hosted Plausible or Umami

**Cost:** Server hosting (~$5/month) or free if self-hosted on existing infrastructure

**Rationale:** Privacy-focused, GDPR-compliant, open source

---

### If Adding Auto-Updates

**Recommendation:** GitHub Releases (free)

**Cost:** $0

**Rationale:** Free, integrated with git, no additional services needed

---

### If Adding Crash Reporting

**Recommendation:** Sentry (free tier) or self-hosted Sentry

**Cost:** $0 (free tier) or server hosting (~$5/month)

**Rationale:** Industry standard, good free tier, self-hostable

---

### If Adding CI/CD

**Recommendation:** GitHub Actions

**Cost:** $0 (public repo) or 2k min/month (private repo)

**Rationale:** Integrated with GitHub, generous free tier, easy setup

---

## Service Selection Questionnaire

### Current Answers

**1. Preference for third-party services?**
- ✅ Free only — open source or free tiers exclusively

**2. Comfortable self-hosting open source tools?**
- ✅ Yes — we have DevOps capacity (or not needed)

**3. Maximum monthly spend on third-party services at launch?**
- ✅ $0 — entirely free

---

## Service Recommendation Format

### For Any Future Service Needs

**When recommending any service, always use:**

**FREE OPTIONS:**
┌───────────────┬────────────────┬───────────────┬────────────────┐
│ Service       │ Free Tier      │ Hard Limit    │ When to Upgrade│
└───────────────┴────────────────┴───────────────┴────────────────┘

**PAID OPTIONS (if free is insufficient):**
┌───────────────┬────────────────┬───────────────┬────────────────┐
│ Service       │ Starting Price │ What you get  │ Best for       │
└───────────────┴────────────────┴───────────────┴────────────────┘

**MY RECOMMENDATION:** [specific pick with reason]

**TOTAL ESTIMATED MONTHLY COST:** [free / $X/month]

---

## Summary

**Current Services:** 0 (fully offline — zero external runtime dependencies)  
**Current Monthly Cost:** $0  
**Current Annual Cost:** $0  

**Service Philosophy:** Zero external services, maximum privacy, minimal cost. All functionality is self-contained. Fonts are bundled via the `google_fonts` Flutter package (no CDN at runtime).

**Future Considerations:**
- Could add GitHub Actions for CI/CD ($0)
- Could add self-hosted analytics (~$5/month if server needed)
- Could add Sentry for crash reporting ($0 free tier)

**Recommendation:** Continue with zero-service approach. Add services only if absolutely necessary for user value, and always prefer free/open-source options.
