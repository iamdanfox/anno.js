WEBPACK = ./node_modules/.bin/webpack
LESSC = ./node_modules/.bin/lessc
COFFEELINT = ./node_modules/.bin/coffeelint
UGLIFYJS = ./node_modules/.bin/uglifyjs
DOCCO = ./node_modules/.bin/docco



all: dist/anno.min.js dist/anno.min.css

dist/anno.js: src/anno.litcoffee
	$(WEBPACK)

dist/anno.css: src/anno.less
	$(LESSC) src/anno.less > dist/anno.css

docco: src/*.litcoffee
	$(DOCCO) -o ./docco src/*.litcoffee

dist/anno.min.js: dist/anno.js
	$(UGLIFYJS) dist/anno.js --compress --mangle > dist/anno.min.js

dist/anno.min.css: dist/anno.css
	$(LESSC) --clean-css dist/anno.css > dist/anno.min.css

gzip: dist/anno.min.js dist/anno.min.css
	gzip --to-stdout --best --keep dist/anno.min.js > dist/anno.min.js.gz
	gzip --to-stdout --best --keep dist/anno.min.css > dist/anno.min.css.gz
	@echo "\x1b[0;32m`wc -c anno.min.js.gz anno.min.css.gz`\x1b[0m" # switch to green, wc, switch back

lint: src/anno.litcoffee
	$(COFFEELINT) src/anno.litcoffee

clean:
	rm -rf anno.* docco
