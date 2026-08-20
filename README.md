<div align="center">

# 💊 PillBin

### Smart, offline-first medicine management — track, donate, and dispose responsibly

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

**PillBin** is a comprehensive, offline-first medicine management application built for both patients and medical centers. Users can track medicines, receive smart expiry alerts, discover nearby disposal centers, donate unused medicines, and get AI-powered health insights — all from a single app.

The platform connects users with **verified vendor centers** through a full donation and approval pipeline, enriched with contextual in-app nudges, a community blog, and **PillBot** — a multi-agent AI chatbot powered by the Agno framework with RAG over medical PDFs.

---

### 📦 Medicine Inventory Management

At its core, PillBin is a smart medicine cabinet. Users can add medicines with full metadata — `name`, `dosage`, `batch number`, `manufacturer`, `type`, `purchase date`, `expiry date`, `notes`, and even an optional photo. The system auto-classifies each medicine into one of three live states:

- **Active** — more than 5 days until expiry, shown in green
- **Expiring Soon** — 5 days or fewer until expiry, shown in amber with a daily 9 AM push notification
- **Expired** — past expiry date, shown in red with a one-tap bulk-clear action

Medicines are **soft-deleted** first (moved to a "Deleted Bin" with up to 100-item history), then permanently wiped on demand or auto-cleaned after 15 days. A per-account cap of **100 active medicines** keeps queries performant. Each medicine also stores product links to external pharmacy sites (`Tata 1mg`, `PharmEasy`, `Netmeds`) for quick reordering.

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

Both are maintained as **running counters** (`ratingSum`, `totalReviews`, `ratingBreakdown`) updated with a single `$inc` per write — no aggregation, so the cost is flat whether a center has 10 reviews or 10 million. Reviews paginate with a **server-side star filter**, so filtering searches every review rather than the loaded page.

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

Donors get an impact screen summarising what they've contributed — medicines donated, centers helped, and completion streaks — plus a per-request **status timeline** rendered from `statusHistory`, so every state change is visible with its timestamp.

---

### 🤖 PillBot — Multi-Agent AI Chatbot

PillBot is built on the **Agno** multi-agent framework and is the most technically complex feature in PillBin. It exposes a **FastAPI** endpoint that the Flutter app calls with user queries and a `userId` for session continuity.

The agent pipeline:
1. **Query intake** — user message received by FastAPI, `userId` resolved to a Redis chat history key
2. **Intent routing** — a fast, cheap model classifies the query and picks exactly one specialist path, so a simple question never pays for the full toolchain
3. **RAG retrieval** — query embedded with Gemini and searched against a **ChromaDB** hybrid index (vector + keyword, RRF-fused) over chunked medical PDFs
4. **Live tools** — inventory, directory, donation, vendor and notification tools call the Node API so answers reflect the user's real data
5. **Web search** — DuckDuckGo for health information not covered by the indexed PDFs
6. **LLM reasoning** — Agno composes the context and answers via **Gemini** (or **Groq**, switchable through `LLM_PROVIDER`)
7. **Two-tier history** — recent turns live in **Redis** with a 24h TTL, older ones fall back to **SQLite**, paged 40 messages at a time

Chat history is persisted per `userId`, providing continuity across app sessions.

---

### 📍 Location-Based Services

Users can discover nearby medical and disposal centers using **MongoDB `$geoNear`** geospatial queries. The default search radius is **10 km** and is customizable. Results can be filtered by facility type:

- `Hospital`, `Clinic`, `Pharmacy`, `Health Center`

Each center card shows: operating hours, accepted medicine types, ratings, an image gallery, and a direct-call button. Only **admin-approved** centers appear in this list — centers awaiting verification are invisible to users.

Users can **save** centers to a personal list (`savedMedicalCenters` on the `User` model) and access them quickly from their profile.

---

### 🔔 Smart Notification System

PillBin has a server-side notification model (`Notification` collection) with 4 priority levels — `Normal`, `Important`, `Urgent`, `Alert`. Delivery is **Firebase Cloud Messaging** push plus an in-app inbox, with device tokens registered per install (`DeviceToken`) and deactivated on logout.

