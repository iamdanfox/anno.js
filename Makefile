all: dist/anno.min.js dist/anno.min.css

dist/anno.js: src/anno.litcoffee
	webpack

dist/anno.css: src/anno.less
	lessc src/anno.less > dist/anno.css

docco: src/*.litcoffee
	docco -o ./docco src/*.litcoffee

dist/anno.min.js: dist/anno.js
	uglifyjs dist/anno.js --compress --mangle > dist/anno.min.js

dist/anno.min.css: dist/anno.css
	lessc --clean-css dist/anno.css > dist/anno.min.css

gzip: dist/anno.min.js dist/anno.min.css
	gzip --to-stdout --best --keep dist/anno.min.js > dist/anno.min.js.gz
	gzip --to-stdout --best --keep dist/anno.min.css > dist/anno.min.css.gz
	@echo "\x1b[0;32m`wc -c anno.min.js.gz anno.min.css.gz`\x1b[0m" # switch to green, wc, switch back

lint: src/anno.litcoffee
	coffeelint src/anno.litcoffee

clean:
	rm -rf anno.* docco
