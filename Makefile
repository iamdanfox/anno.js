all: anno.js anno.css

anno.js: src/anno.coffee
	coffee -bl -o . src/anno.coffee

anno.css: src/anno.less
	lessc src/anno.less > anno.css

clean:
	rm anno.js anno.css
