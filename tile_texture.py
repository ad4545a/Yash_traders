from PIL import Image

def tile_image(input_path, output_path, scale_factor=0.25):
    try:
        # Open the original image
        original = Image.open(input_path)
        
        # Calculate new size for the tile
        new_width = int(original.width * scale_factor)
        new_height = int(original.height * scale_factor)
        
        # Resize the image to be a "tile"
        tile = original.resize((new_width, new_height), Image.Resampling.LANCZOS)
        
        # Create a new blank image with the original dimensions (or slightly larger to ensure coverage)
        # We'll use the original dimensions to maintain the aspect ratio if it was specific, 
        # or just huge to cover everything. Let's keep original dimensions.
        new_image = Image.new('RGBA', original.size)
        
        # Paste the tiles
        for x in range(0, new_image.width, new_width):
            for y in range(0, new_image.height, new_height):
                new_image.paste(tile, (x, y))
        
        # Save the result
        new_image.save(output_path)
        print(f"Successfully tiled image to {output_path}")
        
    except Exception as e:
        print(f"Error processing image: {e}")

if __name__ == "__main__":
    input_file = r"d:\andriod_app\Yash_Traders\assets\images\header_pattern.png"
    # Overwriting the file directly as requested to "use that"
    output_file = r"d:\andriod_app\Yash_Traders\assets\images\header_pattern.png"
    
    # Scale factor 0.15 for "very small texture" (approx 1/6th size)
    tile_image(input_file, output_file, scale_factor=0.15)
