gem install sass
sass --update web/src:web/public
echo "done"
browserify web/src/js/index.js -o web/public/js/index.js
