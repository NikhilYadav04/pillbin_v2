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

Key highlights:
- **Offline-first** with a custom 11-type TTL cache layer and 3-priority fallback
- **Role-based** flows for Users, Vendors, and Admins
- **Geospatial** center discovery via MongoDB `$geoNear`
- **Multi-agent AI** with Pinecone RAG, web search, Redis chat history, and MCP tooling

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
