# 💊 PillBin - Smart Medicine Management System

---

## 🌟 About PillBin

**PillBin** is a comprehensive medicine management application designed to help users track their medicines, receive timely expiry alerts, find nearby disposal centers, and get AI-powered health insights from their medical reports. With intelligent features like OCR-powered report analysis and location-based services, PillBin promotes responsible medicine disposal and better health management.

---

## 🖼️ Screenshots

<img width="4000" height="3000" alt="collage" src="https://github.com/user-attachments/assets/856b9723-5dd2-4f0d-a967-cd18302fc097" />

---

## ✨ Key Features

### 📦 **Medicine Inventory Management**
- ✅ Add, edit, and delete medicines with comprehensive details
- ✅ Track expiry dates, dosages, batch numbers, and manufacturers
- ✅ Smart categorization: Active, Expiring Soon (5 days alert), Expired
- ✅ Soft delete with recovery option (maintains history of up to 100 deleted items)
- ✅ Bulk operations: Clear all expired medicines at once
- ✅ User limit: 100 medicines per account for optimal performance

### 🔔 **Smart Notification System**
- 🎉 **Welcome Notification**: Instant greeting upon signup completion
- ⏰ **Medicine Expiry Alerts**: Scheduled daily notifications for medicines expiring within 5 days
- 📱 **Instant Notifications**: Real-time alerts for important events
- 🔕 **Priority Levels**: Important, Normal, Urgent, Alert
- 📊 **Notification History**: Maintains last 50 notifications with auto-cleanup
- 🗑️ **Bulk Management**: Clear all or individual notifications

### 🤖 **AI-Powered Features**

#### **1. Gemini Health Chatbot**
- 💬 General health and medicine queries
- 🧠 Powered by Google Gemini 2.0 Flash Lite
- ⚡ Token-optimized responses (80 token limit)
- 🔒 Privacy-focused conversations

#### **2. RAG Health Report Agent**
- 📄 Upload health reports (PDF format)
- 🔍 OCR processing for scanned documents
- 🧩 FAISS vector store for semantic search
- 🌐 Web search integration when needed
- 💡 LangChain ReAct agent for intelligent query answering
- 📊 Explains lab values, normal ranges, and health insights

### 📍 **Location-Based Services**
- 🗺️ Find nearby medicine disposal centers (MongoDB geospatial search)
- 📏 Radius-based search (default 10km, customizable)
- 🏥 Filter by facility type: Hospital, Clinic, Pharmacy, Health Center
- 🕒 View operating hours and accepted medicine types
- ⭐ Rating system for centers

### 📊 **Statistics & History**
- 📈 Total medicines tracked
- ⚠️ Expiring soon count
- 🗑️ Medicines disposed count

### 🔐 **Authentication & Security**
- 📧 Email-based OTP authentication
- 🔑 JWT access & refresh tokens
- ⏱️ Rate limiting on OTP requests (10 requests per 10 minutes)
- 🛡️ Secure password-free authentication

### 📱 **Responsive Design**
- 📱 **Mobile-First**: Optimized for smartphones
- 📲 **Tablet Support**: Adaptive layouts for larger screens

### 📚 **Information & Awareness**
- 📰 **Latest Articles**: Curated content on medicine disposal best practices
- 🌍 **Environmental Impact**: Learn about effects of improper disposal on nature
- 📊 **Survey Data**: Real insights from students and doctors on medicine disposal habits
- 🏢 **NGO Directory**: Links to organizations working on safe medicine disposal
- 🔗 **Resource Hub**: Connect with government and non-profit disposal programs
- 💡 **Educational Content**: Tips for responsible medicine management

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    PILLBIN ECOSYSTEM                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐         ┌──────────────┐                │
│  │  Flutter App │◄───────►│ Node.js API  │                │
│  │   (Mobile)   │         │  (Express)   │                │
│  └──────────────┘         └───────┬──────┘                │
│         │                         │                        │
│         │                         ▼                        │
│         │                  ┌─────────────┐                │
│         │                  │   MongoDB   │                │
│         │                  │  (Database) │                │
│         │                  └─────────────┘                │
│         │                                                  │
│         └──────────────────────┐                          │
│                                ▼                          │
│                         ┌──────────────┐                  │
│                         │  Python API  │                  │
│                         │  (FastAPI)   │                  │
│                         └──────┬───────┘                  │
│                                │                          │
│                    ┌───────────┴────────────┐             │
│                    ▼                        ▼             │
│             ┌─────────────┐         ┌─────────────┐      │
│             │    FAISS    │         │   Gemini    │      │
│             │ Vector Store│         │   AI API    │      │
│             └─────────────┘         └─────────────┘      │
│                                                           │
│                    ┌──────────────────┐                  │
│                    │   LangChain      │                  │
│                    │  ReAct Agent     │                  │
│                    └──────────────────┘                  │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

### 📂 Project Structure

