@echo off
setlocal enabledelayedexpansion

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

    if not exist "typs" mkdir "typs"
    if not exist "typ-pdf" mkdir "typ-pdf"
    if not exist "typ-pdf-jpg" mkdir "typ-pdf-jpg"
    if not exist "mp4" mkdir "mp4"

    python scripts/gen_typ.py "%name%"

    call :get_basename "%name%" basename

    echo Compiling typst...
    typst compile --root . "typs/!basename!.typ" "typ-pdf/!basename!.pdf"

    echo Converting to JPG...
    magick -density 300 "typ-pdf/!basename!.pdf[0]" -resize x1080 -background white -alpha remove -quality 90 "typ-pdf-jpg/!basename!.pdf.jpg"

    if exist "!basename!.mp3" (
        echo Creating MP4...
        ffmpeg -loop 1 -framerate 1 -i "typ-pdf-jpg/!basename!.pdf.jpg" -i "!basename!.mp3" -c:v libx264 -tune stillimage -c:a copy -pix_fmt yuv420p -shortest -y "mp4/!basename!.mp4"
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

    if exist "typ-pdf/!basename!.pdf" (
        del "typ-pdf/!basename!.pdf"
        echo Deleted typ-pdf/!basename!.pdf
    )

    if exist "typ-pdf-jpg/!basename!.pdf.jpg" (
        del "typ-pdf-jpg/!basename!.pdf.jpg"
        echo Deleted typ-pdf-jpg/!basename!.pdf.jpg
    )

    exit /b 0
)

echo Unknown command: %cmd%
echo Usage: gen.bat [add^|clean] "song name"
exit /b 1

:get_basename
set "%~2=%~n1"
exit /b 0