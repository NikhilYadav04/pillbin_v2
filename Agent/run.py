import uvicorn


if __name__ == "__main__":
    print("--- Health RAG Agent Server ---")

    print("Starting Uvicorn server at http://127.0.0.1:8000")

    # 'app.main:app' points to the 'app' variable inside the 'app/main.py' file
    uvicorn.run("app.main:app", host="127.0.0.1", port=8000, reload=True)
