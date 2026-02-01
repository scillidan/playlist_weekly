# justfile

default:
	just all

all:
	just build-pdf
	just convert-to-jpg
	just convert-to-mp4

clean:
	find . -name "*.pdf" -delete
	# find . -name "*.pdf.jpg" -delete
	find . -name "*.mp4" -delete

watch:
	find . -name "*.typ" | entr -c just all

build-pdf:
	find . -name "*.typ" -exec typst compile {} \;

batch-jpg:
	bash ./_convert-to-jpg.sh

batch-mp4:
	bash ./_convert-to-mp4.sh

test filename:
    magick -density 300 "{{filename}}.pdf" -resize x1080 -background white -alpha remove -quality 90 "{{filename}}.pdf.jpg" && ffmpeg -loop 1 -framerate 1 -i "{{filename}}.pdf.jpg" -i "{{filename}}.mp3" -c:v libx264 -tune stillimage -c:a copy -pix_fmt yuv420p -shortest -y "{{filename}}.mp4"