
import os
import xml.etree.ElementTree as ET

SVG_DIR = "Set Symbols"  # Update this to your folder

def strip_namespace(elem):
    if '}' in elem.tag:
        elem.tag = elem.tag.split('}', 1)[1]
    for child in elem:
        strip_namespace(child)

for filename in os.listdir(SVG_DIR):
    if not filename.lower().endswith(".svg"):
        continue

    path = os.path.join(SVG_DIR, filename)

    try:
        tree = ET.parse(path)
        root = tree.getroot()

        # Remove namespace declarations
        for key in list(root.attrib.keys()):
            if key.startswith("xmlns"):
                del root.attrib[key]

        strip_namespace(root)

        tree.write(path, encoding="utf-8", xml_declaration=True)
        print(f"✔ Cleaned: {filename}")

    except Exception as e:
        print(f"✖ Error processing {filename}: {e}")