| Type | Trigger | Schedule | Priority |
|---|---|---|---|
| Welcome | Signup completion | Instant | Normal |
| Medicine Expiry | Expires within 5 days | Daily 9 AM (`node-cron`) | Urgent |
| Donation Updates | Submitted / approved / completed / cancelled | Instant | Important |
| Custom Alerts | Admin / system events | Instant | Varies |

The inbox is **paginated 20 at a time** with infinite scroll, and a **60-day TTL index** ages rows out automatically. The unread badge reads a server-side `countDocuments` rather than the loaded page, so it stays correct past page one.

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
- **AI-generated blog images** — a dedicated `/api/blogs/generate/image` endpoint uses **Gemini** (`@google/genai`) to generate a relevant cover image from the blog title
- Like posts (toggle), view likers, add / edit / delete comments
- Personal feed showing only your own posts

---

### 💾 Offline-First Architecture

Every API response that the app fetches is saved to a **custom TTL cache** built on `FlutterSecureStorage`, covering 11 distinct data types (inventory, donations, centers, notifications, profile, etc.). On every subsequent load:

1. **Cache hit** — serve data instantly, no spinner shown
2. **Cache miss / expired** — call API, refresh cache, update UI
3. **Network error** — fall back to stale cache, show connectivity banner

TTL is **24 hours**. `Connectivity Plus` monitors network state in real time; the app syncs in the background as soon as connectivity is restored.

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

OTP requests are rate-limited to **10 per 10 minutes** per email / IP via `express-rate-limit`. Three roles exist — `user`, `vendor`, `admin` — each enforced by dedicated middleware (`requireVendor`, `requireAdmin`) on all sensitive routes.

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
│   │   ├── adminController.js        # Center approval / rejection
│   │   ├── authController.js
│   │   ├── blogController.js
│   │   ├── donationController.js
│   │   ├── medicalCenterController.js
│   │   ├── medicineController.js
│   │   ├── notificationController.js
│   │   └── vendorController.js
│   ├── models/
│   ├── routes/
│   ├── middleware/
│   ├── services/
│   ├── server.js
│   └── Dockerfile
│
└── agno_agent/                       # Python AI Agent
    └── backend/
        ├── config/
        │   ├── redis_client.py
        │   ├── redis_client.py
        │   ├── sqlite_client.py
        │   └── chat_repository.py    # Redis hot tier → SQLite archive
        ├── models/schemas.py
        ├── routes/
        ├── tools/                    # inventory, directory, donation, vendor
        └── services/
            ├── agent_service.py      # two-stage intent router
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
| AI (blog images) | Gemini via `@google/genai` |
| Rate Limiting | express-rate-limit |

### AI Agent
| Layer | Technology |
|---|---|
| Runtime | Python 3.11 |
| API Server | FastAPI + Uvicorn |
| Agent Framework | Agno (two-stage intent router) |
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
| Render | Server + agent hosting (Docker) |

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                      PILLBIN ECOSYSTEM                       │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐          ┌───────────────┐                │
│  │  Flutter App │◄────────►│  Node.js API  │                │
│  │  (Mobile)    │          │  (Express)    │                │
│  └──────┬───────┘          └───────┬───────┘                │
│         │                          │                         │
│         │                  ┌───────┴────────┐               │
│         │                  │    MongoDB     │               │
│         │                  │  + Cloudinary  │               │
│         │                  └────────────────┘               │
│         │                                                    │
│         └──────────────────────┐                            │
│                                ▼                            │
│                      ┌─────────────────┐                    │
│                      │  Python Agent   │                    │
│                      │   (FastAPI)     │                    │
│                      └───────┬─────────┘                    │
│                              │                              │
│              ┌───────────────┼───────────────┐             │
│              ▼               ▼               ▼             │
│       ┌──────────┐   ┌──────────────┐  ┌─────────┐        │
│       │  Agno    │   │   ChromaDB   │  │  Redis  │        │
│       │ (Router) │   │ Hybrid Vector│  │ + SQLite│        │
│       └────┬─────┘   └──────────────┘  └─────────┘        │
│            │                                                │
│     ┌──────┴──────┐                                        │
│     ▼             ▼                                        │
│  ┌───────┐  ┌──────────┐                                   │
│  │Gemini │  │  Node    │                                   │
│  │/ Groq │  │API Tools │                                   │
│  └───────┘  └──────────┘                                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
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

