import os
import tempfile
from agno.knowledge.knowledge import Knowledge
from agno.knowledge.reader.pdf_reader import PDFReader
from agno.knowledge.chunking.recursive import RecursiveChunking
from agno.knowledge.embedder.google import GeminiEmbedder
from agno.vectordb.chroma import ChromaDb, SearchType
from backend.config.settings import settings
from backend.utils.logger import logger, Timer

_vector_db = ChromaDb(
    collection=settings.CHROMA_COLLECTION,
    path=settings.CHROMA_PATH,
    persistent_client=True,
    search_type=SearchType.hybrid,
    hybrid_rrf_k=60,
    embedder=GeminiEmbedder(id="gemini-embedding-2"),
)

knowledge_base = Knowledge(
    name="PillBin User Documents",
    description="User-uploaded medical reports and documents",
    vector_db=_vector_db,
)

_reader = PDFReader(
    name="PillBin PDF Reader",
    split_on_pages=False,
    chunking_strategy=RecursiveChunking(
        chunk_size=settings.CHUNK_SIZE,
        overlap=settings.CHUNK_OVERLAP,
    ),
)


async def index_document(file_bytes: bytes, filename: str, user_id: str) -> int:
    """Save uploaded PDF to temp file, chunk and index into ChromaDB."""
    t = Timer()
    suffix = os.path.splitext(filename)[1] or ".pdf"
    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
        tmp.write(file_bytes)
        tmp_path = tmp.name

    try:
        # Read and chunk the document
        docs = _reader.read(tmp_path)
        chunk_count = len(docs) if docs else 0

        logger.info(f"  \033[2m📄 Chunking:\033[0m  {filename}")
        logger.info(f"     chunks:    {chunk_count} (size={settings.CHUNK_SIZE}, overlap={settings.CHUNK_OVERLAP})")

        # Index into ChromaDB
        await knowledge_base.ainsert(
            name=filename,
            path=tmp_path,
            reader=_reader,
            metadata={"user_id": user_id, "doc_name": filename},
        )
        logger.info(f"     \033[92m✅ Indexed into ChromaDB\033[0m \033[2m{t.elapsed()}\033[0m")
        return chunk_count
    finally:
        os.unlink(tmp_path)


def search_documents(query: str, user_id: str, num_results: int = 5) -> list:
    """Search ChromaDB for relevant chunks. Returns list of results with metadata."""
    t = Timer()
    results = _vector_db.search(
        query=query,
        limit=num_results,
        filters={"user_id": user_id},
    )

    result_count = len(results) if results else 0
    logger.info(f"  \033[2m🔍 RAG Search:\033[0m \"{query[:50]}{'...' if len(query) > 50 else ''}\"")
    logger.info(f"     user_id:   {user_id[:12]}...")
    logger.info(f"     results:   {result_count}/{num_results} \033[2m{t.elapsed()}\033[0m")

    if results:
        for i, doc in enumerate(results):
            name = getattr(doc, "name", "?")
            content = str(getattr(doc, "content", ""))[:60]
            logger.info(f"     [{i+1}] \033[2m{name} → {content}...\033[0m")

    return results


async def clear_user_documents(user_id: str) -> None:
    """Delete all documents for a user."""
    logger.info(f"  \033[2m🗑️  Clearing docs for:\033[0m {user_id[:12]}...")
    knowledge_base.vector_db.delete_by_metadata({"user_id": user_id})


def clear_document_by_name(doc_name: str) -> None:
    """Delete a specific document by name."""
    logger.info(f"  \033[2m🗑️  Clearing doc:\033[0m {doc_name}")
    knowledge_base.vector_db.delete_by_name(doc_name)
