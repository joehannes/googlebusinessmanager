# Architecture — AI-Powered Google Business Profile Manager

Local-first Flutter application (Linux desktop `.deb`, Android, web) for
managing business.google.com listings. No backend: the client talks directly
to the user's own AI provider and Google APIs.

## 1. Tech stack

| Concern | Choice | Notes |
| --- | --- | --- |
| Framework | Flutter / Dart | one codebase, responsive shell |
| State | `flutter_riverpod` | providers + `Notifier` for active workspace |
| Routing | `go_router` | `StatefulShellRoute` (bottom nav ⇄ nav rail ≥900px) |
| Database | `drift` (+ `drift_flutter`) | relational: businesses → staging items / posts |
| Key/flag store | `shared_preferences` | local-only; no libsecret build dependency |
| HTTP | `dio` | AI (OpenRouter), Google OAuth + GBP APIs, Nominatim |
| AI (text+vision) | `google_generative_ai` (Gemini) / OpenRouter REST (Qwen) | user-supplied free keys |
| Voice | `speech_to_text` | guarded; typing fallback on Linux desktop |
| Maps | `flutter_map` + OSM tiles + Nominatim | zero API keys |
| Geolocation | `geolocator` | guarded; map search/drag fallback on Linux |
| Media | `image_picker` + `image_cropper` | cropping mobile-only (4:3), picker everywhere |
| Phone input | `intl_phone_field` | country prefix assistance → auto `wa.me` link |
| Ads | `google_mobile_ads` | Android/iOS only; `AdsService` no-ops elsewhere |
| Extras | `url_launcher`, `confetti` | setup wizard links, success celebration |

## 2. Module map

```text
lib/
  core/
    routing/app_router.dart        # shell + routes, onboarding redirect
    theme/app_theme.dart           # M3 light/dark, amber AI-estimate accents
    services/
      key_store_service.dart       # prefs-backed keys/flags (AiProvider enum)
      ai_service.dart              # unified Gemini/Qwen text+vision, JSON contracts
      request_queue.dart           # serialization + pacing + 429 backoff
      gbp_api_service.dart         # OAuth loopback, accounts/locations/posts/media
      oauth_loopback_{io,stub}.dart# conditional import (web-safe)
      location_service.dart        # geolocator (guarded) + Nominatim search/reverse
      media_service.dart           # pick/camera/crop guards + image persistence
      speech_service.dart          # guarded speech_to_text wrapper
      ads_service.dart             # banner/interstitial lifecycle (mobile only)
    utils/whatsapp.dart            # wa.me link builder
  features/
    onboarding/                    # 5-page guided tour + key wizard + confetti
    businesses/                    # data (drift db, repository) + list/edit/detail
    location/                      # full-screen OSM pin picker
    staging/                       # catalog grid, editor, bulk AI create, publisher
    posts/                         # posts list, generate dialog, editor+publish
    ai_assistant/                  # voice/text chat + draft/analyze quick actions
    settings/                      # provider keys, OAuth credentials, tour replay
  shared/widgets/                  # AdBanner, EmptyState, PriceChip
```

## 3. Data model (Drift, schema v3)

- **business_profiles** — name, category, description, address,
  latitude/longitude, phoneCountryIso, phoneNumber (E.164), whatsappLink,
  website, email, notes, languages (CSV), targetAudience,
  gbpAccountName, gbpLocationName.
- **staging_items** — businessId FK, kind (product|service|offer|other),
  title (≤58 chars), category, description (≤1000 chars), language,
  priceAmount, currencyCode, **priceIsAiEstimate** (drives the amber
  highlight and the sync/publish guardrail), landingUrl (optional product
  page), imagePath, source (ai:gemini|ai:qwen|manual),
  status (draft|published), createdAt.
- **business_posts** — businessId FK, title, body, language,
  topicType (STANDARD|OFFER|EVENT), imagePath, source, status, createdAt.

