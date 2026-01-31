# WhatsApp Access + Compliance (2026) — AFRIPULSE (English)

## 1) Getting WhatsApp API access (recommended path)
You generally have 2 options:
### Option A — Use a BSP (fastest)
- Examples: Twilio, MessageBird, Infobip, Vonage, etc.
- Pros: fastest onboarding, easier setup, good tooling.
- Cons: higher per-message cost.

### Option B — Meta WhatsApp Business Platform (direct)
- Pros: direct pricing/control.
- Cons: more setup steps and ongoing compliance requirements.

AFRIPULSE v1 ships “Twilio-ready” webhook code so a gig can implement quickly.

## 2) Core compliance rules you MUST follow
- You must have opt-in consent before messaging users.
- Users must be able to opt-out easily (e.g., “STOP”).
- Do not spam; do not surprise users.
- Use approved templates for business-initiated messaging.
- Within the “customer service window” you can respond freely after the user messages you.

## 3) January 2026 policy change (important)
Meta/WhatsApp announced an update to its WhatsApp Business Platform / Business Solution policy (announced Oct 2025) that **prohibits third‑party “standalone, general‑purpose AI assistants”** (open‑ended chatbots) from operating on the WhatsApp Business Platform, with enforcement described as starting **January 15, 2026** (new users affected earlier in Oct 2025 per reporting).

AFRIPULSE remains compliant because it is:
- a **structured research & data‑collection bot** (surveys, opt‑in, opt‑out)
- not an open‑ended “ask me anything” assistant
- AI (if enabled) is only used for **business‑approved tasks** such as:
  - suggesting survey questions for paid campaigns
  - summarizing *aggregated* results
  - quality checks / fraud flags

Official + reputable references:
- WhatsApp Business Solution Terms (preview): https://www.whatsapp.com/legal/business-solution-terms/preview?lang=en
- WhatsApp Business Messaging Policy: https://business.whatsapp.com/policy
- TechCrunch reporting on the general‑purpose chatbot ban (Oct 18, 2025): https://techcrunch.com/2025/10/18/whatssapp-changes-its-terms-to-bar-general-purpose-chatbots-from-its-platform/
- European Commission press release on the policy and competition concerns (Dec 3, 2025): https://ec.europa.eu/commission/presscorner/detail/en/ip_25_2896

## 4) Templates and URLs (Jan 2026)
If you submit templates that include URLs, you must use valid, verifiable HTTPS URLs to avoid template creation errors.

## 5) Opt-in acquisition methods (practical)
- QR codes at partner locations (shops, events)
- Short links on social media
- Web landing page with checkbox consent
- USSD/SMS funnel to WhatsApp (country-dependent)
- Partner networks (telcos, associations, chambers of commerce)

## 6) What to store (privacy)
- Store the minimum: country/region and respondent attributes needed for representativeness.
- Do NOT sell personal data; sell aggregated insights.
- Keep audit logs and opt-out logs.
