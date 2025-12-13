import shutil
import ocrmypdf
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
    """

    ocr_pdf_path = pdf_path.with_suffix(".ocr.pdf")

    try:

        # 1. OCR the PDF to make it searchable (from your notebook)
        print(f"Starting OCR for {pdf_path.name}...")
        ocrmypdf.ocr(
            pdf_path, ocr_pdf_path, language="eng", force_ocr=True, progress_bar=False
        )
        print("OCR complete.")

        # 2. Load the OCR'd PDF
        loader = PDFPlumberLoader(str(ocr_pdf_path))
        documents = loader.load()

        # 3. Split documents into chunks and upload it in pinecone
        total_chunks_added = 0

        if documents:
            full_text_content = "\n\n".join(doc.page_content for doc in documents)

            response = add_document(full_text_content, user_id=user_id)

            if response == False:
                return False

            total_chunks_added = len(documents)

        return True

    except Exception as e:
        print(f"Error creating vector store for {user_id}: {e}")
        return False

    finally:
        # 6. Clean up temporary files
        if pdf_path.exists():
            pdf_path.unlink()
        if ocr_pdf_path.exists():
            ocr_pdf_path.unlink()
