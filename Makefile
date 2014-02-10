all: anno.js anno.css

anno.js: src/anno.litcoffee
	coffee -bl -o . src/anno.litcoffee

anno.css: src/anno.less
	lessc src/anno.less > anno.css

clean:
	rm anno.js anno.css
