<div align="center">

# 💊 PillBin

### Smart, offline-first medicine management — track, donate, and dispose responsibly

[![Get it on Google Play](https://img.shields.io/badge/Google_Play-Download-414141?logo=googleplay&logoColor=white)](https://play.google.com/store/apps/details?id=com.nikhil.pillbin)

[![Flutter](https://img.shields.io/badge/Flutter-3.4.4-02569B?logo=flutter)](https://flutter.dev) [![Node.js](https://img.shields.io/badge/Node.js-22-339933?logo=nodedotjs)](https://nodejs.org) [![FastAPI](https://img.shields.io/badge/FastAPI-Python-009688?logo=fastapi)](https://fastapi.tiangolo.com) [![MongoDB](https://img.shields.io/badge/MongoDB-8.x-47A248?logo=mongodb)](https://mongodb.com) [![Agno](https://img.shields.io/badge/Agno-Multi--Agent-FF6B35?logo=openai)](https://github.com/agno-agi/agno) [![ChromaDB](https://img.shields.io/badge/ChromaDB-Hybrid%20RAG-FFB300)](https://trychroma.com) [![Firebase](https://img.shields.io/badge/FCM-Push-FFCA28?logo=firebase)](https://firebase.google.com) [![Render](https://img.shields.io/badge/Render-Deployed-46E3B7?logo=render)](https://render.com)

</div>

---

## 📸 App Screenshots

<div align="center">

<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/6ff038f3-fe9b-4dae-8c98-863b130d14cb" width="160"/></td>
    <td><img src="https://github.com/user-attachments/assets/180f3b38-dd99-45ae-8067-d8f422d13cb0" width="160"/></td>
  </tr>
</table>

</div>

---

## 📖 Overview

**PillBin** is a comprehensive, offline-first medicine management application built for both patients and medical centers, **live on [Google Play](https://play.google.com/store/apps/details?id=com.nikhil.pillbin)**. Users can track medicines for themselves and their family, get expiry and refill reminders, discover nearby disposal centers, donate unused medicines, and get AI-powered health insights — all from a single app.

The platform connects users with **verified vendor centers** through a full donation and approval pipeline, enriched with contextual in-app nudges, a moderated community blog, and **PillBot** — a multi-agent AI chatbot built on the Agno framework, with a low-latency decision model routing each question to the right specialist agent and RAG over the user's own uploaded documents.

---

### 📦 Medicine Inventory Management

At its core, PillBin is a smart medicine cabinet. Users can add medicines with full metadata — `name`, `dosage`, `batch number`, `manufacturer`, `type`, `purchase date`, `expiry date`, `notes`, and even an optional photo. The system auto-classifies each medicine into one of three live states:

- **Active** — more than 5 days until expiry, shown in green
- **Expiring Soon** — 5 days or fewer until expiry, shown in amber with a daily 9 AM push notification
- **Expired** — past expiry date, shown in red with a one-tap bulk-clear action

Medicines are **soft-deleted** first (moved to a "Deleted Bin" with up to 100-item history), then permanently wiped on demand. Medicines expired for more than 15 days can also be auto-cleaned by the daily job (opt-in via `EXPIRY_CLEANUP_ENABLED`). A per-account cap of **100 active medicines** keeps queries performant. Each medicine also stores product links to external pharmacy sites (`Tata 1mg`, `PharmEasy`, `Netmeds`) for quick reordering.

#### 🔁 Refill Reminders

Any medicine can be marked as **recurring** with a refill interval in days. The server stores `nextRefillAt`, and the same daily 9 AM job that sends expiry alerts also finds every medicine whose refill is due, sends **one grouped push per user** ("Time to refill 3 medicines"), and rolls `nextRefillAt` forward by the interval. A per-user, per-day dedup key makes a job re-run on the same day a no-op instead of a second notification.

#### 👨‍👩‍👧 Family Profiles

One account can track medicines for the whole household. Users add family members (name and optional relation) and tag each medicine as theirs or a member's; the inventory screen gets a **Self / Mom / Dad** profile switcher that filters every tab. It is deliberately one shared inventory with a tag, not separate inventories, so expiry alerts, refills and stats keep working unchanged — notifications just read "Paracetamol (Mom)". The server validates that a submitted `familyMemberId` belongs to the caller before saving it, and deleting a member moves their medicines back to the account owner.

---

### 🏥 Donation System

PillBin turns unused medicines into community value. Users can submit a donation request to any nearby approved medical center, attaching:

- A list of medicines to donate (name, category, quantity, expiry, condition)
- Up to 2 medicine photos (`medicinePhotos[]` stored on Cloudinary)
- A personal note and contact preference (`call`, `visit`, `either`)

The request enters a **4-stage pipeline**:

```
Pending → Approved / Rejected → Completed
```

Once approved, the user is notified and can call the center directly from the app to schedule pickup. Vendors can attach a `vendorNote` on approval or rejection. Users can cancel `pending` requests at any time. All donations are searchable by medicine name or center name and grouped by status.

**"Centers near you need…" banner.** Vendors mark each medicine category they take as `accepting`, `full` or `not_accepting`. A `$geoNear` + `$facet` aggregation (`GET /api/medical-center/nearby-needs`) finds approved centers near the user and returns the categories most of them are currently accepting, which the inventory screen shows as a dismissible banner — so donations go where they are actually wanted.

Completing a donation is **atomic**: the status change, the center's donation counter and the donor's inventory update run in a single **MongoDB transaction**, and the push notification is sent only after the commit, so a retried transaction can never notify twice.

---

### QR Handover & Shareable Receipts

The last two steps of a donation happen at the counter, so both are built around a QR code.

**Handover.** An approved donor taps *Show Handover Code* and the server mints a JWT carrying a `typ: "handoff"` claim, the request id, and the donor id. It lives **5 minutes** and the app silently re-mints it every 4, so the code on screen always works but a screenshot stops working almost immediately. The vendor scans it and the donation completes — the scan path and the manual *Mark as Completed* button call the same `finalizeCompletion()`, so the two can never drift. Scanning runs with `DetectionSpeed.noDuplicates` behind an in-flight guard, and a second scan of the same code is rejected because the request has already left `approved`.

**Receipt.** Either side can open a completed donation and share a receipt. It is painted entirely on-device — a `RepaintBoundary` over a fixed 720px canvas, captured to PNG and handed to the platform share sheet — so there is no upload, no storage, and no link that can rot. Because it is an image it previews inline in WhatsApp rather than arriving as a file to download.

The receipt stays verifiable anyway: it carries a QR pointing at a **public** verification page, `GET /api/donations/verify/:id`, which renders the receiving center, collection date and item counts for anyone the receipt is forwarded to. Nothing about the donor is exposed, and nothing is stored to support it — the receipt number (`PB-<year>-<id tail>`) is derived from the request id by the same formula on both the app and the server.

---

### 🏢 Vendor Portal

Medical centers onboard as **Vendors**. After registration, a center goes through admin verification before appearing in the user-facing location list. The vendor dashboard provides:

- **Center profile management** — name, address, facility type, operating hours, accepted medicine categories, ratings
- **Image gallery** — upload up to 3 center photos (Cloudinary + `CachedNetworkImage` with shimmer loading)
- **Verification document upload** — up to 5 documents for admin review
- **Inventory management** — what medicine types the center currently accepts
- **Donation request inbox** — view all incoming requests, approve / reject with a note, mark as completed
- **QR scanner** — complete a handover by scanning the donor's code instead of tapping through the list

Vendor routes are guarded by the `requireVendor` middleware — the `role` field on the `User` model must be `"vendor"`.

---

### ⭐ Ratings & Reviews

Once a donation is **completed**, the donor can rate the center 1–5 with an optional comment — one review per donation, enforced by a unique index on `donationRequestId`. Reviews are deletable by their author, which frees that donation to be rated again.

Centers carry two numbers: a plain **average** shown as stars, and a **Bayesian weighted rating** used for ranking, so one 5★ review can't outrank a center with fifty 4.8★ ones:

```
weighted = (C × 3.5 + ratingSum) / (C + totalReviews)     // C = 5
```

Both are maintained as **running counters** (`ratingSum`, `totalReviews`, `ratingBreakdown`) updated with a single `$inc` per write — no aggregation, so the cost is flat whether a center has 10 reviews or 10 million. The review row and the counter update commit together in one **MongoDB transaction**. Reviews paginate with a **server-side star filter**, so filtering searches every review rather than the loaded page.

Review text goes through the same [content moderation](#content-moderation) as blog posts. A held review still counts toward the star rating (it comes from a real completed donation); only its text is hidden until an admin approves it.

---

### 📊 Vendor Analytics

A dedicated analytics screen with a **6M / 1Y / 2Y / 5Y** period selector. Bucket granularity follows the range so the chart never exceeds ~12 bars:

| Range | Bucket | Label |
|---|---|---|
| ≤ 12 months | monthly | `Aug` |
| 13–36 months | quarterly | `Q3 '26` |
| > 36 months | yearly | `2026` |

Surfaces total requests, fulfilment rate, average approval latency (computed from the `statusHistory` audit trail), a status-breakdown donut, most-donated medicines, and the busiest period. The dashboard keeps a compact preview that links through.

---

### 📈 Donation Impact

Donors get an impact screen summarising what they've contributed — medicines safely disposed, medicines tracked, campaigns joined and badges earned — plus a per-request **status timeline** rendered from `statusHistory`, so every state change is visible with its timestamp.

**Share my Impact** turns that screen into a branded image card (name, medicines disposed, stats and badges) and opens the share sheet. It uses the same on-device technique as the receipt: an off-screen `RepaintBoundary` captured to PNG, with no server call.

---

### 🤖 PillBot — Multi-Agent AI Chatbot

PillBot is built on the **Agno** multi-agent framework and is the most technically complex feature in PillBin. It exposes a **FastAPI** endpoint that the Flutter app calls with user queries and a `userId` for session continuity.

The agent pipeline:
1. **Query intake** — user message received by FastAPI, `userId` resolved to a Redis chat history key, and the caller's role (`user` or `vendor`) verified against the Node API rather than trusted from the request
2. **Intent routing** — a router picks exactly one specialist path, so a simple question never pays for the full toolchain. The categories are role-aware: users get inventory, directory, donations, notifications, knowledge and general; vendors get requests, center, notifications, out-of-scope and general
3. **RAG retrieval** — for questions about the user's own uploaded documents, the query is searched against a **ChromaDB** hybrid index (vector + keyword, RRF-fused, `k=60`), filtered to that user's documents only
4. **Live tools** — inventory, directory, donation, vendor and notification tools call the Node API with the user's JWT, so answers reflect the user's real data
5. **Web search** — DuckDuckGo for general health questions, with safety rules: no diagnosis, no dosing advice, emergency guidance first
6. **LLM reasoning** — Agno composes the context and answers via **Gemini** (or **Groq**, switchable through `LLM_PROVIDER`), with a 60 s timeout and a structured fallback response on failure
7. **Two-tier history** — recent turns live in **Redis** with a 24h TTL, older ones fall back to **SQLite**, paged 40 messages at a time

Chat history is persisted per `userId`, providing continuity across app sessions.

#### ⚡ Decision-model router (Jev)

Routing is a classification problem, so instead of asking a text-generating LLM to write a category name, PillBot asks **Jev** — a "System 1" decision model from TypeSafe AI that returns calibrated probabilities instead of text — three typed questions in a single call:

| Question | Type | Used for |
|---|---|---|
| `intent` | choice | Which specialist agent handles the query |
| `is_followup` | boolean | Conversational follow-ups ("tell me more") that need the chat history |
| `is_emergency` | boolean | Chest pain, stroke signs, overdose and similar — users only |

The decision is confidence-gated: a top intent probability ≥ 0.7 is used directly; follow-ups, low-confidence answers, and any Jev error or timeout (2 s) fall back to the original Gemini router, so an outage degrades speed, never correctness. An emergency score ≥ 0.5 adds a *seek immediate care first* instruction to whichever agent answers and bypasses the history shortcut. Jev is called through the **Vercel AI Gateway** and toggled with `JEV_ENABLED`. In live testing it routed 7/7 sample queries correctly — including a vendor asking about their own medicine at home (out of scope) and a chest-pain message (emergency 0.99) — in about 0.4–0.6 s per call.

---

### 📍 Location-Based Services

Users can discover nearby medical and disposal centers using **MongoDB `$geoNear`** geospatial queries. The default search radius is **10 km** and is customizable. Results can be filtered by facility type:

- `Hospital`, `Clinic`, `Pharmacy`, `Health Center`

Each center card shows: operating hours, accepted medicine types, ratings, an image gallery, and a direct-call button. Only **admin-approved** centers appear in this list — centers awaiting verification are invisible to users. Vendor-registered centers that passed admin document review carry a **Verified** badge on both the list card and the detail screen, so donors can tell a reviewed listing apart at a glance.

Users can **save** centers to a personal list (`savedMedicalCenters` on the `User` model) and access them quickly from their profile.

---

### 🔔 Smart Notification System

PillBin has a server-side notification model (`Notification` collection) with 4 priority levels — `Normal`, `Important`, `Urgent`, `Alert`. Delivery is **Firebase Cloud Messaging** push plus an in-app inbox, with device tokens registered per install (`DeviceToken`) and deactivated on logout.

| Type | Trigger | Schedule | Priority |
|---|---|---|---|
| Welcome | Signup completion | Instant | Normal |
| Medicine Expiry | Expiring within 5 days, or expired | Daily 9 AM IST (`node-cron`) | Important / Alert |
| Refill Due | A recurring medicine's refill date has arrived | Daily 9 AM IST (same job) | Normal |
| Donation Updates | Submitted / approved / completed / cancelled | Instant | Important |
| Moderation | Content held for review (admins) · approved / removed (author) | Instant | Important / Normal |
| Center Verification | Admin approves or rejects a vendor center | Instant | Important |

Expiry and refill alerts are **grouped per user** ("3 medicines expire soon") and carry a per-user, per-day dedup key backed by a unique index, so a re-run of the job on the same day can't double-notify. The inbox is **paginated 20 at a time** with infinite scroll, and a **60-day TTL index** ages rows out automatically. The unread badge reads a server-side `countDocuments` rather than the loaded page, so it stays correct past page one.

If the user has turned notifications off at the OS level, **Settings** shows a warning ("you'll miss expiry and refill reminders") with a button that opens the phone's app settings — otherwise every reminder feature would fail silently.

---

### 💬 In-App Nudge System

Separate from the notification inbox, PillBin has a live **nudge engine** built into the `RootScreen` overlay. On app open, it evaluates real user data and injects up to **3 contextual slide-up cards** per session, in strict priority order:

| Priority | Nudge | Condition |
|---|---|---|
| 1 | Donation Approved | Any approved donation request |
| 2 | Medicines Expiring | `expiringSoonCount` > 0 |
| 3 | Donation Pending | Any pending request > 2 days old |
| 4 | Find Centers Near You | First time only (persisted flag) |
| 5 | Explore Health Blogs | First time only (persisted flag) |
| 6 | Donate Unused Medicines | First time + no donations yet |

Cards auto-dismiss after 6 s, support swipe-to-dismiss, and their tap action navigates directly to the relevant screen. One-time nudges are stored in `FlutterSecureStorage` and never repeat.

---

### 📝 Community Blog

PillBin has a fully-featured community blog for health awareness content:

- Browse all community posts in a chronological feed
- Create posts with up to 2 media attachments (photos)
- **AI-generated blog images** — a dedicated `/api/blog/generate/image` endpoint uses **Azure FLUX** to generate a relevant cover image from the post's text
- Like posts (toggle), view likers, add / edit / delete comments
- Personal feed showing only your own posts

### Content Moderation

In a health app, user posts are a real risk: dangerous medical advice ("stop your insulin"), people trying to sell prescription drugs, spam and abuse. Every blog post, comment and review text is classified by **Jev** on create **and on edit** (so a harmless post can't later be edited into a harmful one) into `ok`, `spam`, `abusive`, `selling_medicines` or `dangerous_advice`:

| Result | Action |
|---|---|
| `ok` ≥ 0.7 | Published |
| `spam` / `abusive` / `selling_medicines` ≥ 0.85 | Rejected with a community-guidelines message; nothing is saved |
| Anything else, including all `dangerous_advice` | **Held**: saved but visible only to its author (shown as *Under review*) until an admin approves it |

`dangerous_advice` is never auto-rejected, however confident the model is, because a doctor's genuine advice can trip it — a person always makes that call. Held items notify every admin and sit in a review queue (`GET /api/admin/moderation`); approving or rejecting notifies the author. Comment counts only include visible comments, so holding, approving or deleting a comment never drifts the count. Moderation **fails open**: if Jev is disabled, errors or times out, content publishes exactly as it would without moderation, so an outage never blocks posting.

---

### 💾 Offline-First Architecture

Every API response that the app fetches is saved to a **custom TTL cache** built on `FlutterSecureStorage`, covering 11 distinct data types (inventory, donations, centers, notifications, profile, etc.). On every subsequent load:

1. **Cache hit** — serve data instantly, no spinner shown
2. **Cache miss / expired** — call API, refresh cache, update UI
3. **Network error** — fall back to stale cache, show connectivity banner

TTLs are **per data type**, from 1 hour for fast-changing data (profile, chat history) up to 24 hours for slow-changing data (all centers); the default is 24 hours. `Connectivity Plus` monitors network state in real time; the app syncs in the background as soon as connectivity is restored.

---

### 🎖️ Badge & Stats System

The `User` model tracks lifetime stats (`totalMedicinesTracked`, `expiringSoonCount`, `medicinesDisposedCount`, `campaignsJoinedCount`) and awards **gamification badges** automatically:

| Badge | Condition |
|---|---|
| 🥉 First Timer | ≥ 1 medicine tracked |
| 🥈 Eco Helper | ≥ 5 medicines tracked |
| 🥇 Green Champion | ≥ 20 medicines tracked |

Badge unlock timestamps are recorded and displayed on the user's profile screen.

---

### 📚 Information & Awareness

The **Info** feature provides curated, static-content articles on:
- Medicine disposal best practices
- Environmental impact of improper disposal
- Government disposal programs and NGO directories

This makes PillBin not just a utility app but an awareness platform for responsible medicine lifecycle management.

---

### 🔐 Authentication & Role System

PillBin supports **passwordless email OTP** and **Google Sign-In**, both landing on the same session:

1. **OTP** — user enters email → code sent via `Nodemailer` / `Resend` → verified
2. **Google** — native account picker returns an ID token, verified server-side with `google-auth-library`
3. Either path issues a JWT **access token** (3h) + **refresh token**, rotated transparently by the refresh endpoint

Google is only ever an *identity check* — the app's own JWT still runs the session, so every protected route is unchanged. Accounts are matched **by email**, so signing in with Google on an existing OTP account **links** the two providers instead of creating a duplicate: the same `_id`, role, and donation history are kept.

OTP requests are rate-limited via `express-rate-limit` at **5 per 10 minutes per email** (stops one inbox being flooded) and **30 per 10 minutes per IP** (stops one client spraying many emails), using `ipKeyGenerator` so IPv6 clients can't dodge the limit by rotating addresses. Three roles exist — `user`, `vendor`, `admin` — each enforced by dedicated middleware (`requireVendor`, `requireAdmin`) on all sensitive routes.

---

## 🗂️ Project Structure

```
pillbin/
├── app/                              # Flutter Mobile Application
│   └── lib/
│       ├── config/
│       │   ├── cache/               # TTL CacheManager (offline-first)
│       │   ├── routes/              # Named navigation routes
│       │   └── theme/               # Colors, text styles
│       ├── core/
│       │   ├── nudge/               # In-app nudge engine
│       │   └── utils/               # Shimmer, snackbar helpers
│       ├── features/
│       │   ├── auth/                # OTP authentication
│       │   ├── blog/                # Community blogs
│       │   ├── donation/            # Donation requests & tracking
│       │   ├── home/                # Dashboard & quick actions
│       │   ├── info/                # Awareness & articles
│       │   ├── locations/           # Medical center discovery
│       │   ├── medicines/           # Medicine inventory
│       │   ├── pillbot/             # Multi-agent AI chatbot
│       │   ├── profile/             # User profile
│       │   └── vendor/              # Vendor portal & dashboard
│       ├── network/                 # Dio HTTP client, models
│       ├── root_screen.dart         # Bottom nav + nudge overlay
│       ├── app.dart
│       └── main.dart
│
├── server/                           # Node.js Backend API
│   ├── controllers/
│   │   ├── adminController.js        # Center verification + moderation queue
│   │   ├── authController.js
│   │   ├── blogController.js
│   │   ├── commentController.js
│   │   ├── donationController.js     # Donations, reviews, receipts
│   │   ├── familyMemberController.js
│   │   ├── medicalCenterController.js
│   │   ├── medicineController.js
│   │   ├── notificationController.js
│   │   └── vendorController.js
│   ├── jobs/expiryJob.js             # Daily expiry + refill notifications
│   ├── services/
│   │   ├── moderationService.js      # Jev content moderation
│   │   ├── notifyService.js          # Inbox row + FCM push
│   │   └── pushService.js
│   ├── models/
│   ├── routes/
│   ├── middleware/
│   ├── utils/transaction.js          # MongoDB transaction helper
│   ├── server.js
│   └── Dockerfile
│
└── agno_agent/                       # Python AI Agent
    └── backend/
        ├── database/
        │   ├── redis_client.py
        │   ├── sqlite_client.py
        │   └── chat_repository.py    # Redis hot tier → SQLite archive
        ├── models/output_schema.py
        ├── routes/                   # /query, /history, /knowledge
        ├── tools/                    # inventory, directory, donation, vendor, notification
        ├── utils/role_resolver.py    # Verifies user vs vendor with the Node API
        └── services/
            ├── agent_service.py      # Intent router + specialist agents
            ├── jev_client.py         # Jev decision-model client
            ├── knowledge_service.py  # ChromaDB hybrid RAG
            └── llm_factory.py        # Gemini / Groq switch
```

---

## 🛠️ Tech Stack

### Mobile / Frontend
| Layer | Technology |
|---|---|
| Framework | Flutter 3.4.4 / Dart 3.x |
| State Management | Provider |
| HTTP Client | Dio |
| Offline Cache | FlutterSecureStorage (TTL, 11 types) |
| Image Loading | CachedNetworkImage |
| Maps | Google Maps Flutter |
| Location | Geolocator |
| Connectivity | Connectivity Plus |
| Media Uploads | Image Picker / Cropper |
| Notifications | Flutter Local Notifications |
| QR | `qr_flutter` (render) · `mobile_scanner` (scan) |
| Sharing | `share_plus` + `path_provider` (receipt PNG) |
| Typography | Poppins (custom font) |

### Backend
| Layer | Technology |
|---|---|
| Runtime | Node.js 22 |
| Framework | Express 5.1 |
| Database | MongoDB 8.x + Mongoose |
| Auth | JWT (access + refresh) · Google via `google-auth-library` |
| Push | Firebase Admin (FCM) |
| Scheduling | `node-cron` (daily expiry job) |
| File Storage | Cloudinary + Multer |
| Email OTP | Nodemailer / Resend |
| AI (blog images) | Azure FLUX |
| AI (moderation) | Jev via Vercel AI Gateway |
| Transactions | MongoDB multi-document transactions |
| Rate Limiting | express-rate-limit |

### AI Agent
| Layer | Technology |
|---|---|
| Runtime | Python 3.11 |
| API Server | FastAPI + Uvicorn |
| Agent Framework | Agno (intent router + specialist agents) |
| Intent Router | Jev decision model, with Gemini / Groq fallback |
| LLM | Gemini or Groq (`LLM_PROVIDER`) |
| Embeddings | Gemini |
| Vector Search | ChromaDB — hybrid vector + keyword, RRF-fused |
| Chat History | Redis (hot, 24h TTL) → SQLite (archive) |
| Web Search | DuckDuckGo Search tool |

### Data & Infrastructure
| Service | Purpose |
|---|---|
| MongoDB | Primary DB with geospatial indexing |
| ChromaDB | Vector store for RAG (persistent, disk-backed) |
| Redis | Agent chat history cache |
| Cloudinary | Medical center & medicine image CDN |
| Firebase | Cloud Messaging + Google Sign-In |
| Vercel AI Gateway | Access to the Jev decision model |
| Render | Server + agent hosting (Docker) |

---

## 🏗️ Architecture

```
┌──────────────┐                 ┌──────────────────┐      ┌──────────────────┐
│ Flutter App  │◄───────────────►│   Node.js API    │─────►│ MongoDB          │
│ (Android)    │   REST + FCM    │   (Express)      │      │ + Cloudinary     │
└──────┬───────┘                 └────────┬─────────┘      └──────────────────┘
       │                                  │  content moderation
       │ /query                           ▼
       │                         ┌──────────────────┐
       │                         │ Jev (Vercel AI   │
       │                         │ Gateway)         │
       │                         └──────────────────┘
       ▼                                  ▲  intent · follow-up · emergency
┌─────────────────────────────────────────┴──────────────────────────────────┐
│ Python Agent (FastAPI)                                                     │
│                                                                            │
│  query ──► Router ──confident──► Specialist agent (Agno) ──► answer        │
│              │                        │          │                         │
│              └─ unsure / error ──► Gemini router │                         │
│                                       ▼          ▼                         │
│                              Node API tools   ChromaDB hybrid RAG          │
│                              (user's JWT)     (user's own documents)       │
│                                                                            │
│  Chat history: Redis (hot, 24h) → SQLite (archive)                         │
│  LLM: Gemini or Groq (LLM_PROVIDER)                                        │
└────────────────────────────────────────────────────────────────────────────┘
```

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK** 3.4.4+, **Dart** 3.x
- **Node.js** 22.x+ (`firebase-admin` requires ≥22)
- **Python** 3.11+
- **MongoDB** 8.x (local or Atlas)
- **Docker** (optional, for containerized deployment)

---

### Backend Setup

```bash
cd server
npm install
cp .env.example .env
```

Fill in `server/.env`. The required values are `MONGODB_URI`, the two JWT secrets, SMTP (for OTP emails), Cloudinary and `GOOGLE_CLIENT_ID` (the OAuth **Web** client ID, not the Android one). Firebase, Azure image generation and Jev are optional: each feature switches itself off when its values are empty.

```bash
npm start
```

The server starts at **`http://localhost:5000`**.

---

### AI Agent Setup

```bash
cd agno_agent
python -m venv venv
source venv/bin/activate       # Windows: venv\Scripts\activate
pip install -r backend/requirements.txt
cp .env.example .env
```

Fill in `agno_agent/.env`: `GEMINI_API_KEY` (or `GROQ_API_KEY` with `LLM_PROVIDER=groq`) and `REDIS_URL`. In Docker, point `CHROMA_PATH` and `SQLITE_PATH` at the persistent disk (`/data/chromadb`, `/data/pillbin.db`). Jev is optional.

```bash
uvicorn backend.main:app --reload
```

The agent starts at **`http://localhost:8000`**.

---

### Mobile App Setup

```bash
cd app
flutter pub get
```

```bash
cp .env.example .env
```

Fill in `app/.env`: `GOOGLE_SERVER_CLIENT_ID` (the same Web client ID the server uses) and the Gmail account that sends OTP emails. The `*_KEY` entries are just storage key names and can stay as they are.

The Google Maps key is read from `app/android/local.properties` (gitignored) and injected into the manifest as a placeholder, so it never enters the repo. Add:

```properties
MAPS_API_KEY=AIza...
```

Without it the app still builds, but the map renders blank.

Backend URLs live in [`lib/network/config/api_config.dart`](app/lib/network/config/api_config.dart) — flip one line to switch the whole app between local and deployed:

```dart
static const String currentEnvironment = 'dev';   // 'dev' | 'prod'
```

Google Sign-In on Android also needs your debug **and** release SHA-1/SHA-256 fingerprints registered in the Firebase console, then `google-services.json` re-downloaded:

```bash
cd android && ./gradlew signingReport
```

```bash
flutter run
```

---

## 📡 REST API Reference

All Node routes are prefixed with `/api`. Protected routes require `Authorization: Bearer <access_token>`. List endpoints are paginated with `?page=&limit=`.

### Auth — `/api/auth`
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/signup` | Request OTP for a new account |
| `POST` | `/verify-signup` | Verify OTP, create account |
| `POST` | `/signin` | Request OTP for an existing account |
| `POST` | `/verify-signin` | Verify OTP, receive tokens |
| `POST` | `/google` | Sign in / up with a Google ID token |
| `POST` | `/refresh-token` | Rotate access token |

### User — `/api/user`
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/profile` | Get full profile |
| `POST` | `/complete-profile` | Complete onboarding profile |
| `PUT` | `/edit-profile` | Edit profile details |
| `POST` | `/save-medical-center` | Save a center as favourite |
| `DELETE` | `/remove-saved-medical-center` | Remove saved center |
| `GET` | `/saved-medical-centers` | List saved centers |

### Medicines — `/api/medicine`
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/add` | Add medicine (optional photo, recurrence, family member) |
| `GET` | `/inventory` | Get active inventory |
| `GET` | `/deleted-inventory` | Get soft-deleted medicines |
| `PUT` | `/update/:medicineId` | Update medicine details |
| `DELETE` | `/delete/:medicineId` | Soft-delete medicine |
| `DELETE` | `/delete-all-expired` | Bulk soft-delete all expired |
| `DELETE` | `/delete/:medicineId/hard` | Permanently delete medicine |
| `DELETE` | `/delete-all-hard` | Permanently wipe deleted bin |

### Family Members — `/api/family-members`
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/` | List the account's family members |
| `POST` | `/` | Add a family member |
| `DELETE` | `/:memberId` | Remove a member; their medicines move back to the owner |

### Donations — `/api/donations`
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/` | Submit donation request (with photos) |
| `GET` | `/my-requests` | Get the user's donation history |
| `GET` | `/:id` | Get a single donation request |
| `DELETE` | `/:id` | Cancel a pending request |
| `GET` | `/:id/handoff-token` | Mint the 5-minute QR token for an approved donation |
| `POST` | `/:id/review` | Rate a completed donation (moderated) |
| `DELETE` | `/review/:reviewId` | Delete your own review |
| `GET` | `/center/:centerId/reviews` | Center reviews — paginated, `?rating=` filter |
| `GET` | `/verify/:id` | **Public** — HTML page verifying a shared receipt |

### Medical Centers — `/api/medical-center`
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/nearby` | Geo-search nearby centers — `?latitude=&longitude=&radius=` |
| `GET` | `/nearby-needs` | Categories nearby centers are currently accepting |
| `GET` | `/search` | Search centers by name / type |
| `GET` | `/all` | List all approved centers |
| `GET` | `/:id` | Get center details |
| `GET` | `/:id/inventory` | Get a center's accepted inventory |

### Blogs — `/api/blog`
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/` | Community feed (published posts only) |
| `GET` | `/user` | Current user's posts, including held ones |
| `GET` | `/:id` | Get a single post |
| `POST` | `/` | Create post with media (moderated) |
| `PUT` | `/:id` | Update post (re-moderated if the content changes) |
| `DELETE` | `/:id` | Delete post |
| `POST` | `/generate/image` | Generate a cover image with Gemini |
| `POST` | `/:id/likes` | Toggle like |
| `GET` | `/:id/likes` | List likers |
| `GET` | `/:id/likes/status` | Whether the current user liked the post |
| `GET` | `/:id/comments` | List comments |
| `POST` | `/:id/comments` | Add comment (moderated) |
| `PUT` | `/:id/comments/:commentId` | Edit comment (re-moderated) |
| `DELETE` | `/:id/comments/:commentId` | Delete comment |

### Notifications — `/api/notifications`
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/` | Get notifications — paginated |
| `GET` | `/unread-count` | Server-side unread count for the badge |
| `POST` | `/read` | Mark notifications as read |
| `POST` | `/tokens/register` | Register this device's FCM token |
| `POST` | `/tokens/deactivate` | Deactivate the token on logout |
| `DELETE` | `/:notificationId` | Dismiss one notification |
| `DELETE` | `/` | Clear all notifications |

### Vendor — `/api/vendor` (role: `vendor`)
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/register-center` | Register a medical center |
| `GET` | `/my-center` | Get the vendor's center |
| `PUT` | `/my-center` | Update center profile |
| `PUT` | `/my-center/images` | Upload center photos |
| `PUT` | `/inventory` | Update accepted categories and their status |
| `POST` | `/verify-documents` | Upload verification documents |
| `GET` | `/requests` | Incoming donation requests |
| `PUT` | `/requests/:id` | Approve / reject with a note |
| `PUT` | `/requests/:id/complete` | Mark a donation as completed |
| `POST` | `/scan` | Complete a donation from a scanned handover token |
| `GET` | `/analytics` | KPIs, timeline & top medicines — `?months=6,12,24,60` |
| `GET` | `/analytics/medicines` | Ranked donated-medicine totals, paginated |

### Admin — `/api/admin` (role: `admin`)
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/verifications` | Pending center verifications |
| `PUT` | `/verifications/:centerId/approve` | Approve a vendor center |
| `PUT` | `/verifications/:centerId/reject` | Reject a vendor center (reason required) |
| `GET` | `/moderation` | Held posts, comments and reviews — `?type=blog\|comment\|review` |
| `PUT` | `/moderation/:type/:id/approve` | Publish a held item |
| `PUT` | `/moderation/:type/:id/reject` | Remove a held item |

### AI Agent (FastAPI, port 8000)
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/query` | Ask PillBot (form data: `token`, `user_message`, optional location, role and PDF upload) |
| `GET` | `/history` | Chat history — paginated, 40 per page |
| `DELETE` | `/history` | Clear chat history |
| `DELETE` | `/knowledge` | Delete the user's indexed documents |

---

## 🧮 Core Algorithms

### TTL Cache Layer (Offline-First)
The Flutter app implements a custom **11-type TTL cache** using `FlutterSecureStorage`:
1. On every API call, check cache first — serve immediately if valid
2. On cache miss or expiry, hit the API and refresh the cache
3. On network error, fall back to stale cache (no hard failure)

TTLs are set per data type (1–24 hours) with background sync on reconnect. Connectivity state is monitored via `Connectivity Plus`.

### Medicine Status Engine
Statuses are computed from `expiryDate` whenever a medicine is saved, and recomputed for every medicine by the daily job:
- `active` — more than 5 days until expiry
- `expiring_soon` — ≤ 5 days until expiry
- `expired` — past expiry date

A daily `node-cron` job (9 AM IST, configurable via `EXPIRY_CRON`) finds medicines whose status changed since the last alert, sends one grouped notification per user, then sends refill reminders. A run lock prevents two overlapping runs, and per-day dedup keys make re-runs safe. Cleanup of medicines expired for more than 15 days is opt-in (`EXPIRY_CLEANUP_ENABLED=true`).

### Confidence-Gated Decisions (Jev)
Both AI decision points follow the same pattern: act automatically only above a confidence threshold, route everything uncertain to a slower but safer path, and treat any model failure as "no decision":

| Decision | Confident | Uncertain | Model unavailable |
|---|---|---|---|
| PillBot routing | Use Jev's intent (≥ 0.7) | Gemini router | Gemini router |
| Content moderation | Publish (`ok` ≥ 0.7) or reject (≥ 0.85) | Hold for an admin | Publish |

### In-App Nudge Engine (max 3/session)
Priority-ordered contextual slide-up cards injected into the `RootScreen` overlay:

| Priority | Nudge | Condition |
|---|---|---|
| 1 | Donation Approved | Any approved pending donation |
| 2 | Medicines Expiring | `expiringSoonCount` > 0 |
| 3 | Donation Pending | Pending > 2 days old |
| 4 | Find Centers Near You | First time only (persisted) |
| 5 | Explore Health Blogs | First time only (persisted) |
| 6 | Donate Unused Medicines | First time + no donations yet |

Nudges auto-dismiss after 6 s, support swipe-to-dismiss, and tap actions navigate directly to the relevant screen.

---

## 🗄️ Database Schema

```
User ──< Medicine >── FamilyMember (optional tag)
User ──< FamilyMember
User ──< DonationRequest >── MedicalCenter
User ──< CenterReview >── MedicalCenter
User ──< Notification
User ──< DeviceToken
User ──< Blog ──< Comment
            └──< Like
Chat (Redis 24h) ── userId ──> SQLite archive
Uploaded documents ── chunks ──> ChromaDB
```

| Model | Key fields |
|---|---|
| `User` | `email`, `role` (`user` / `vendor` / `admin`), `stats`, `badges`, `savedMedicalCenters` |
| `Medicine` | `userId`, `name`, `expiryDate`, `status`, `isDeleted`, `familyMemberId`, `isRecurring`, `refillIntervalDays`, `nextRefillAt` |
| `FamilyMember` | `userId`, `name`, `relation` |
| `DonationRequest` | `userId`, `medicalCenterId`, `medicines[]`, `status`, `statusHistory[]`, `medicinePhotos[]` |
| `MedicalCenter` | `name`, `location` (GeoJSON, `2dsphere`), `facilityType`, `isVendorManaged`, `verificationStatus`, `inventory[]`, `ratingSum`, `totalReviews`, `weightedRating` |
| `CenterReview` | `userId`, `medicalCenterId`, `donationRequestId` (unique), `rating`, `comment`, `moderationStatus` |
| `Notification` | `userId`, `type`, `title`, `description`, `status`, `dedupKey` (unique, sparse), `isRead` — 60-day TTL |
| `Blog` | `author`, `content`, `role`, `images[]`, `likesCount`, `commentsCount`, `moderationStatus` |
| `Comment` | `blog`, `author`, `content`, `moderationStatus` |

---

## 📱 App Screens

| Screen | Description |
|---|---|
| **Auth** | Email OTP (paste-friendly 6-box input) or Google Sign-In |
| **Home** | Dashboard — expiry summary, quick actions, nudge overlay |
| **Medicine Inventory** | Active / expiring / expired tabs, family profile switcher, centers-need banner |
| **Add / Edit Medicine** | Full metadata, photo, refill reminder, family member picker |
| **Manage Family** | Add and remove family members |
| **Deleted Bin** | Soft-deleted medicines with hard-delete and restore |
| **Donation** | Submit request to nearby centers, track status pipeline |
| **My Donations** | Grouped by status: Pending → Approved → Completed / Rejected |
| **Handover Code** | Auto-refreshing QR the donor shows at the counter |
| **Donation Receipt** | Shareable receipt image with a public verification QR |
| **Vendor Scanner** | Camera scanner that completes a donation on scan |
| **Locations** | Geo-search map + list with facility filter and Verified badges |
| **Blogs** | Community feed, create post with media, like and comment; own held posts marked *Under review* |
| **PillBot** | Multi-agent AI chatbot with persistent chat history |
| **Notifications** | Inbox with bulk clear and individual dismiss |
| **Profile & Settings** | Stats, badges, saved centers, notifications-off warning, privacy, help, about |
| **My Impact** | Disposal stats and badges, shareable impact card |
| **Vendor Dashboard** | Center management, image gallery, donation request inbox, analytics |

Admin tasks (center verification, moderation queue) are done through the admin API; there is no admin screen in the app.

---

## 🔒 Security

| Concern | Implementation |
|---|---|
| Authentication | Email OTP or Google — no passwords stored |
| Google tokens | ID token verified server-side; Firebase config files gitignored |
| Token strategy | Short-lived JWT access token + refresh token rotation |
| OTP abuse | 5 requests / 10 min per email and 30 / 10 min per IP (`express-rate-limit`, IPv6-safe) |
| Role enforcement | Middleware guards: `requireVendor`, `requireAdmin`; the agent re-checks the role with the Node API instead of trusting the client |
| Ownership checks | A submitted `familyMemberId` must belong to the caller; blog edits accept only whitelisted fields, so authors can't change `author`, counts or moderation status |
| Handover tokens | Separate `typ: "handoff"` claim, 5-minute TTL — never accepted as a session token |
| Receipt verification | Public page exposes only center, date and counts — no donor details |
| User content | Jev moderation on create and edit; dangerous medical advice is always held for a human |
| AI safety | PillBot won't diagnose or give dosing advice; emergencies get a "seek care now" instruction first |
| Secrets | Maps key injected at build time from `local.properties`; `.env` files gitignored |
| Image upload | Cloudinary CDN, validated via Multer before storage |

---

## 🚢 Deployment

Both backends ship as Docker images on **Render**.

| Service | Root Directory | Notes |
|---|---|---|
| Server | `server` | `node:22-alpine`, `npm ci --omit=dev` |
| Agent | `agno_agent` | `python:3.11-slim`, single uvicorn worker |

The agent **requires a persistent disk mounted at `/data`** — ChromaDB and SQLite write there, and Render's container filesystem is wiped on every redeploy. Without it the knowledge base and chat archive are lost on restart. One worker is deliberate: both stores are instance-local and don't tolerate concurrent writers.

Jev is off until `JEV_ENABLED=true` is set on each service. Both services fall back safely while it is off, so it can be enabled independently.

```bash
# seed & maintenance scripts (server/)
node scripts/seedDonations.js --count=60 --months=6
node scripts/seedNotifications.js --count=45
node scripts/backfillRatingCounters.js      # run once after deploying reviews
node scripts/verifyAllCenters.js --dry-run  # dev only: approve pending centers
```

---

## 🧪 Testing

```bash
# Agent endpoint tests
cd agno_agent
python test_endpoints.py
python test_client.py

# Flutter widget tests
cd app
flutter test
```

Flutter tests cover the donation receipt (layout survives 1, 14 and 34 medicines, and the receipt-number formula matches the server's) and the medicine inventory card layout. The Jev router and the moderation pipeline were verified against live Jev and the database during development; turning those checks into an automated suite, and adding one for the Node.js backend, is the next step.

---

## 📄 License

MIT © 2025 — feel free to fork and build on top of this.