Edit `.env`:

```env
PORT=5000
NODE_ENV=development
MONGODB_URI="mongodb://localhost:27017/pillbin"
JWT_SECRET="your_jwt_secret_min_32_chars"
JWT_REFRESH_SECRET="your_refresh_secret"
JWT_EXPIRES_IN=3h
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
GEMINI_API_KEY="your_gemini_api_key"
CLOUDINARY_CLOUD_NAME="your_cloud_name"
CLOUDINARY_API_KEY="your_cloudinary_key"
CLOUDINARY_API_SECRET="your_cloudinary_secret"
ADMIN="your_admin_secret_key"

# Google Sign-In — the OAuth **Web** client ID, not the Android one
GOOGLE_CLIENT_ID="xxxxx.apps.googleusercontent.com"

# Firebase Cloud Messaging
FIREBASE_PROJECT_ID="your_project_id"
FIREBASE_CLIENT_EMAIL="firebase-adminsdk@your-project.iam.gserviceaccount.com"
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----
...
-----END PRIVATE KEY-----
"
```

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
```

Edit `agno_agent/.env`:

```env
LLM_PROVIDER=gemini                 # or "groq"
GEMINI_API_KEY="your_gemini_api_key"
GROQ_API_KEY="your_groq_api_key"    # only if LLM_PROVIDER=groq

REDIS_URL="redis://localhost:6379"
CHROMA_PATH="tmp/chromadb"          # /data/chromadb in Docker
SQLITE_PATH="tmp/pillbin.db"        # /data/pillbin.db in Docker

NODE_JS_BASE_URL="http://localhost:5000"
CORS_ORIGINS="*"
```

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

Create `app/.env`:

```env
AUTH_TOKEN_KEY=...
REFRESH_TOKEN_KEY=...
USER_DATA_KEY=...
SESSION=...
GMAIL_MAIL=...
GMAIL_PASSWORD=...

# same Web client ID the server uses
GOOGLE_SERVER_CLIENT_ID="xxxxx.apps.googleusercontent.com"
```

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

All protected routes require `Authorization: Bearer <access_token>`. List endpoints are paginated with `?page=&limit=` and return a `pagination` block.

### Auth
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/auth/signup` | Request OTP for new account |
| `POST` | `/api/auth/verify-signup` | Verify OTP, create account |
| `POST` | `/api/auth/signin` | Request OTP for existing account |
| `POST` | `/api/auth/verify-signin` | Verify OTP, receive tokens |
| `POST` | `/api/auth/google` | Sign in / up with a Google ID token |
| `POST` | `/api/auth/refresh-token` | Rotate access token |

### Medicines
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/medicines/add` | Add medicine (with optional photo) |
| `GET` | `/api/medicines/inventory` | Get active inventory |
| `GET` | `/api/medicines/deleted-inventory` | Get soft-deleted medicines |
| `PUT` | `/api/medicines/update/:medicineId` | Update medicine details |
| `DELETE` | `/api/medicines/delete/:medicineId` | Soft-delete medicine |
| `DELETE` | `/api/medicines/delete-all-expired` | Bulk soft-delete all expired |
| `DELETE` | `/api/medicines/delete/:medicineId/hard` | Permanently delete medicine |
| `DELETE` | `/api/medicines/delete-all-hard` | Permanently wipe deleted bin |

### Donations
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/donations/` | Submit donation request (with photos) |
| `GET` | `/api/donations/my-requests` | Get user's donation history |
| `GET` | `/api/donations/:id` | Get single donation request |
| `DELETE` | `/api/donations/:id` | Cancel pending request |
| `POST` | `/api/donations/:id/review` | Rate a completed donation |
| `DELETE` | `/api/donations/review/:reviewId` | Delete your own review |
| `GET` | `/api/donations/center/:centerId/reviews` | Center reviews — paginated, `?rating=` filter |
| `GET` | `/api/donations/:id/handoff-token` | Mint the 5-minute QR token for an approved donation |
| `GET` | `/api/donations/verify/:id` | **Public** — HTML page verifying a shared receipt |

