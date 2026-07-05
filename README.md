# Business Profile Manager

A **local-first, AI-augmented Flutter app** for managing Google Business Profile
(business.google.com) listings on Linux desktop, Android, and the web — with a
staging engine for bulk, voice-driven catalog creation.

No backend. Your data, drafts and API keys live on your device.

## Features

- **Multi-business workspaces** — manage any number of listings; catalogs,
  posts and AI context never mix between businesses.
- **Guided one-time onboarding** — showcase carousel plus a beginner-proof
  wizard for the free AI key (real verification ping, confetti included) and
  the optional Google Cloud OAuth setup.
- **Bring-your-own free AI key** (no credit card):
  - **Google Gemini** via AI Studio (recommended), or
  - **Qwen** text + vision models via OpenRouter.
- **Bulk creation engine** — select up to 20 product photos, dictate one
  instruction ("…target American and European investors, descriptions in
  English and Spanish, seasonal prices…"), and the vision AI drafts product
  names (≤58 chars), SEO descriptions (≤1000 chars), categories (**reusing
  your existing ones**), suggested landing-page URLs and **local market price
  estimations** for every image, in every configured language. Requests are
  auto-paced to respect free-tier rate limits.
- **Guided Product Sync** — Google offers no public API for the Products tab
  (checked July 2026), so after you accept the drafts the app walks you
  product-by-product: one-tap copy per field, photo reveal for drag-&-drop,
  opens the Product Editor, and tracks what's synced. Automatic post
  publishing via the (real) v4 API remains available as an alternative.
- **Human-in-the-loop staging catalog** — every AI draft lands in an editable
  grid. AI price estimates glow **amber** with a "Please verify" tooltip and
  are **never published unverified**.
- **Posts studio** — AI-drafted blog / "What's new" / offer posts per product,
  category or free-form spec; edit, translate, publish.
- **AI assistant** — chat by voice or keyboard; turn prompts or single photos
  straight into staged entries.
- **Smart contact** — country-aware phone input, automatic `wa.me/…` WhatsApp
  link generation.
- **Free maps** — OpenStreetMap (flutter_map) pin picking, Nominatim address
  search and reverse geocoding for the AI's local pricing context. No Google
  Maps key needed.
- **Real Google publishing** — OAuth 2.0 (loopback, "Desktop app" client) with
  your own Google Cloud credentials; list accounts/locations, link one to a
  workspace, push contact/website/coordinates, publish posts and photos.
- **AdMob** — top banner + post-publish interstitial on mobile (test ad units;
  no-op on desktop/web).

## Getting started

```bash
flutter pub get
dart run build_runner build   # generates Drift database code
flutter run                   # -d linux | -d chrome | Android device
```

## Build the Xubuntu/Debian package

```bash
./packaging/build_deb.sh
sudo apt install ./build/gbp-manager_1.0.0_amd64.deb
```

Installs to `/opt/gbp-manager`, adds a launcher entry ("Business Profile
Manager") and the `gbp-manager` command.

## One-time account setup (all free)

1. **AI key** — the in-app wizard walks you through it:
   - Gemini: <https://aistudio.google.com/apikey> (Google account only), or
   - OpenRouter: <https://openrouter.ai/keys>.
2. **Google publishing (optional)** — create a Google Cloud project, enable
   *My Business Account Management API*, *My Business Business Information
   API* and *Google My Business API*, configure the OAuth consent screen and
   create a **Desktop app** OAuth client. Paste ID + secret in Settings.
   Note: Google gates the Business Profile APIs behind a short
   [access request](https://developers.google.com/my-business/content/prereqs).

See [architecture.md](architecture.md) for the full technical design.
