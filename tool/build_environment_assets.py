#!/usr/bin/env python3
"""Build compact nearest-neighbor environment assets from approved sources."""

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "art_source"
OUTPUT_DIR = ROOT / "assets" / "images" / "environment"


def build_water_tile() -> None:
    source = Image.open(
        SOURCE_DIR / "concepts" / "ocean_water_tile_v001.png"
    ).convert("RGB")
    tile = source.resize((256, 256), Image.Resampling.NEAREST)
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    tile.save(OUTPUT_DIR / "ocean_water_tile_v001.png", optimize=True)


def build_props_atlas() -> None:
    source = Image.open(
        SOURCE_DIR / "processed" / "ocean_props_sheet_v001.png"
    ).convert("RGBA")
    cell_size = 64
    atlas = Image.new("RGBA", (cell_size * 4, cell_size * 2))

    for row in range(2):
        for column in range(4):
            crop = source.crop(
                (
                    column * source.width // 4,
                    row * source.height // 2,
                    (column + 1) * source.width // 4,
                    (row + 1) * source.height // 2,
                )
            )
            bounds = crop.getchannel("A").getbbox()
            if bounds is None:
                raise RuntimeError(f"Missing prop at row {row}, column {column}")
            prop = crop.crop(bounds)
            prop.thumbnail((60, 60), Image.Resampling.NEAREST)
            destination = (
                column * cell_size + (cell_size - prop.width) // 2,
                row * cell_size + cell_size - prop.height - 2,
            )
            atlas.alpha_composite(prop, destination)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    atlas.save(OUTPUT_DIR / "ocean_props_atlas_v001.png", optimize=True)


def main() -> None:
    build_water_tile()
    build_props_atlas()


if __name__ == "__main__":
    main()
