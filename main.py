from fastapi import FastAPI, UploadFile, File, Form
from fastapi.responses import FileResponse
import os
import uuid
from audio_filters import apply_filter

app = FastAPI()

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@app.post("/process")
async def process_audio(
    file: UploadFile = File(...),
    style: str = Form("simple"),
):
    print("received style =", style)  # デバッグ用
    # 保存
    input_filename = f"{uuid.uuid4()}_{file.filename}"
    input_path = os.path.join(UPLOAD_DIR, input_filename)

    with open(input_path, "wb") as f:
        f.write(await file.read())

    # フィルタ適用
    output_path = apply_filter(input_path, style)

    # 処理済み音声を返す
    return FileResponse(
        output_path,
        media_type="audio/wav",
        filename="processed.wav"
    )
