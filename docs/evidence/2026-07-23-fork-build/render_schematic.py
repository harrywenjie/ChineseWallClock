from pathlib import Path

import fitz
from pypdf import PdfReader


source = Path("KiCad/schematic.pdf")
output = Path("temp/pdfs")
output.mkdir(parents=True, exist_ok=True)

reader = PdfReader(source)
print(f"pages={len(reader.pages)}")
for index, page in enumerate(reader.pages, start=1):
    print(f"--- PAGE {index} TEXT ---")
    print(page.extract_text() or "<no text>")

document = fitz.open(source)
for index, page in enumerate(document, start=1):
    print(f"page_rect={page.rect}")
    pixmap = page.get_pixmap(dpi=300, alpha=False)
    target = output / f"schematic-{index}.png"
    pixmap.save(target)
    print(f"rendered={target} width={pixmap.width} height={pixmap.height}")

    regions = {
        "controller-and-shift-registers": fitz.Rect(
            page.rect.width * 0.08,
            page.rect.height * 0.48,
            page.rect.width * 0.47,
            page.rect.height * 0.84,
        ),
        "rtc-and-power": fitz.Rect(
            page.rect.width * 0.50,
            page.rect.height * 0.48,
            page.rect.width * 0.78,
            page.rect.height * 0.72,
        ),
    }
    for name, clip in regions.items():
        detail = page.get_pixmap(dpi=600, alpha=False, clip=clip)
        detail_target = output / f"schematic-{index}-{name}.png"
        detail.save(detail_target)
        print(
            f"rendered={detail_target} width={detail.width} height={detail.height}"
        )
