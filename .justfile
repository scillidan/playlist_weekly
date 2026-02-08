default:
	just all

all:
	just pdf
	just pdf-jpg
	just mp4

pdf:
	find . -name "*.typ" -exec typst compile {} \;

pdf-jpg:
	mkdir -p pdf-jpg
	for f in *.pdf; do \
		basename=$(basename "$f" .pdf); \
		magick -density 300 "$f[0]" -resize x1080 -background white -alpha remove -quality 90 "pdf-jpg/$basename.pdf.jpg"; \
	done

mp4:
	mkdir -p mp4
	find pdf-jpg -maxdepth 1 -name "*.jpg" -print0 | while IFS= read -r -d '' f; do \
		basename=$(basename "$f" .pdf.jpg | sed 's/｜/|/g'); \
		img_file="$f"; \
		aud_file="${basename}.mp3"; \
		if [ -f "$aud_file" ]; then \
			ffmpeg -loop 1 -framerate 1 -i "$img_file" -i "$aud_file" -c:v libx264 -tune stillimage -c:a copy -pix_fmt yuv420p -shortest -y "mp4/${basename}.mp4"; \
		fi; \
	done

clean:
	find . -name "*.pdf" -delete
	# find . -name "*.pdf.jpg" -delete
	find . -name "*.mp4" -delete

add basename:
	@mkdir -p pdf-jpg mp4
	@audio_file="" && \
	for ext in mp3; do \
		if [ -f "{{basename}}.$$ext" ]; then \
			audio_file="{{basename}}.$$ext"; \
			break; \
		fi; \
	done
	@typst compile "txt-pdf/{{basename}}.typ" "txt-pdf/{{basename}}.pdf" 2>/dev/null
	@if [ -f "txt-pdf/{{basename}}.pdf" ]; then \
		magick -density 300 "txt-pdf/{{basename}}.pdf[0]" -resize x1080 \
			-background white -alpha remove -quality 90 \
			"pdf-jpg/{{basename}}.pdf.jpg" 2>/dev/null; \
	fi
	@if [ -n "$$audio_file" ] && [ -f "pdf-jpg/{{basename}}.pdf.jpg" ]; then \
		ffmpeg -loop 1 -framerate 1 -i "pdf-jpg/{{basename}}.pdf.jpg" \
			-i "$$audio_file" -c:v libx264 -tune stillimage -c:a copy \
			-pix_fmt yuv420p -shortest -y "mp4/{{basename}}.mp4" 2>/dev/null; \
	fi
	@echo "✅ {{basename}}"