```
pillbin/
├── app/                          # Flutter Mobile Application
│   ├── lib/
│   │   ├── config/              # App configuration
│   │   │   ├── routes/          # Navigation routes
│   │   │   └── theme/           # App theme & colors
│   │   ├── core/                # Core utilities
│   │   │   └── constants/       # App constants
│   │   ├── features/            # Feature modules
│   │   │   ├── auth/           # Authentication
│   │   │   ├── campaign/       # Campaigns (future)
│   │   │   ├── chatbot/        # AI Chatbot
│   │   │   ├── health_ai/      # RAG Health Agent
│   │   │   ├── home/           # Home & Dashboard
│   │   │   ├── info/           # Info, Articles & Awareness
│   │   │   ├── locations/      # Disposal Centers
│   │   │   ├── medicines/      # Medicine Management
│   │   │   └── profile/        # User Profile
│   │   ├── network/            # API clients
│   │   ├── root_screen.dart    # Bottom navigation
│   │   ├── app.dart            # App widget
│   │   └── main.dart           # Entry point
│   └── pubspec.yaml            # Dependencies
│
├── server/                      # Node.js Backend API
│   ├── config/
│   │   └── database.js         # MongoDB connection
│   ├── controllers/            # Business logic
│   │   ├── authController.js
│   │   ├── userController.js
│   │   ├── medicineController.js
│   │   ├── medicalCenterController.js
│   │   ├── chatbotController.js
│   │   └── notificationController.js
│   ├── models/                 # MongoDB schemas
│   │   ├── User.js
│   │   ├── Medicine.js
│   │   ├── MedicalCenter.js
│   │   └── Notification.js
│   ├── routes/                 # API routes
│   ├── middleware/             # Auth & helpers
│   ├── utils/                  # JWT utilities
│   ├── services/               # External services
│   ├── server.js              # Server entry point
│   ├── Dockerfile             # Docker config
│   └── package.json
│
└── Agent/                      # Python AI Agent
    ├── app/
    │   ├── api/
    │   │   └── endpoints.py   # API endpoints
    │   ├── config.py          # Configuration
    │   ├── main.py            # FastAPI app
    │   ├── models/
    │   │   └── schemas.py     # Pydantic schemas
    │   └── services/
    │       ├── agent_service.py    # LangChain agent
    │       └── vector_store.py     # FAISS operations
    ├── requirements.txt       # Python dependencies
    ├── Dockerfile            # Docker config
    └── run.py               # Development server
```

---

## 🛠️ Tech Stack

### 📱 **Mobile App (Flutter)**
- **Framework**: Flutter 3.4.4 / Dart
- **State Management**: Provider
- **HTTP Client**: Dio
- **Local Storage**: Flutter Secure Storage
- **File Handling**: File Picker, Permission Handler
- **Notifications**: Flutter Local Notifications, Timezone
- **UI/UX**: Material Design, Custom Poppins Font

### 🖥️ **Backend API (Node.js)**
- **Runtime**: Node.js 20.x
- **Framework**: Express.js 5.1
- **Database**: MongoDB 8.17 with Mongoose ODM
- **Authentication**: JWT (jsonwebtoken)
- **Security**: Express Rate Limit, CORS
- **AI Integration**: Google Gemini API (@google/genai)
- **Email Service**: Nodemailer (SMTP)
- **Validation**: Express Validator
- **Logging**: Morgan

### 🤖 **AI Agent (Python)**
- **Framework**: FastAPI
- **LLM**: Google Gemini 2.0 Flash Lite
- **Agent Framework**: LangChain (ReAct Agent)
- **Vector Store**: FAISS (Facebook AI Similarity Search)
- **Embeddings**: Google Generative AI Embeddings
- **OCR**: Tesseract OCR (ocrmypdf)
- **PDF Processing**: PDFPlumber
- **Web Search**: DuckDuckGo Search
- **Server**: Uvicorn + Gunicorn

### 🗄️ **Database**
- **Primary**: MongoDB (with geospatial indexing)
- **Vector Store**: FAISS (for semantic search)
- **Storage**: Persistent volume for FAISS indexes

### ☁️ **Deployment**
- **Hosting**: Railway.app
- **Containerization**: Docker
- **Persistent Storage**: Railway Volumes

---

## 📥 Installation

### Prerequisites

Ensure you have the following installed:

- **Flutter SDK** 3.4.4 or higher
- **Dart** 3.x
- **Node.js** 20.x or higher
- **Python** 3.10 or higher
- **MongoDB** 8.x (local or cloud)
- **Docker** (optional, for containerized deployment)
- **Tesseract OCR** (for PDF processing)

---

### Backend Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/pillbin.git
   cd pillbin/server
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your credentials
   ```

4. **Start MongoDB**
   ```bash
   # If using local MongoDB
   mongod --dbpath /path/to/data
   
   # Or use MongoDB Atlas (cloud)
   ```

5. **Run the server**
   ```bash
   # Development mode with auto-reload
   npm start
   
   # Production mode
   node server.js
   ```

   Server will run at: `http://localhost:5000`

---

### AI Agent Setup

1. **Navigate to Agent directory**
   ```bash
   cd ../Agent
   ```

2. **Create virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Install system dependencies**
   ```bash
   # Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install tesseract-ocr ghostscript libopenjp2-7
   
   # macOS
   brew install tesseract ghostscript openjpeg
   
   # Windows
   # Download Tesseract from: https://github.com/UB-Mannheim/tesseract/wiki
   ```

