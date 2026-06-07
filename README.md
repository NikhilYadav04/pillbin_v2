# 💊 PillBin - Smart Medicine Management System

---

## 🌟 About PillBin

**PillBin** is a comprehensive, offline-first medicine management application that helps users track medicines, receive expiry alerts, find nearby disposal centers, donate unused medicines, and get AI-powered health insights. Built for both patients and medical centers, PillBin connects users with verified vendor centers through a full donation and approval pipeline — with intelligent in-app nudges, community blogs, and a multi-agent AI chatbot powered by Agno.

---

## 🖼️ Screenshots

<img width="1311" height="568" alt="Screenshot 2025-12-05 142750" src="https://github.com/user-attachments/assets/6ff038f3-fe9b-4dae-8c98-863b130d14cb" />

<img width="1322" height="531" alt="Screenshot 2025-12-05 142807" src="https://github.com/user-attachments/assets/180f3b38-dd99-45ae-8067-d8f422d13cb0" />

---

## ✨ Key Features

### 📦 **Medicine Inventory Management**
- ✅ Add, edit, and delete medicines with full details (dosage, batch, manufacturer)
- ✅ Smart categorization: Active, Expiring Soon (5-day alert), Expired
- ✅ Soft delete with recovery — history of up to 100 deleted items
- ✅ Bulk operations: clear all expired medicines at once
- ✅ 100 medicines per account for optimal performance

### 🏥 **Donation System**
- 💊 Submit medicine donation requests to nearby medical centers
- 📸 Attach medicine photos to donation requests
- 📋 Track status: Pending → Approved → Completed / Rejected
- 📞 Call center directly once donation is approved
- 🔍 Search donations by medicine name or center, grouped by status
- ❌ Cancel pending requests

### 🏢 **Vendor Portal**
- 🏥 Medical center onboarding and registration
- 📊 Vendor dashboard with stats, image gallery, and verification status
- 📥 Manage incoming donation requests (approve / reject with notes)
- 🖼️ Upload and display center photos (Cloudinary + CachedNetworkImage)
- 📦 Vendor inventory management
- ✅ Admin approval workflow — centers verified before appearing to users

### 📝 **Community Blogs**
- 📰 Browse all community health blogs
- ✍️ Create, edit, and delete your own posts
- ❤️ Like and comment on posts
- 👤 Personal blog feed

### 🔔 **Smart Notification System**
- 🎉 Welcome notification on signup
- ⏰ Medicine expiry alerts — daily at 9 AM for medicines expiring within 5 days
- 🔕 Priority levels: Normal, Important, Urgent, Alert
- 📊 Last 50 notifications with auto-cleanup
- 🗑️ Bulk clear or individual dismiss

### 💬 **In-App Nudge System**
- 🎯 Contextual slide-up cards based on real user data — max 3 per session
- 🏆 Priority-ordered: donation approvals → expiry alerts → pending reminders → feature discovery
- 🔁 One-time feature discovery nudges (persisted, never repeated)
- 👆 Swipe to dismiss, tap action to navigate, auto-dismiss after 6s

### 🤖 **PillBot — Multi-Agent AI Chatbot**
- 🧠 Powered by **Agno** multi-agent framework with **OpenAI** models
- 🔍 **RAG** over medical PDFs via **Pinecone** vector search
- 🌐 Web search integration for real-time health information
- 🔌 **MCP server** tooling for extended agent capabilities
- 💬 Context-aware health and medicine queries
- 🗂️ Chat history with **Redis** caching

### 📍 **Location-Based Services**
- 🗺️ Nearby medical/disposal centers via **MongoDB $geoNear**
- 📏 Radius-based search (default 10km, customizable)
- 🔎 Filter by facility type: Hospital, Clinic, Pharmacy, Health Center
- 🕒 Operating hours, accepted medicine types, ratings
- 🖼️ Center image galleries with CachedNetworkImage
- ✅ Only admin-approved vendor centers shown to users

### 💾 **Offline-First Architecture**
- 📦 Custom **TTL-based cache layer** (FlutterSecureStorage, 11 data types)
- ⚡ 3-priority fallback: cache → API → stale cache on error
- 🔄 24-hour TTL with background sync on reconnect
- 📡 Connectivity detection for seamless offline/online transitions

### 🔐 **Authentication & Security**
- 📧 Email OTP authentication (password-free)
- 🔑 JWT access & refresh tokens
- ⏱️ Rate limiting on OTP (10 requests / 10 minutes)
- 👥 Role-based access: User, Vendor, Admin

### 📱 **Responsive Design**
- 📱 Mobile-first with full tablet adaptive layouts
- 🎨 Custom Poppins font, shimmer loading states, smooth animations

