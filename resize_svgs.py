import os
import xml.etree.ElementTree as ET

INPUT_DIR = "Set Symbols"
OUTPUT_DIR = "output_svgs"
MAX_WIDTH = 512
MAX_HEIGHT = 512

os.makedirs(OUTPUT_DIR, exist_ok=True)

for filename in os.listdir(INPUT_DIR):
    if not filename.lower().endswith(".svg"):
        continue

    path = os.path.join(INPUT_DIR, filename)
    tree = ET.parse(path)
    root = tree.getroot()

    # Try to get original dimensions from viewBox or width/height
    viewbox = root.get("viewBox")
    if viewbox:
        _, _, orig_w, orig_h = map(float, viewbox.strip().split())
    else:
        orig_w = float(root.get("width", MAX_WIDTH))
        orig_h = float(root.get("height", MAX_HEIGHT))

    # Determine scale factor to fit inside max dimensions
    scale = min(MAX_WIDTH / orig_w, MAX_HEIGHT / orig_h)
    new_w = round(orig_w * scale, 2)
    new_h = round(orig_h * scale, 2)

    # Set new size attributes
    root.set("width", f"{new_w}")
    root.set("height", f"{new_h}")
    if not viewbox:
        root.set("viewBox", f"0 0 {orig_w} {orig_h}")

    out_path = os.path.join(OUTPUT_DIR, filename)
    tree.write(out_path)

