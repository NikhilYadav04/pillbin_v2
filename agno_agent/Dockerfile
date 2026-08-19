FROM python:3.11-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# chromadb pulls a few packages that still build from source on slim
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY backend/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt \
    && apt-get purge -y --auto-remove build-essential

# Imports are absolute from `backend`, so the package must sit under the workdir
COPY backend ./backend

# Chroma and SQLite write here; mount a persistent disk at /data or the
# knowledge base and chat archive are lost on every restart
ENV CHROMA_PATH=/data/chromadb \
    SQLITE_PATH=/data/pillbin.db
RUN mkdir -p /data

EXPOSE 8000

# Single worker on purpose: the Chroma persistent client and the SQLite file
# are both local to the instance and do not tolerate concurrent writers
# exec so uvicorn replaces the shell and receives SIGTERM directly —
# without it the platform's stop signal never reaches the server
CMD exec uvicorn backend.main:app --host 0.0.0.0 --port ${PORT:-8000} --workers 1