### 📚 **Information & Awareness**
- 📰 Curated articles on medicine disposal best practices
- 🌍 Environmental impact awareness
- 🏢 NGO directory and government disposal programs

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                     PILLBIN ECOSYSTEM                        │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐          ┌───────────────┐               │
│  │  Flutter App │◄────────►│  Node.js API  │               │
│  │  (Mobile)    │          │  (Express)    │               │
│  └──────┬───────┘          └───────┬───────┘               │
│         │                          │                        │
│         │                  ┌───────┴────────┐              │
│         │                  │    MongoDB     │              │
│         │                  │  + Cloudinary  │              │
│         │                  └────────────────┘              │
│         │                                                   │
│         └──────────────────────┐                           │
│                                ▼                           │
│                      ┌─────────────────┐                   │
│                      │  Python Agent   │                   │
│                      │   (FastAPI)     │                   │
│                      └───────┬─────────┘                   │
│                              │                             │
│              ┌───────────────┼───────────────┐            │
│              ▼               ▼               ▼            │
│       ┌──────────┐   ┌──────────────┐  ┌─────────┐       │
│       │  Agno    │   │   Pinecone   │  │  Redis  │       │
│       │ (Agents) │   │ Vector Store │  │ (Cache) │       │
│       └────┬─────┘   └──────────────┘  └─────────┘       │
│            │                                               │
│     ┌──────┴──────┐                                        │
│     ▼             ▼                                        │
│  ┌───────┐  ┌──────────┐                                  │
│  │OpenAI │  │MCP Server│                                  │
│  │Models │  │ Tooling  │                                  │
│  └───────┘  └──────────┘                                  │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### 📂 Project Structure

```
pillbin/
├── app/                              # Flutter Mobile Application
│   ├── lib/
│   │   ├── config/
│   │   │   ├── cache/               # TTL CacheManager (offline-first)
│   │   │   ├── routes/              # Named navigation routes
│   │   │   └── theme/               # Colors, text styles
│   │   ├── core/
│   │   │   ├── nudge/               # In-app nudge engine
│   │   │   └── utils/               # Shimmer, snackbar helpers
│   │   ├── features/
│   │   │   ├── auth/                # OTP authentication
│   │   │   ├── blog/                # Community blogs
│   │   │   ├── donation/            # Donation requests & tracking
│   │   │   ├── home/                # Dashboard & quick actions
│   │   │   ├── info/                # Awareness & articles
│   │   │   ├── locations/           # Medical center discovery
│   │   │   ├── medicines/           # Medicine inventory
│   │   │   ├── pillbot/             # Multi-agent AI chatbot
│   │   │   ├── profile/             # User profile
│   │   │   └── vendor/              # Vendor portal & dashboard
│   │   ├── network/                 # Dio HTTP client, models
│   │   ├── root_screen.dart         # Bottom nav + nudge overlay
│   │   ├── app.dart
│   │   └── main.dart
│   └── pubspec.yaml
│
├── server/                           # Node.js Backend API
│   ├── controllers/
│   │   ├── adminController.js        # Center approval / rejection
│   │   ├── authController.js
│   │   ├── blogController.js
│   │   ├── chatbotController.js
│   │   ├── commentController.js
│   │   ├── donationController.js
│   │   ├── likeController.js
│   │   ├── medicalCenterController.js
│   │   ├── medicineController.js
│   │   ├── notificationController.js
│   │   ├── ragController.js
│   │   ├── userController.js
│   │   └── vendorController.js
│   ├── models/
│   │   ├── blog.js
│   │   ├── chat.js
│   │   ├── comment.js
│   │   ├── DonationRequest.js
│   │   ├── like.js
│   │   ├── MedicalCenter.js
│   │   ├── Medicine.js
│   │   ├── Notification.js
│   │   ├── rag.js
│   │   └── User.js
│   ├── routes/
│   ├── middleware/
│   ├── services/
│   ├── server.js
│   ├── Dockerfile
│   └── package.json
│
└── Agent/                            # Python AI Agent
    └── app/
        ├── api/endpoints.py
        ├── config1/
        │   ├── redis_client.py
        │   └── vector_store.py
        ├── models/schemas.py
        └── services/
            ├── agent_service.py      # Agno multi-agent logic
            ├── redis_service.py      # Chat history caching
            └── vector_store.py       # Pinecone operations
```

---

## 🛠️ Tech Stack

### 📱 **Mobile App (Flutter)**
| Package | Purpose |
|---|---|
| Flutter 3.4.4 / Dart | Framework |
| Provider | State management |
| Dio | HTTP client |
| FlutterSecureStorage | TTL cache (offline-first) |
| CachedNetworkImage | Network image caching |
| Google Maps Flutter | Map & location UI |
| Geolocator | Device GPS |
| Connectivity Plus | Online/offline detection |
| Image Picker / Cropper | Camera & gallery uploads |
| Flutter Local Notifications | Expiry & event alerts |
| URL Launcher | Calls, external links |

### 🖥️ **Backend API (Node.js)**
| Package | Purpose |
|---|---|
| Express 5.1 | Web framework |
| MongoDB 8.x + Mongoose | Database + ODM |
| JWT (jsonwebtoken) | Auth tokens |
| Cloudinary + Multer | Image upload & storage |
| Nodemailer / Resend | Email OTP delivery |
| @google/genai | Gemini AI integration |
| Express Rate Limit | OTP abuse prevention |

