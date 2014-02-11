all: anno.js anno.css

anno.js: src/anno.litcoffee
	coffee -bl -o . src/anno.litcoffee

anno.css: src/anno.less
	lessc src/anno.less > anno.css

docco: src/*.litcoffee
	docco -o ./docco src/*.litcoffee

clean:
	rm -rf anno.js anno.css docco
