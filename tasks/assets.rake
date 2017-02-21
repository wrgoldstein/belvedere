namespace :assets do
  task :precompile do
    `npm install`
    `sass --update web/src:web/public`
    `browserify web/src/js/index.js -o web/public/js/index.js`
  end
end
