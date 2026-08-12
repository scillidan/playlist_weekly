import argparse
import fnmatch
import glob
import os
import re
import subprocess
import sys


def safe_print(msg):
    try:
        print(msg)
    except UnicodeEncodeError:
        sys.stdout.buffer.write((msg + "\n").encode("utf-8", "replace"))


def sanitize_log_name(s):
    return re.sub(r"[^a-zA-Z0-9._-]", "_", s).strip("_")


def list_songs(only):
    songs = []
    for mp3 in sorted(glob.glob("medias/*.mp3")):
        name = os.path.splitext(os.path.basename(mp3))[0]
        if only and not fnmatch.fnmatch(name, only):
            continue
        songs.append(name)
    return songs


def main():
    parser = argparse.ArgumentParser(description="Build all songs in medias/")
    parser.add_argument("--force", action="store_true", help="overwrite existing mp4")
    parser.add_argument(
        "--only", metavar="PATTERN", help="only build matching songs (fnmatch)"
    )
    parser.add_argument(
        "--dry-run", action="store_true", help="list actions without running"
    )

    argv = sys.argv[1:]
    if argv and argv[0] == "--":
        argv = argv[1:]
    args = parser.parse_args(argv)

    songs = list_songs(args.only)
    if not songs:
        safe_print("No songs matched.")
        return 1

    log_dir = "_temp/build-logs"
    os.makedirs(log_dir, exist_ok=True)

    built = 0
    skipped = 0
    failed = 0
    failed_names = []
    failed_logs = []

    for name in songs:
        mp4 = f"_output/{name}.mp4"
        if os.path.exists(mp4) and not args.force:
            safe_print(f"Skip: {name} (mp4 exists)")
            skipped += 1
            continue

        if args.dry_run:
            action = "REBUILD" if os.path.exists(mp4) else "BUILD"
            safe_print(f"[dry-run] {action}: {name}")
            continue

        log_file = os.path.join(log_dir, sanitize_log_name(name) + ".log")
        safe_print(f"Build: {name}")

        cmd = [sys.executable, "scripts/gen.py", "add", name]
        with open(log_file, "w", encoding="utf-8") as log:
            result = subprocess.run(cmd, stdout=log, stderr=subprocess.STDOUT)

        if result.returncode == 0:
            built += 1
            os.remove(log_file)
        else:
            failed += 1
            failed_names.append(name)
            failed_logs.append(log_file)
            safe_print(f"  FAILED: {name} (log: {log_file})")

    safe_print("")
    safe_print("========================================")
    safe_print(f"Build complete: {built} built, {failed} failed, {skipped} skipped.")

    if failed:
        safe_print("")
        safe_print("========== ERROR LOGS ==========")
        for name, log_file in zip(failed_names, failed_logs):
            safe_print(f"  {name}: {log_file}")
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
