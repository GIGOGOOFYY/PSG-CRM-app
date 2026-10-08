# Shared assets (synced to everyone, not just this PC)

Anything in this folder is part of the Cloudflare Pages deploy, so once it's
pushed it's reachable at the same public URL for every device — no more
"shows on my PC, not on anyone else's" (that happened before because files
were only ever local to one machine; nothing here depends on your PC being on).

- `pdfs/`   — datasheets, spec sheets, catalogs etc. to link/attach from the
              WhatsApp bot or the CRM.
- `images/` — logos, product photos, anything else that needs a stable URL.

## How to use

1. Drop the file in `pdfs/` or `images/` (keep the filename simple — no
   spaces; use dashes, e.g. `laminated-glass-tds.pdf`).
2. `git add`, commit, `git push` from `cloudflare-deploy` as usual.
3. Once Cloudflare Pages finishes deploying (~30-60s), the file is live at:
   https://psg-crm.pages.dev/assets/pdfs/<filename>
   https://psg-crm.pages.dev/assets/images/<filename>

That URL is what the WhatsApp bot needs to send a file as a document
message, and what any `<img>`/link in the CRM webapp can point to.
