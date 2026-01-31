from PIL import Image
import os

def process_logo(input_path, output_path):
    try:
        print(f"Processing: {input_path}")
        img = Image.open(input_path).convert("RGBA")
        datas = img.getdata()

        new_data = []
        for item in datas:
            # More aggressive threshold: brighter than light gray counts as background
            # Also checking for near-white
            if item[0] > 180 and item[1] > 180 and item[2] > 180:
                new_data.append((255, 255, 255, 0)) # Transparent
            else:
                new_data.append(item)

        img.putdata(new_data)
        img.save(output_path, "PNG")
        print(f"Saved transparent logo to: {output_path}")
    except Exception as e:
        print(f"Error: {e}")

# Paths
source_logo = r"d:\andriod_app\pk_sons_jewellery\assets\images\logo.png"
new_logo = r"d:\andriod_app\pk_sons_jewellery\assets\images\logo_v2.png"

if os.path.exists(source_logo):
    process_logo(source_logo, new_logo)
else:
    print("Source logo not found.")
