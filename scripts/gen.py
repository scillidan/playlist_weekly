import os
import subprocess
import sys


def safe_print(msg):
    try:
        print(msg)
    except UnicodeEncodeError:
        sys.stdout.buffer.write((msg + "\n").encode("utf-8", "replace"))


def run(cmd, cwd=None):
    return subprocess.run(cmd, cwd=cwd)


def strip_ext(name):
    for ext in (".mp3", ".lrc"):
        if name.lower().endswith(ext):
            return name[: -len(ext)]
    return name


def add_one(basename):
    media = f"medias/{basename}.mp3"
    if not os.path.exists(media):
        safe_print(f"Error: media not found for {basename} in medias/")
        return 1

    lrc = f"medias/{basename}.lrc"
    if not os.path.exists(lrc):
        safe_print(
            f"Warning: lrc not found for {basename} in medias/ (lyrics will be empty)"
        )

    os.makedirs("_output/pdfs", exist_ok=True)
    os.makedirs("_output/jpgs", exist_ok=True)

    if run([sys.executable, "scripts/gen_typ.py", basename]).returncode != 0:
        return 1

    safe_print("Compiling typst...")
    typ = f"_output/pdfs/{basename}.typ"
    pdf = f"_output/pdfs/{basename}.pdf"
    if run(["typst", "compile", "--root", ".", typ, pdf]).returncode != 0:
        safe_print(f"Error: typst compile failed for {basename}")
        return 1

    safe_print("Converting to JPG...")
    jpg = f"_output/jpgs/{basename}.pdf.jpg"
    if (
        run(
            [
                "magick",
                "-density",
                "300",
                f"{pdf}[0]",
                "-resize",
                "x1080",
                "-background",
                "white",
                "-alpha",
                "remove",
                "-quality",
                "90",
                jpg,
            ]
        ).returncode
        != 0
    ):
        return 1

    safe_print("Creating MP4...")
    mp4 = f"_output/{basename}.mp4"
    if (
        run(
            [
                "ffmpeg",
                "-loop",
                "1",
                "-framerate",
                "1",
                "-i",
                jpg,
                "-i",
                media,
                "-c:v",
                "libx264",
                "-tune",
                "stillimage",
                "-c:a",
                "copy",
                "-pix_fmt",
                "yuv420p",
                "-shortest",
                "-y",
                mp4,
            ]
        ).returncode
        != 0
    ):
        safe_print(f"Error: ffmpeg failed for {basename}")
        return 1

    safe_print(f"Done: {basename}")
    return 0


def clean_one(basename):
    targets = [
        f"_output/pdfs/{basename}.pdf",
        f"_output/jpgs/{basename}.pdf.jpg",
        f"_output/{basename}.mp4",
    ]
    for t in targets:
        if os.path.exists(t):
            os.remove(t)
            safe_print(f"Deleted {t}")
    return 0


def regen_one(basename):
    typ = f"_output/pdfs/{basename}.typ"
    if os.path.exists(typ):
        os.remove(typ)
        safe_print(f"Deleted {typ}")
    return add_one(basename)


def main():
    if len(sys.argv) < 2:
        safe_print('Usage: gen.py [add|clean|regen] "song name"')
        return 1

    cmd = sys.argv[1]

    if cmd == "add":
        if len(sys.argv) < 3:
            safe_print('Usage: gen.py add "song name"')
            return 1
        return add_one(strip_ext(sys.argv[2]))

    if cmd == "clean":
        if len(sys.argv) < 3:
            safe_print('Usage: gen.py clean "song name"')
            return 1
        return clean_one(strip_ext(sys.argv[2]))

    if cmd == "regen":
        if len(sys.argv) < 3:
            safe_print('Usage: gen.py regen "song name"')
            return 1
        return regen_one(strip_ext(sys.argv[2]))

    safe_print(f"Unknown command: {cmd}")
    safe_print('Usage: gen.py [add|clean|regen] "song name"')
    return 1


if __name__ == "__main__":
    sys.exit(main())
