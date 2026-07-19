#!/usr/bin/env python3
"""Build small nearest-neighbor runtime strips from approved concept sheets."""

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
FISH_DIR = ROOT / "assets" / "images" / "fish"
PROCESSED_DIR = ROOT / "art_source" / "processed"


def remove_magenta_fringe(image: Image.Image) -> Image.Image:
    pixels = image.load()
    for y in range(image.height):
        for x in range(image.width):
            red, green, blue, alpha = pixels[x, y]
            if alpha and red > 110 and blue > 80 and red > green * 1.45 and blue > green * 1.3:
                pixels[x, y] = (red, green, blue, 0)
    return image


def build_strip(
    source: Path,
    output: Path,
    boxes: list[tuple[int, int, int, int]],
    cell_size: tuple[int, int],
    scrub_magenta: bool = False,
) -> None:
    image = Image.open(source).convert("RGBA")
    cell_width, cell_height = cell_size
    strip = Image.new("RGBA", (cell_width * len(boxes), cell_height))

    for index, box in enumerate(boxes):
        frame = image.crop(box)
        if scrub_magenta:
            frame = remove_magenta_fringe(frame)
        alpha_box = frame.getchannel("A").getbbox()
        if alpha_box is None:
            raise RuntimeError(f"No visible pixels in frame {index} from {source}")
        frame = frame.crop(alpha_box)
        frame.thumbnail((cell_width - 4, cell_height - 4), Image.Resampling.NEAREST)
        offset = (
            index * cell_width + (cell_width - frame.width) // 2,
            (cell_height - frame.height) // 2,
        )
        strip.alpha_composite(frame, offset)

    output.parent.mkdir(parents=True, exist_ok=True)
    strip.save(output, optimize=True)


def main() -> None:
    roster = PROCESSED_DIR / "fish_roster_model_sheet_v002.png"
    puffer = PROCESSED_DIR / "puffer_swim_source_v001.png"
    roster_columns = [(0, 256), (256, 512), (512, 768), (768, 1024)]

    def roster_boxes(top: int, bottom: int) -> list[tuple[int, int, int, int]]:
        return [(left, top, right, bottom) for left, right in roster_columns]

    build_strip(
        roster,
        FISH_DIR / "starter_fish_swim_v001.png",
        roster_boxes(130, 330),
        (48, 32),
        scrub_magenta=True,
    )
    build_strip(
        roster,
        FISH_DIR / "small_fish_swim_v001.png",
        roster_boxes(450, 650),
        (48, 28),
        scrub_magenta=True,
    )
    build_strip(
        roster,
        FISH_DIR / "hunter_fish_swim_v001.png",
        roster_boxes(1050, 1370),
        (64, 40),
        scrub_magenta=True,
    )
    with Image.open(puffer) as puffer_image:
        puffer_width = puffer_image.width // 4
    build_strip(
        puffer,
        FISH_DIR / "puffer_fish_swim_v001.png",
        [
            (index * puffer_width, 150, (index + 1) * puffer_width, 650)
            for index in range(4)
        ],
        (48, 48),
    )


if __name__ == "__main__":
    main()