v1 → v2 migration drops the old development tables (they contained seeded
demo rows only) and recreates cleanly; v2 → v3 adds `landingUrl`. No mock
data is seeded anywhere.

## 4. AI integration

One `AiService` façade over both providers:

- **Structured contracts** — listing/vision/post prompts demand a strict JSON
  array; parsing tolerates fences/prose but **throws `AiException` with the
  raw output** instead of inventing fallback content.
- **Local pricing** — the business address (or Nominatim reverse-geocoded
  coordinates) is injected into the system prompt, so estimates come back in
  the local currency for that market and are flagged `priceIsAiEstimate`.
- **Rate limiting** — every call runs through `RequestQueue`: serialized,
  ≥4 s spacing (Gemini free tier ≈15 RPM), exponential backoff retries on 429.
- **Key verification** — cheap real calls (`countTokens` / `GET /key`) power
  the onboarding wizard's "Test & save" step.

## 5. Google Business Profile publishing

- **Auth**: OAuth 2.0 installed-app **loopback flow** — temporary
  `127.0.0.1:<port>` HTTP server + system browser consent; refresh token
  stored locally; auto-refresh with expiry-safe caching. Conditional import
  keeps web builds compiling (flow itself needs the desktop/mobile app).
- **APIs used** (user's own Cloud project; Business Profile API access is
  granted by Google on request):
  - `mybusinessaccountmanagement.googleapis.com/v1/accounts`
  - `mybusinessbusinessinformation.googleapis.com/v1/{account}/locations`
    (list + `PATCH` with `updateMask`: title, phone, website, latlng)
  - `mybusiness.googleapis.com/v4/{parent}/localPosts` (posts)
  - `v4 media:startUpload` → bytes upload → media create (gallery photos)
- **Products (the Product Editor tab)**: verified July 2026 — Google still
  exposes **no public API** for the Products tab, and scripting the web UI
  violates their ToS. The app therefore ships a **Guided Product Sync**
  (`product_sync_screen.dart`): it cycles through every accepted entry,
  offers one-tap copy for each field (limits mirror the editor: name ≤58
  chars, description ≤1000 chars, price in local currency, optional landing
  page URL), reveals the photo for drag-&-drop, opens business.google.com,
  and tracks synced items. Publishing as local posts remains available as a
  clearly-labeled automatic alternative (posts ≠ Products tab).
- **Guardrail**: items whose price is still an unverified AI estimate are
  excluded from sync and skipped by the posts publisher.

## 6. UX

- Material 3, slate/off-white surfaces, indigo primary, teal accents; amber
  reserved for AI-estimate warnings. Light + dark.
- Responsive shell: bottom `NavigationBar` on phones, `NavigationRail` on
  ≥900 px; ad banner (mobile) tops the shell without layout jumps.
- Empty states everywhere explain the next step; long operations show paced
  progress ("Processing image 7 of 20 …").
- Onboarding: 2 showcase pages (voice→bilingual copy, photos→priced catalog),
  AI key wizard with provider choice + deep links + live test + confetti,
  optional Google Cloud walkthrough. Replayable from Settings.

## 7. Platform degradation matrix

| Capability | Android | Linux desktop | Web |
| --- | --- | --- | --- |
| Voice input | ✓ | typing fallback | browser-dependent |
| Camera | ✓ (+crop 4:3) | file picker | file picker |
| GPS | ✓ | map search/drag | browser prompt |
| Ads | ✓ (test IDs) | hidden | hidden |
| Google OAuth | ✓ loopback | ✓ loopback | disabled with notice |

## 8. Packaging

`packaging/build_deb.sh` wraps the release bundle into
`build/gbp-manager_<version>_amd64.deb`: `/opt/gbp-manager` payload,
`/usr/bin/gbp-manager` symlink, desktop entry + 256px icon, dependencies
`libgtk-3-0, libglib2.0-0, libstdc++6, libc6`. The runner's
`RUNPATH=$ORIGIN/lib` keeps the bundle relocatable.