### 🤖 **AI Agent (Python)**
| Package | Purpose |
|---|---|
| FastAPI + Uvicorn | API server |
| Agno | Multi-agent orchestration |
| OpenAI | LLM models |
| Pinecone | Vector search (RAG) |
| Redis | Chat history caching |
| DuckDuckGo Search | Web search tool |
| Gunicorn | Production server |

### 🗄️ **Data & Storage**
| Service | Purpose |
|---|---|
| MongoDB | Primary DB (geospatial indexing) |
| Pinecone | Vector store for RAG |
| Redis | Agent session/chat caching |
| Cloudinary | Medical center image CDN |

### ☁️ **Deployment**
| Service | Purpose |
|---|---|
| Azure | Backend + AI Agent hosting |
| Docker | Containerization |

---

## 📥 Installation

### Prerequisites
- **Flutter SDK** 3.4.4+, **Dart** 3.x
- **Node.js** 20.x+
- **Python** 3.10+
- **MongoDB** 8.x (local or Atlas)
- **Docker** (optional)

---

### Backend Setup

```bash
cd pillbin/server
npm install
cp .env.example .env   # fill in credentials
npm start
```
Runs at `http://localhost:5000`

---

### AI Agent Setup

```bash
cd ../Agent
python -m venv venv
source venv/bin/activate      # Windows: venv\Scripts\activate
pip install -r requirements.txt
python run.py                 # dev mode
```
Runs at `http://localhost:8000`

---

### Mobile App Setup

```bash
cd ../app
flutter pub get
# create .env
echo "BASE_URL=http://your-backend-url.com" > .env
echo "AGENT_URL=http://your-agent-url.com" >> .env
flutter run
```

---

## 🔐 Environment Variables

### **Backend (`server/.env`)**
```bash
PORT=5000
NODE_ENV=production
MONGODB_URI=mongodb://localhost:27017/pillbin
JWT_SECRET=your_jwt_secret_min_32_chars
JWT_REFRESH_SECRET=your_refresh_secret
JWT_EXPIRES_IN=3h
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
GEMINI_API_KEY=your_gemini_api_key
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_cloudinary_key
CLOUDINARY_API_SECRET=your_cloudinary_secret
ADMIN=your_admin_secret_key
```

### **AI Agent (`Agent/.env`)**
```bash
OPENAI_API_KEY=your_openai_api_key
PINECONE_API_KEY=your_pinecone_api_key
PINECONE_INDEX_NAME=your_index_name
REDIS_URL=your_redis_url
```

### **Flutter App (`app/.env`)**
```bash
BASE_URL=https://your-backend.azurewebsites.net
AGENT_URL=https://your-agent.azurewebsites.net
```

---

## 🏢 Vendor & Donation Flow

```
User submits donation request
        ↓
Vendor receives it in dashboard
        ↓
Vendor approves / rejects with note
        ↓
User sees status update in My Donations
        ↓
If approved → user calls center to schedule pickup
        ↓
Vendor marks as completed
```

> Medical centers added by vendors go through **admin approval** before appearing in the user-facing location list.

---

## 🔔 Notification & Nudge Reference

### Notifications
| Type | Trigger | Schedule | Priority |
|---|---|---|---|
| Welcome | Signup completion | Instant | Normal |
| Medicine Expiry | Expires within 5 days | Daily 9 AM | Urgent |
| Custom Alerts | Admin/system events | Instant | Varies |

### In-App Nudges (max 3/session)
| Priority | Nudge | Condition |
|---|---|---|
| 1 | Donation Approved | Any approved donation |
| 2 | Medicines Expiring | Expiring soon count > 0 |
| 3 | Donation Pending | Pending > 2 days old |
| 4 | Find Centers Near You | First time only |
| 5 | Explore Health Blogs | First time only |
| 6 | Donate Unused Medicines | First time + no donations |

---

## 🚀 Docker Deployment

```yaml
# docker-compose.yml
version: '3.8'
services:
  mongodb:
    image: mongo:8
    volumes:
      - mongo_data:/data/db

  backend:
    build: ./server
    ports:
      - "5000:5000"
    environment:
      - MONGODB_URI=mongodb://mongodb:27017/pillbin
      - JWT_SECRET=${JWT_SECRET}
      - GEMINI_API_KEY=${GEMINI_API_KEY}
      - CLOUDINARY_CLOUD_NAME=${CLOUDINARY_CLOUD_NAME}
    depends_on:
      - mongodb

  agent:
    build: ./Agent
    ports:
      - "8000:8000"
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - PINECONE_API_KEY=${PINECONE_API_KEY}
      - REDIS_URL=${REDIS_URL}

volumes:
  mongo_data:
```

```dockerfile
# server/Dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install --production
COPY . .
EXPOSE 5000
CMD ["node", "server.js"]
```

```dockerfile
# Agent/Dockerfile
FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD gunicorn -w 4 -k uvicorn.workers.UvicornWorker app.main:app --bind 0.0.0.0:$PORT
```

```bash
docker-compose up -d
```

---

<div align="center">

**Made with ❤️ by PillBin Team**

⭐ Star us on GitHub if you find this helpful!

</div>
