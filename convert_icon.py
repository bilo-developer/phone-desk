import sys
from PIL import Image

def convert_to_ico(png_path, out_paths):
    img = Image.open(png_path)
    # Ensure it is a square, resize if necessary
    width, height = img.size
    if width != height:
        size = min(width, height)
        img = img.crop(((width - size) // 2, (height - size) // 2, (width + size) // 2, (height + size) // 2))
    
    icon_sizes = [(16,16), (32, 32), (48, 48), (64,64), (128, 128), (256, 256)]
    
    for path in out_paths:
        img.save(path, format='ICO', sizes=icon_sizes)
        print(f"Saved {path}")

png_file = r"C:\Users\bcbil\.gemini\antigravity-ide\brain\df7d2c62-1cb0-4c35-a8f1-80ab2868cf2d\phone_desk_icon_1780456425383.png"
paths = [
    r"c:\src\project\phone_link_copy\assets\app_icon.ico",
    r"c:\src\project\phone_link_copy\windows\runner\resources\app_icon.ico"
]

convert_to_ico(png_file, paths)