### Medical Centers
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/medical-centers/nearby` | Geo-search nearby centers |
| `GET` | `/api/medical-centers/search` | Search centers by name/type |
| `GET` | `/api/medical-centers/all` | List all approved centers |
| `GET` | `/api/medical-centers/:id` | Get center details |
| `GET` | `/api/medical-centers/:id/inventory` | Get center's accepted inventory |

### Blogs
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/blogs/` | Get all community blogs |
| `GET` | `/api/blogs/user` | Get current user's blogs |
| `GET` | `/api/blogs/:id` | Get single blog post |
| `POST` | `/api/blogs/` | Create blog post (with media) |
| `PUT` | `/api/blogs/:id` | Update blog post |
| `DELETE` | `/api/blogs/:id` | Delete blog post |
| `POST` | `/api/blogs/:id/likes` | Toggle like |
| `POST` | `/api/blogs/:id/comments` | Add comment |
| `PUT` | `/api/blogs/:id/comments/:commentId` | Edit comment |
| `DELETE` | `/api/blogs/:id/comments/:commentId` | Delete comment |

### Notifications
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/notifications/` | Get notifications — `?page=&limit=` |
| `POST` | `/api/notifications/` | Add notification |
| `DELETE` | `/api/notifications/:notificationId` | Dismiss one notification |
| `DELETE` | `/api/notifications/` | Clear all notifications |

### Vendor (role: `vendor`)
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/vendor/register-center` | Register medical center |
| `GET` | `/api/vendor/my-center` | Get vendor's center details |
| `PUT` | `/api/vendor/my-center` | Update center profile |
| `PUT` | `/api/vendor/my-center/images` | Upload center photos |
| `PUT` | `/api/vendor/inventory` | Update accepted medicine inventory |
| `POST` | `/api/vendor/verify-documents` | Upload verification documents |
| `GET` | `/api/vendor/requests` | View incoming donation requests |
| `PUT` | `/api/vendor/requests/:id` | Approve / reject with note |
| `PUT` | `/api/vendor/requests/:id/complete` | Mark donation as completed |
| `POST` | `/api/vendor/scan` | Complete a donation from a scanned handover token |
| `GET` | `/api/vendor/analytics` | KPIs, timeline & top medicines — `?months=6,12,24,60` |
| `GET` | `/api/vendor/donated-medicines` | Ranked medicine totals, paginated |

### Admin (role: `admin`)
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/admin/verifications` | Get pending center verifications |
| `PUT` | `/api/admin/verifications/:centerId/approve` | Approve vendor center |
| `PUT` | `/api/admin/verifications/:centerId/reject` | Reject vendor center |

### User Profile
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/users/profile` | Get full profile |
| `POST` | `/api/users/complete-profile` | Complete onboarding profile |
| `PUT` | `/api/users/edit-profile` | Edit profile details |
| `POST` | `/api/users/save-medical-center` | Save a center as favourite |
| `DELETE` | `/api/users/remove-saved-medical-center` | Remove saved center |
| `GET` | `/api/users/saved-medical-centers` | List saved centers |

---

## 🧮 Core Algorithms

### TTL Cache Layer (Offline-First)
The Flutter app implements a custom **11-type TTL cache** using `FlutterSecureStorage`:
1. On every API call, check cache first — serve immediately if valid
2. On cache miss or expiry, hit the API and refresh the cache
3. On network error, fall back to stale cache (no hard failure)

Cache TTL is **24 hours** with background sync on reconnect. Connectivity state is monitored via `Connectivity Plus`.

### Medicine Status Engine
Statuses are computed dynamically from `expiryDate`:
- `active` — more than 5 days until expiry
- `expiring_soon` — ≤ 5 days until expiry (triggers push alert at 9 AM daily)
- `expired` — past expiry date

A scheduled job (`/api/medicines/update-statuses`) recalculates all statuses and auto-cleans medicines expired for more than 15 days.

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
User ──< Medicine
User ──< DonationRequest >── MedicalCenter
User ──< Notification
User ──< Blog ──< Comment
                  └──< Like
