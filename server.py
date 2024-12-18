import uvicorn
from main import app
import os

if __name__ == "__main__":
    port = int(os.environ.get("RENDER_PORT", "8000"))
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=port,
        log_level="info"
    )
