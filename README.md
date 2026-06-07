<div align="center">

# 💊 PillBin

### Smart, offline-first medicine management — track, donate, and dispose responsibly

[![Flutter](https://img.shields.io/badge/Flutter-3.4.4-02569B?logo=flutter)](https://flutter.dev) [![Node.js](https://img.shields.io/badge/Node.js-20-339933?logo=nodedotjs)](https://nodejs.org) [![FastAPI](https://img.shields.io/badge/FastAPI-Python-009688?logo=fastapi)](https://fastapi.tiangolo.com) [![MongoDB](https://img.shields.io/badge/MongoDB-8.x-47A248?logo=mongodb)](https://mongodb.com) [![Agno](https://img.shields.io/badge/Agno-Multi--Agent-FF6B35?logo=openai)](https://github.com/agno-agi/agno) [![Azure](https://img.shields.io/badge/Azure-Hosted-0078D4?logo=microsoftazure)](https://azure.microsoft.com)

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

### 🏢 Vendor Portal

Medical centers onboard as **Vendors**. After registration, a center goes through admin verification before appearing in the user-facing location list. The vendor dashboard provides:

- **Center profile management** — name, address, facility type, operating hours, accepted medicine categories, ratings
- **Image gallery** — upload up to 3 center photos (Cloudinary + `CachedNetworkImage` with shimmer loading)
- **Verification document upload** — up to 5 documents for admin review
- **Inventory management** — what medicine types the center currently accepts
- **Donation request inbox** — view all incoming requests, approve / reject with a note, mark as completed

Vendor routes are guarded by the `requireVendor` middleware — the `role` field on the `User` model must be `"vendor"`.

---

### 🤖 PillBot — Multi-Agent AI Chatbot

PillBot is built on the **Agno** multi-agent framework and is the most technically complex feature in PillBin. It exposes a **FastAPI** endpoint that the Flutter app calls with user queries and a `userId` for session continuity.

The agent pipeline:
1. **Query intake** — user message received by FastAPI, `userId` resolved to a Redis chat history key
2. **RAG retrieval** — query embedded and searched against a **Pinecone** vector index containing chunked medical PDFs, returning the top-k relevant passages
3. **Web search** — DuckDuckGo search tool activated for real-time health information not covered by static PDFs
4. **MCP tooling** — Model Context Protocol server tools extend the agent with structured capabilities
5. **LLM reasoning** — Agno orchestrates the above context sources and sends a final prompt to **OpenAI** models for a grounded, safe response
6. **Response + caching** — the response is streamed back to the app and the turn is appended to the **Redis**-backed chat history for the session

Chat history is persisted per `userId`, providing continuity across app sessions.

---

### 📍 Location-Based Services

Users can discover nearby medical and disposal centers using **MongoDB `$geoNear`** geospatial queries. The default search radius is **10 km** and is customizable. Results can be filtered by facility type:

- `Hospital`, `Clinic`, `Pharmacy`, `Health Center`

Each center card shows: operating hours, accepted medicine types, ratings, an image gallery, and a direct-call button. Only **admin-approved** centers appear in this list — centers awaiting verification are invisible to users.

Users can **save** centers to a personal list (`savedMedicalCenters` on the `User` model) and access them quickly from their profile.

---

### 🔔 Smart Notification System

PillBin has a server-side notification model (`Notification` collection) with 4 priority levels — `Normal`, `Important`, `Urgent`, `Alert`. Notifications are delivered in-app and via **Flutter Local Notifications**:

| Type | Trigger | Schedule | Priority |
|---|---|---|---|
| Welcome | Signup completion | Instant | Normal |
| Medicine Expiry | Expires within 5 days | Daily 9 AM | Urgent |
| Custom Alerts | Admin / system events | Instant | Varies |

The inbox stores the **last 50 notifications** with auto-cleanup. Users can dismiss individually or bulk-clear with one tap.

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

PillBin uses **passwordless email OTP** authentication:
1. User enters email → OTP sent via `Nodemailer` / `Resend`
2. OTP verified → JWT **access token** (3h) + **refresh token** issued
3. Refresh endpoint rotates both tokens transparently

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
        │   └── vector_store.py
        ├── models/schemas.py
        ├── routes/
        └── services/
            ├── agent_service.py      # Agno multi-agent logic
            ├── redis_service.py      # Chat history caching
            └── vector_store.py       # Pinecone operations
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
| Typography | Poppins (custom font) |

### Backend
| Layer | Technology |
|---|---|
| Runtime | Node.js 20 |
| Framework | Express 5.1 |
| Database | MongoDB 8.x + Mongoose |
| Auth | JWT (access + refresh tokens) |
| File Storage | Cloudinary + Multer |
| Email OTP | Nodemailer / Resend |
| AI (blog images) | Gemini via `@google/genai` |
| Rate Limiting | express-rate-limit |

### AI Agent
| Layer | Technology |
|---|---|
| Runtime | Python 3.10+ |
| API Server | FastAPI + Uvicorn |
| Agent Framework | Agno (multi-agent orchestration) |
| LLM | OpenAI models |
| Vector Search | Pinecone (RAG over medical PDFs) |
| Chat Cache | Redis |
| Web Search | DuckDuckGo Search tool |
| Production Server | Gunicorn |

### Data & Infrastructure
| Service | Purpose |
|---|---|
| MongoDB | Primary DB with geospatial indexing |
| Pinecone | Vector store for RAG |
| Redis | Agent session / chat history cache |
| Cloudinary | Medical center image CDN |
| Azure | Backend + AI agent hosting |
| Docker | Containerization |

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
│       │  Agno    │   │   Pinecone   │  │  Redis  │        │
│       │ (Agents) │   │ Vector Store │  │ (Cache) │        │
│       └────┬─────┘   └──────────────┘  └─────────┘        │
│            │                                                │
│     ┌──────┴──────┐                                        │
│     ▼             ▼                                        │
│  ┌───────┐  ┌──────────┐                                   │
│  │OpenAI │  │MCP Server│                                   │
│  │Models │  │ Tooling  │                                   │
│  └───────┘  └──────────┘                                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK** 3.4.4+, **Dart** 3.x
- **Node.js** 20.x+
- **Python** 3.10+
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
OPENAI_API_KEY="your_openai_api_key"
PINECONE_API_KEY="your_pinecone_api_key"
PINECONE_INDEX_NAME="your_index_name"
REDIS_URL="your_redis_url"
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
BASE_URL=http://your-backend-url.com
AGENT_URL=http://your-agent-url.com
```

```bash
flutter run
```

---

## 📡 REST API Reference

All protected routes require `Authorization: Bearer <access_token>`.

### Auth
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/auth/signup` | Request OTP for new account |
| `POST` | `/api/auth/verify-signup` | Verify OTP, create account |
| `POST` | `/api/auth/signin` | Request OTP for existing account |
| `POST` | `/api/auth/verify-signin` | Verify OTP, receive tokens |
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
| `GET` | `/api/notifications/` | Get user notifications |
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
Chat (Redis) ── userId
Rag ── document chunks → Pinecone
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
| Authentication | Email OTP — no passwords stored |
| Token strategy | Short-lived JWT access token + refresh token rotation |
| OTP abuse | `express-rate-limit` — 10 requests per 10 minutes per phone / IP |
| Role enforcement | Middleware guards: `requireVendor`, `requireAdmin` |
| Image upload | Cloudinary CDN, validated via Multer before storage |
| Soft delete | Medicines are soft-deleted before permanent removal; 100-item history cap |

---

## 🧪 Testing

```bash
# Agent endpoint tests
cd agno_agent
python test_endpoints.py
python test_client.py

# MCP tooling test
python test_mcp.py
```

No automated test suite exists yet for the Flutter app or Node.js backend — contributions welcome.

---

## 📄 License

MIT © 2025 — feel free to fork and build on top of this.
