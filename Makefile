WEBPACK = ./node_modules/.bin/webpack
LESSC = ./node_modules/.bin/lessc
COFFEELINT = ./node_modules/.bin/coffeelint
DOCCO = ./node_modules/.bin/docco



all: dist/anno.js dist/anno.css

dist/anno.js: src/anno.litcoffee
	$(WEBPACK)

dist/anno.css: src/anno.less
	$(LESSC) src/anno.less > dist/anno.css

docco: src/*.litcoffee
	$(DOCCO) -o ./docco src/*.litcoffee

lint: src/anno.litcoffee
	$(COFFEELINT) src/anno.litcoffee

clean:
	rm -rf anno.* docco
