all: anno.js anno.css

anno.js: anno.coffee
	coffee -bc anno.coffee

anno.css: anno.less
	lessc anno.less > anno.css

clean:
	rm anno.js anno.css
