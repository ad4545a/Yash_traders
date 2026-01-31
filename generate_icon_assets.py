from PIL import Image, ImageDraw
import os
import math

# Configurations
SIZE = (1024, 1024)
COLOR_TOP = (15, 61, 46)     # Primary Emerald (#0F3D2E)
COLOR_BOTTOM = (2, 13, 9)    # Deep Emerald (#020D09) - Darker shade for blend
LOGO_PATH = os.path.join("assets", "images", "app_logo_gold.png")
BG_PATH = os.path.join("assets", "images", "gradient_bg.png")
FG_PATH = os.path.join("assets", "images", "android_foreground.png")
FINAL_PATH = os.path.join("assets", "images", "app_icon_final.png")

def create_gradient(width, height, c1, c2):
    base = Image.new('RGB', (width, height), c1)
    top = Image.new('RGB', (width, height), c1)
    bottom = Image.new('RGB', (width, height), c2)
    mask = Image.new('L', (width, height))
    mask_data = []
    for y in range(height):
        # Linear gradient vertical
        mask_data.extend([int(255 * (y / height))] * width)
    mask.putdata(mask_data)
    base.paste(bottom, (0, 0), mask)
    return base

def main():
    print("Generating assets...")
    
    # 1. Generate Background
    bg = create_gradient(SIZE[0], SIZE[1], COLOR_TOP, COLOR_BOTTOM)
    bg.save(BG_PATH)
    print(f"Saved Background: {BG_PATH}")

    # 2. Process Foreground (Logo)
    # Load logo
    if not os.path.exists(LOGO_PATH):
        print("Error: Logo file not found!")
        return

    logo = Image.open(LOGO_PATH).convert("RGBA")
    
    # Resize logo to ~81% of canvas (Zoomed in "just a little" from 68%)
    target_width = 830
    ratio = target_width / float(logo.width)
    target_height = int(float(logo.height) * ratio)
    
    logo_resized = logo.resize((target_width, target_height), Image.Resampling.LANCZOS)
    
    # Create transparent foreground canvas
    fg = Image.new('RGBA', SIZE, (0, 0, 0, 0))
    
    # Center the logo
    pos_x = (SIZE[0] - target_width) // 2
    pos_y = (SIZE[1] - target_height) // 2
    
    fg.paste(logo_resized, (pos_x, pos_y), logo_resized)
    fg.save(FG_PATH)
    print(f"Saved Android Foreground: {FG_PATH}")

    # 3. Composite Final Icon (for iOS/Web)
    final_icon = Image.open(BG_PATH).convert("RGBA")
    final_icon.paste(fg, (0, 0), fg) # fg is already the same size and centered
    final_icon.save(FINAL_PATH)
    print(f"Saved Final Flat Icon: {FINAL_PATH}")

if __name__ == "__main__":
    main()