5. **Configure environment variables**
   ```bash
   # Set in .env or export
   export GOOGLE_API_KEY="your_gemini_api_key"
   export DATA_DIR="/path/to/persistent/storage"
   ```

6. **Run the agent**
   ```bash
   # Development mode
   python run.py
   
   # Production mode (with Docker)
   docker build -t pillbin-agent .
   docker run -p 8000:8000 -v /data:/data pillbin-agent
   ```

   Agent will run at: `http://localhost:8000`

---

### Mobile App Setup

1. **Navigate to app directory**
   ```bash
   cd ../app
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   ```bash
   # Create .env file in app root
   echo "BASE_URL=http://your-backend-url.com" > .env
   echo "AGENT_URL=http://your-agent-url.com" >> .env
   ```

4. **Run the app**
   ```bash
   # Check connected devices
   flutter devices
   
   # Run on connected device
   flutter run
   
   # Build APK (Android)
   flutter build apk --release
   
   # Build iOS (macOS only)
   flutter build ios --release
   ```

---

## 🔐 Environment Variables

### **Backend (.env)**

```bash
# Server Configuration
PORT=5000
NODE_ENV=production

# MongoDB
MONGODB_URI=mongodb://localhost:27017/pillbin
# Or MongoDB Atlas: mongodb+srv://user:pass@cluster.mongodb.net/pillbin

# JWT Secrets
JWT_SECRET=your_super_secret_jwt_key_here_min_32_chars
JWT_REFRESH_SECRET=your_refresh_token_secret_here
JWT_EXPIRES_IN=3h

# Email Configuration (SMTP)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-specific-password

# Google Gemini API
GEMINI_API_KEY=your_gemini_api_key_here

# Admin Key
ADMIN=your_admin_secret_key
```

### **AI Agent (.env)**

```bash
# Google Gemini API
GOOGLE_API_KEY=your_gemini_api_key_here

# Data Storage (for Railway/Docker)
DATA_DIR=/data

# Or for local development
# DATA_DIR=.
```

### **Flutter App (.env)**

```bash
# API Endpoints
BASE_URL=https://your-backend.railway.app
AGENT_URL=https://your-agent.railway.app

# Optional: API Keys for future features
# GOOGLE_MAPS_API_KEY=your_key_here
```

---

## 🔔 Notification System

PillBin uses **Flutter Local Notifications** with **Timezone** for intelligent scheduling.

### **Notification Types**

| Type | Trigger | Schedule | Priority |
|------|---------|----------|----------|
| **Welcome** | Signup completion | Instant | Normal |
| **Medicine Expiry** | Medicine expires in ≤5 days | Daily at 9 AM | Urgent |
| **Custom Alerts** | Admin/System events | Instant | Varies |

---

## 🤖 AI Agent Features

### **RAG Health Report Analysis**

1. **Upload PDF Report**
   - OCR processing for scanned documents
   - Text extraction with PDFPlumber
   - Automatic chunking (150 chars, 20 overlap)

2. **Vector Store Creation**
   - Google Gemini embeddings (gemini-embedding-001)
   - FAISS indexing for semantic search
   - User-specific index storage

3. **Query Processing**
   - Retrieval with MMR (Maximal Marginal Relevance)
   - Top 5 relevant chunks
   - LangChain ReAct agent for reasoning

4. **Web Search Integration**
   - DuckDuckGo search for external info
   - Automatic fallback when context insufficient

### **Example Queries**

```
✅ "What does my cholesterol level mean?"
✅ "Is my blood pressure normal?"
✅ "Summarize my complete blood test"
✅ "What should I do about high glucose?"
✅ "Explain my kidney function tests"
```

---

## 🚀 Deployment

### **Docker Compose**

```yaml
version: '3.8'

services:
  mongodb:
    image: mongo:8
    ports:
      - "27017:27017"
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
    depends_on:
      - mongodb

  agent:
    build: ./Agent
    ports:
      - "8000:8000"
    volumes:
      - agent_data:/data
    environment:
      - GOOGLE_API_KEY=${GOOGLE_API_KEY}
      - DATA_DIR=/data

volumes:
  mongo_data:
  agent_data:
```

### **Docker Files ( For Server and Agent )**

```yaml
FROM node:20-alpine

# Set the working directory inside the container
WORKDIR /app

COPY package.json package-lock.json* ./

# Install only the production dependencies
RUN npm install --production

COPY . .

EXPOSE 5000

CMD ["node", "server.js"]
```

```yaml
FROM python:3.10-slim

# Set the working directory
WORKDIR /app

RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    ghostscript \
    libopenjp2-7 \
    # v4
    && rm -rf /var/lib/apt/lists/*

# Create the /data mount point
RUN mkdir -p /data

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

CMD gunicorn -w 4 -k uvicorn.workers.UvicornWorker app.main:app --bind 0.0.0.0:$PORT
```

Run with:
```bash
docker-compose up -d
```

---

<div align="center">

**Made with ❤️ by PillBin Team**

⭐ Star us on GitHub if you find this helpful!

</div>
