# PSG CRM — Cloudflare deployment

Same pattern as `psg-planner` (production planning): `public/index.html` is the whole
CRM — frontend + a browser-side Supabase client — deployed as a Cloudflare Worker
serving static assets. No Node server to keep running.

It's wired to the **same Supabase project as psg-planner** by default (see `SB_URL`/
`SB_KEY` near the top of `public/index.html`'s script — actually here they're the
`DEFAULT_SB_URL`/`DEFAULT_SB_KEY` constants, with Admin → Cloud Database in the app
able to override them if you ever need to point it elsewhere). Tables are prefixed
`crm_` so nothing collides with psg-planner's `users`/`orders`/etc.

## 1. Supabase (once)

1. In your Supabase project (the same one psg-planner uses) → **SQL Editor → New
   query**, paste **`schema.sql`**, **Run**. Creates `crm_clients`, `crm_calls`,
   `crm_meetings`, `crm_deals`, `crm_users`, `crm_rep_targets`.
2. No seed data needed — once the app is deployed and connected, open **Admin → Cloud
   Database → Push all local data to cloud** from the browser that already has your
   real data (munis-pc) to migrate everything currently in local storage.

## 2. GitHub

```bash
cd "cloudflare-deploy"
git init && git add . && git commit -m "PSG CRM — Cloudflare + Supabase"
git branch -M main
git remote add origin https://github.com/<you>/PSG-CRM-app.git
git push -u origin main
```

## 3. Cloudflare Worker (connected to GitHub)

Cloudflare dashboard → **Workers & Pages → Create → Workers → Import a repository** →
pick the repo. It reads `wrangler.toml` (serves `public/` as static assets) and
deploys. Every push to `main` redeploys. *(Cloudflare **Pages** also works: Create →
Pages → connect repo → build output directory `public`.)*

## 4. First run

Open the deployed URL. Log in with an existing account (Munis/Adnan/any rep — same
logins as the local version, since `crm_users` gets populated by the "Push all local
data to cloud" step above). The app should show your real clients/calls/deals/targets
immediately — if it's empty, double check step 1's "Push all local data to cloud" ran
from the browser that actually has the data.

### Security note
Same as psg-planner: the anon key sits in the page and the tables use permissive
access policies, so anyone with the URL can read/write. Fine for an internal tool on
a private link; if this needs to be reachable from outside the office, put it behind
Cloudflare Access (Zero Trust → Applications → add this Worker, restrict to your
company email domain) rather than relying on the URL being unguessable.

### WhatsApp bot integration
The WhatsApp bot (`whatsapp-bot` repo, Cloudflare Worker) pushes completed leads
straight into `crm_clients` (tagged `lead_source = "WhatsApp Bot"`, `record_type =
"Lead"`) via `src/services/crmSync.js`. See that repo's `wrangler.toml` for the
`SB_URL`/`SB_KEY` vars it needs (same project, same anon key as this app).

### Files
| Path | Purpose |
|------|---------|
| `public/index.html` | The whole CRM app. |
| `schema.sql` | Creates the `crm_*` tables. |
| `wrangler.toml` | Cloudflare Worker (static assets) config. |
