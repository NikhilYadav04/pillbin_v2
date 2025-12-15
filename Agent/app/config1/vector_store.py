import os
from pinecone import Pinecone, ServerlessSpec
from langchain_pinecone import PineconeVectorStore
from langchain_google_genai import GoogleGenerativeAIEmbeddings
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

from config import (
    PINECONE_API_KEY,
    PINECONE_ENVIRONMENT,
    PINECONE_INDEX_NAME,
    GOOGLE_API_KEY,
)


os.environ["PINECONE_API_KEY"] = PINECONE_API_KEY
os.environ["PINECONE_ENVIRONMENT"] = PINECONE_ENVIRONMENT
os.environ["PINECONE_INDEX_NAME"] = PINECONE_INDEX_NAME

os.environ["GOOGLE_API_KEY"] = GOOGLE_API_KEY

# initialize pinecone client
pc = Pinecone(api_key=PINECONE_API_KEY)

# define embedding models
# embeddings = GoogleGenerativeAIEmbeddings(
#     model="models/embedding-001",
#     google_api_key=GOOGLE_API_KEY,
#     output_dimensionality=3072,
# )
embeddings = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")


# retriever
def get_retriever(user_id: str):
    """Initializes and returns the Pinecone vector store retriever"""

    # ensure the index exists, create if not
    if PINECONE_INDEX_NAME not in pc.list_indexes().names():
        print("Creating new index")
        pc.create_index(
            name=PINECONE_INDEX_NAME,
            dimension=384,
            metric="cosine",
            spec=ServerlessSpec(cloud="aws", region="us-east-1"),
        )
        print("Created pinecone index")

    vectorstore = PineconeVectorStore(
        index_name=PINECONE_INDEX_NAME, embedding=embeddings, namespace=user_id
    )

    return vectorstore.as_retriever(search_kwargs={"k": 5})


# add index
def addIndex():
    "ADMIN ROUTE => Add index if does not exists"

    if PINECONE_INDEX_NAME not in pc.list_indexes().names():
        print("Creating new index")
        pc.create_index(
            name=PINECONE_INDEX_NAME,
            dimension=384,
            metric="cosine",
            spec=ServerlessSpec(cloud="aws", region=PINECONE_ENVIRONMENT),
        )

        print("Created pinecone index")

    vectorstore = PineconeVectorStore(
        index_name=PINECONE_INDEX_NAME, embedding=embeddings
    )

    return vectorstore.as_retriever(search_kwargs={"k": 5})


# upload documents to vector store
def add_document(text_content: str, user_id: str):
    """
    Adds a single text document to the Pinecone vector store
    Splits the text into chunks before embedding and upsetting
    """

    if not text_content:
        raise ValueError("Document content cannot be empty")

    try:
        if PINECONE_INDEX_NAME not in pc.list_indexes().names():
            print("Creating new index")
            pc.create_index(
                name=PINECONE_INDEX_NAME,
                dimension=384,
                metric="cosine",
                spec=ServerlessSpec(cloud="aws", region=PINECONE_ENVIRONMENT),
            )

        text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=150, chunk_overlap=20, add_start_index=True
        )

        # create langchain document objects from the raw text
        documents = text_splitter.create_documents([text_content])

        print("Splitting document into chunk for indexing..")

        # get vector store instance to add documents
        vectorstore = PineconeVectorStore(
            index_name=PINECONE_INDEX_NAME, embedding=embeddings, namespace=user_id
        )

        # add documents to vector store
        vectorstore.add_documents(documents=documents)

        print("Successfully added chunks to pinecone vector store")
        return True
    except Exception as e:
        print(f"error : ${e}")
        return False


# get all chunks of data for a particular user
def getAllChunksData(user_id: str) -> list[str]:
    """
    Get all chunks of data for a user namespace
    """

    try:
        # 1. Access the Pinecone Index directly
        index = pc.Index(PINECONE_INDEX_NAME)

        # 2. Create a "Dummy Vector"
        # (It must match your embedding dimension. Gemini uses 3072)
        dummy_vector = [0.0] * 384

        # 3. Query the index to get "everything" in the namespace
        # We ask for top_k=10000 to ensure we grab all chunks for this user
        response = index.query(
            vector=dummy_vector, top_k=5000, namespace=user_id, include_metadata=True
        )

        # 4. Extract the text content from metadata
        # Adjust 'text' to whatever key LangChain used (usually 'text' or 'context')
        docs = [
            match["metadata"]["text"]
            for match in response["matches"]
            if "metadata" in match and "text" in match["metadata"]
        ]

        if not docs:
            return ["No documents found for this user."]

        print(f"✅ [Tool] Retrieved {len(docs)} chunks for user {user_id}")
        return docs

    except Exception as e:
        print(f"❌ [Tool] Error while fetching chunks for user {user_id}: {e}")
        return [f"Error fetching data: {e}"]


# * ADMIN ROUTES


# add index
def addIndex():
    "ADMIN ROUTE => Add index if does not exists"

    if PINECONE_INDEX_NAME not in pc.list_indexes().names():
        print("Creating new index")
        pc.create_index(
            name=PINECONE_INDEX_NAME,
            dimension=384,
            metric="cosine",
            spec=ServerlessSpec(cloud="aws", region=PINECONE_ENVIRONMENT),
        )

        print("Created pinecone index")

    vectorstore = PineconeVectorStore(
        index_name=PINECONE_INDEX_NAME, embedding=embeddings
    )

    return vectorstore.as_retriever(search_kwargs={"k": 5})


# clear documents for a particular namespace
async def clear_documents_user(user_id: str):
    try:
        # Take PineCone Object
        index = pc.Index(PINECONE_INDEX_NAME)

        # Delete only the vectors in this specific user's namespace
        index.delete(delete_all=True, namespace=user_id)

        import time

        time.sleep(1)

        print(f"Successfully deleted all documents for user: {user_id}")
        return True
    except Exception as e:
        print(f"Error deleting documents for user {user_id}: {e}")
        return False


# delete index ( This deletes data for ALL users)
async def clear_index():
    try:
        # Take Pinecone Object
        index = pc.Index(PINECONE_INDEX_NAME)

        # Delete all vectors inside the index (across all namespaces)
        index.delete(delete_all=True)

        print("All records deleted from rag-index (ALL USERS WIPED)")
        return True
    except Exception as e:
        print(f"Error clearing index: {e}")
        return False
