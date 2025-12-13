# app/config.py
import os
from dotenv import load_dotenv

load_dotenv()

# Pinecone
PINECONE_API_KEY = os.getenv("PINECONE_API_KEY")
PINECONE_ENVIRONMENT = os.getenv("PINECONE_ENVIRONMENT", "us-east-1")
PINECONE_INDEX_NAME = os.getenv("PINECONE_INDEX_NAME", "rag-index")

ADMIN = os.getenv("ADMIN")
TEMP_UPLOAD_DIR = os.getenv("TEMP_DIR")


# Google api key
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")