MedicalCenter ──< DonationRequest
User ──< CenterReview >── MedicalCenter
User ──< DeviceToken
Chat (Redis 24h) ── userId ──> SQLite archive
Rag ── document chunks → ChromaDB
```

| Model | Key fields |
|---|---|
| `User` | `id`, `email`, `phoneNumber`, `role`, `stats`, `badges`, `savedMedicalCenters` |
| `Medicine` | `id`, `userId`, `name`, `expiryDate`, `status`, `batchNumber`, `isDeleted` |
| `DonationRequest` | `id`, `userId`, `medicalCenterId`, `medicines[]`, `status`, `medicinePhotos[]` |
| `MedicalCenter` | `id`, `name`, `location` (GeoJSON), `facilityType`, `isApproved`, `images[]` |
| `Notification` | `id`, `userId`, `message`, `priority`, `createdAt` |
| `Blog` | `id`, `authorId`, `title`, `content`, `media[]`, `likesCount` |
| `Comment` | `id`, `blogId`, `userId`, `text` |
| `Chat` | `id`, `userId`, `messages[]` (Redis-backed) |

---

## 📱 App Screens

| Screen | Description |
|---|---|
| **Auth** | Email OTP signup / signin with rate limiting |
| **Home** | Dashboard — expiry summary, quick actions, nudge overlay |
| **Medicine Inventory** | Active / expiring / expired tabs, add and edit medicines |
| **Deleted Bin** | Soft-deleted medicines with hard-delete and restore |
| **Donation** | Submit request to nearby centers, track status pipeline |
| **My Donations** | Grouped by status: Pending → Approved → Completed / Rejected |
| **Handover Code** | Auto-refreshing QR the donor shows at the counter |
| **Donation Receipt** | Shareable receipt image with a public verification QR |
| **Vendor Scanner** | Camera scanner that completes a donation on scan |
| **Locations** | Geo-search map + list with filter by facility type |
| **Blogs** | Community feed, create post with media, like and comment |
| **PillBot** | Multi-agent AI chatbot with persistent chat history |
| **Notifications** | Inbox with bulk clear and individual dismiss |
| **Profile** | Stats, badges, medical conditions, saved centers |
| **Vendor Dashboard** | Center management, image gallery, donation request inbox |
| **Admin Panel** | Pending center verifications — approve or reject |

---

## 🔒 Security

| Concern | Implementation |
|---|---|
| Authentication | Email OTP or Google — no passwords stored |
| Google tokens | ID token verified server-side; Firebase config files gitignored |
| Token strategy | Short-lived JWT access token + refresh token rotation |
| OTP abuse | `express-rate-limit` — 10 requests per 10 minutes per phone / IP |
| Role enforcement | Middleware guards: `requireVendor`, `requireAdmin` |
| Handover tokens | Separate `typ: "handoff"` claim, 5-minute TTL — never accepted as a session token |
| Receipt verification | Public page exposes only center, date and counts — no donor details |
| Image upload | Cloudinary CDN, validated via Multer before storage |
| Soft delete | Medicines are soft-deleted before permanent removal; 100-item history cap |

---

## 🚢 Deployment

Both backends ship as Docker images on **Render**.

| Service | Root Directory | Notes |
|---|---|---|
| Server | `server` | `node:22-alpine`, `npm ci --omit=dev` |
| Agent | `agno_agent` | `python:3.11-slim`, single uvicorn worker |

The agent **requires a persistent disk mounted at `/data`** — ChromaDB and SQLite write there, and Render's container filesystem is wiped on every redeploy. Without it the knowledge base and chat archive are lost on restart. One worker is deliberate: both stores are instance-local and don't tolerate concurrent writers.

```bash
# seed & maintenance scripts
node scripts/seedDonations.js --count=60 --months=6
node scripts/seedNotifications.js --count=45
node scripts/backfillRatingCounters.js      # run once after deploying reviews
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

Flutter coverage is currently limited to the donation receipt — it checks the layout survives 1, 14 and 34 medicines, and pins the receipt-number formula to the one the server uses. The Node.js backend has no automated suite yet — contributions welcome.

---

## 📄 License

MIT © 2025 — feel free to fork and build on top of this.
