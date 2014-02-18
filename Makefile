all: anno.js anno.css

anno.js: src/anno.litcoffee
	coffee --bare --literate -o . src/anno.litcoffee

anno.css: src/anno.less
	lessc src/anno.less > anno.css

docco: src/*.litcoffee
	docco -o ./docco src/*.litcoffee

anno.min.js: anno.js scrollintoview/jquery.scrollintoview.js
	uglifyjs anno.js scrollintoview/jquery.scrollintoview.js --compress --mangle > anno.min.js

anno.min.css: anno.css
	lessc --clean-css anno.css > anno.min.css

gzip: anno.min.js anno.min.css
	gzip --to-stdout --best --keep anno.min.js > anno.min.js.gz
	gzip --to-stdout --best --keep anno.min.css > anno.min.css.gz
	@echo "\x1b[0;32m`wc -c anno.min.js.gz anno.min.css.gz`\x1b[0m" # switch to green, wc, switch back

clean:
	rm -rf anno.* docco



