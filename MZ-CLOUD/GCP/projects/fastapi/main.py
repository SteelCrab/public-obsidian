import uvicorn
from fastapi import FastAPI
from fastapi.responses import HTMLResponse

app = FastAPI()


@app.get("/", response_class=HTMLResponse)
async def read_root():
    return """
    <!DOCTYPE html>
    <html>
    <head>
        <title>EKS FastAPI</title>
        <style>
            body { font-family: Arial, sans-serif; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; background: #f0f2f5; }
            .card { background: white; border-radius: 12px; padding: 40px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); text-align: center; }
            h1 { color: #2c3e50; }
            p { color: #7f8c8d; }
            .badge { display: inline-block; background: #3498db; color: white; padding: 4px 12px; border-radius: 20px; font-size: 14px; }
        </style>
    </head>
    <body>
        <div class="card">
            <h1>EKS FastAPI App</h1>
            <p>Running on Amazon EKS</p>
            <span class="badge">Healthy</span>
        </div>
    </body>
    </html>
    """


@app.get("/api")
async def api_root():
    return {"message": "Hello from EKS FastAPI"}


@app.get("/health")
async def health_check():
    return {"status": "healthy"}


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
