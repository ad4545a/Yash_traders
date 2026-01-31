import base64
import os

png_data = base64.b64decode("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==")
file_path = os.path.join("assets", "images", "transparent.png")

with open(file_path, "wb") as f:
    f.write(png_data)

print(f"Created {file_path}")
