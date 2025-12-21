import shutil
import gc
from pathlib import Path
from fastapi import HTTPException
from langchain_community.document_loaders import PDFPlumberLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_google_genai import GoogleGenerativeAIEmbeddings
from langchain_core.documents import Document
from langchain_core.vectorstores import VectorStoreRetriever

from app.config1.vector_store import add_document


def create_vector_store(user_id: str, pdf_path: Path) -> bool:
    """
    Uploads a PDF document, extracts text, and adds it to the RAG knowledge base.
    NO OCR - Only works with text-based PDFs.
    """

    try:
        # 1. Load the PDF directly
        print(f"Loading PDF: {pdf_path.name}")
        loader = PDFPlumberLoader(str(pdf_path))
        documents = loader.load()

        print(f"Loaded {len(documents)} pages from PDF")

        # 2. Check if we got any text
        if not documents:
            print(f"⚠️ No documents extracted from PDF")
            return False

        # 3. Join all page content
        full_text_content = "\n\n".join(doc.page_content for doc in documents)

        # 4. Validate we have meaningful content
        if len(full_text_content.strip()) < 50:
            print(
                f"⚠️ PDF appears empty or image-based (only {len(full_text_content)} chars)"
            )
            print("Hint: If this is a scanned PDF, you need OCR enabled")
            return False

        print(f"Extracted {len(full_text_content)} characters from PDF")

        # 5. Add to Pinecone
        response = add_document(full_text_content, user_id=user_id)

        if response == False:
            print("❌ Failed to add document to vector store")
            return False

        print(f"✅ Successfully processed PDF for user {user_id}")

        # 6. Clean up memory
        del documents
        del full_text_content
        gc.collect()

        return True

    except Exception as e:
        print(f"❌ Error creating vector store for {user_id}: {e}")
        return False

    finally:
        try:
            if pdf_path and pdf_path.exists():
                pdf_path.unlink()
                print(f"🗑️ Deleted temporary PDF: {pdf_path}")
        except Exception as e:
            print(f"⚠️ Error deleting PDF: {e}")

        # Final memory cleanup
        gc.collect()
