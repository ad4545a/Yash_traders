from PIL import Image
import os

def remove_white_bg(path):
    try:
        print(f"Processing: {path}")
        img = Image.open(path).convert("RGBA")
        datas = img.getdata()

        new_data = []
        for item in datas:
            # Change all white (also shades of whites)
            if item[0] > 200 and item[1] > 200 and item[2] > 200:
                new_data.append((255, 255, 255, 0))
            else:
                new_data.append(item)

        img.putdata(new_data)
        img.save(path, "PNG")
        print("Successfully removed background!")
    except Exception as e:
        print(f"Error: {e}")

# Path to the logo
logo_path = r"d:\andriod_app\pk_sons_jewellery\assets\images\logo.png"
if os.path.exists(logo_path):
    remove_white_bg(logo_path)
else:
    print("Logo not found at path.")
