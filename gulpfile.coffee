gulp = require 'gulp'
coffee = require 'gulp-coffee'
less = require 'gulp-less'
jade = require 'gulp-jade'
coffeelint = require 'gulp-coffeelint'
supervisor = require 'gulp-supervisor'
concat = require 'gulp-concat'
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'
clean = require 'gulp-clean'
livereload = require 'gulp-livereload'
watch = require 'gulp-watch'
# server = require('tiny-lr')()

# Clean build dir
gulp.task 'clean', ->
  gulp.src 'build', read: false
    .pipe clean()
    .on 'error', console.log

# gulp.task 'jade', ->
#   gulp.src('./server/views/**/*.jade')
#     .pipe jade pretty: true
#     .pipe uglify()
#     .pipe gulp.dest('./build/src')
#     .pipe livereload server

# Lint Task
gulp.task 'lint', ->
  gulp.src('./server/src/**/*.coffee')
    .pipe coffeelint()
    .pipe coffeelint.reporter()

gulp.task 'js', ->
  gulp.src('./client/js/**/*.coffee')
    .pipe coffee()
    .pipe gulp.dest('./build/assets/js')
    .on 'error', console.log
    # .pipe livereload server

gulp.task 'css', ->
  gulp.src('./client/css/**/*.less')
    .pipe less compress: true
    .pipe gulp.dest './build/assets/css'
    .on 'error', console.log
    # .pipe livereload server

gulp.task 'server', ['lint', 'css', 'js'], ->
  require './app'

gulp.task 'watch', ->
  gulp.watch './client/js/**/*.coffee', ['lint', 'js']
  gulp.watch './client/css/**/*.less', ['css']
  # gulp.watch('./build/**').on 'change', (file) ->
  #   server.changed file.path    
  supervisor './app.coffee',
    args: [],
    watch: [ 'server', 'app.coffee' ],
    ignore: [ 'server/views'],
    pollInterval: 500,
    extensions: [ 'js', 'coffee', 'json' ],
    exec: 'coffee',

# Default Task
gulp.task 'build', ['clean', 'coffee', 'jade', 'css']
gulp.task 'default', ['lint', 'watch']
