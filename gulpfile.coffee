gulp = require 'gulp'
coffee = require 'gulp-coffee'
less = require 'gulp-less'
jade = require 'gulp-jade'
coffeelint = require 'gulp-coffeelint'
supervisor = require 'gulp-supervisor'
concat = require 'gulp-concat'
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'
livereload = require 'gulp-livereload'
watch = require 'gulp-watch'
server = require('tiny-lr')()

# Lint Task
gulp.task 'lint', ->
  gulp.src('./src/**/*.coffee')
    .pipe coffeelint()
    .pipe coffeelint.reporter()

# gulp.task 'jade', ->
#   gulp.src('./src/views/**/*.jade')
#     .pipe jade pretty: true
#     .pipe uglify()
#     .pipe gulp.dest('./build/src')
#     .pipe livereload server

# gulp.task 'coffee', ->
#   gulp.src('./src/**/*.coffee')
#     .pipe coffee()
#     .pipe gulp.dest('./build/src')
#     .pipe livereload server

# gulp.task 'less', ->
#   gulp.src('./assets/css/**/*.less')
#     .pipe less compress: true
#     .pipe gulp.dest './build/assets/css'
#     .pipe livereload server

gulp.task 'server', ->
  require('./build/src/app')

gulp.task 'watch', ->
  supervisor './src/app.coffee',
    args: [],
    watch: [ 'src' ],
    ignore: [ 'src/public', 'src/views' ],
    pollInterval: 500,
    extensions: [ 'js', 'coffee', 'json' ],
    exec: 'coffee',


# gulp.task 'watch', ['server'], ->
#   server.listen 35729, (err) -> if err then return console.error err
#   gulp.watch './src/**/*.coffee', ['coffee', 'lint']
#   # gulp.watch './src/**/*.jade', ['jade']
#   gulp.watch './assets/css/**/*.less', ['less']
#   gulp.watch('./build/**').on 'change', (file) ->
#     server.changed file.path    

# Default Task
gulp.task 'default', ['lint', 'watch']
