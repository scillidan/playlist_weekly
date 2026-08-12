import glob
import os
import sys


def safe_print(msg):
    """Print to stdout, falling back to bytes if the console cannot encode the text."""
    try:
        print(msg)
    except UnicodeEncodeError:
        sys.stdout.buffer.write((msg + "\n").encode("utf-8", "replace"))


def has_cover(name):
    for ext in ("jpg", "jpeg", "png"):
        if os.path.exists(f"assets/{name}_cover.{ext}"):
            return True
    return False


def artist_images(name):
    arts = []
    for ext in ("jpg", "jpeg", "png"):
        arts.extend(glob.glob(f"assets/{name}_artist*.{ext}"))
    arts = [os.path.basename(a) for a in arts]
    arts.sort()
    return arts


def main():
    if not os.path.isdir("medias"):
        safe_print("Error: medias/ not found")
        sys.exit(1)

    songs = sorted(glob.glob("medias/*.mp3"))
    if not songs:
        safe_print("No .mp3 files found in medias/")
        return

    total = 0
    ready = 0
    issues = 0

    for song in songs:
        name = os.path.splitext(os.path.basename(song))[0]
        total += 1

        lrc = os.path.exists(f"medias/{name}.lrc")
        cover = has_cover(name)
        artists = artist_images(name)

        problems = []
        if not lrc:
            problems.append("lrc missing")
        if not cover:
            problems.append("cover missing")
        if not artists:
            problems.append("artist missing")

        if problems:
            issues += 1
            safe_print(f"[MISS] {name}  ({', '.join(problems)})")
        else:
            ready += 1
            safe_print(f"[ OK ] {name}  (cover + {len(artists)} artist)")

    safe_print("")
    safe_print(f"Total: {total}, ready: {ready}, with issues: {issues}")

    if issues:
        sys.exit(1)


if __name__ == "__main__":
    main()
