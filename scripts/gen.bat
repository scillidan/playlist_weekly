@echo off
setlocal enabledelayedexpansion
set PYTHONIOENCODING=utf-8

set "cmd=%~1"
set "name=%~2"

if "%cmd%"=="" (
    echo Usage: gen.bat [add^|clean] "song name"
    exit /b 1
)

if "%cmd%"=="add" (
    if "%name%"=="" (
        echo Usage: gen.bat add "song name"
        exit /b 1
    )

    call :get_basename "%name%" basename

    set "media=medias/!basename!.mp3"
    if not exist "!media!" (
        echo Error: media not found for !basename! in medias/
        exit /b 1
    )

    if not exist "_output\pdfs" mkdir "_output\pdfs"
    if not exist "_output\jpgs" mkdir "_output\jpgs"
    if not exist "_output\srts" mkdir "_output\srts"

    python scripts/gen_typ.py "!basename!"

    echo Compiling typst...
    typst compile --root . "_output/pdfs/!basename!.typ" "_output/pdfs/!basename!.pdf"

    echo Converting to JPG...
    magick -density 300 "_output/pdfs/!basename!.pdf[0]" -resize x1080 -background white -alpha remove -quality 90 "_output/jpgs/!basename!.pdf.jpg"

    if exist "!media!" (
        echo Creating MP4...
        ffmpeg -loop 1 -framerate 1 -i "_output/jpgs/!basename!.pdf.jpg" -i "!media!" -c:v libx264 -tune stillimage -c:a copy -pix_fmt yuv420p -shortest -y "_output/!basename!.mp4"
    )

    echo Done: !basename!
    exit /b 0
)

if "%cmd%"=="clean" (
    if "%name%"=="" (
        echo Usage: gen.bat clean "song name"
        exit /b 1
    )

    call :get_basename "%name%" basename

    if exist "_output\pdfs\!basename!.typ" (
        del "_output\pdfs\!basename!.typ"
        echo Deleted _output/pdfs/!basename!.typ
    )

    if exist "_output\pdfs\!basename!.pdf" (
        del "_output\pdfs\!basename!.pdf"
        echo Deleted _output/pdfs/!basename!.pdf
    )

    if exist "_output\jpgs\!basename!.pdf.jpg" (
        del "_output\jpgs\!basename!.pdf.jpg"
        echo Deleted _output/jpgs/!basename!.pdf.jpg
    )

    if exist "_output\!basename!.mp4" (
        del "_output\!basename!.mp4"
        echo Deleted _output/!basename!.mp4
    )

    exit /b 0
)

echo Unknown command: %cmd%
echo Usage: gen.bat [add^|clean] "song name"
exit /b 1

:get_basename
set "%~2=%~n1"
exit /b 0
