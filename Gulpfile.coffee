gulp = require "gulp"

gulp_require = (name) ->
  eval "#{name} = require(\"gulp-#{name}\")"

[gulp_require name for name in [
  "watch"
  "coffee"
  "coffeelint"
  "jade"
  "sourcemaps"
  "using"
  "nodemon"
  "supervisor"
  "webserver"
  "livereload"
]]

gulp.task "default", [ "server-watch", "server", "client-watch", "client-webserver", "livereload" ]

# Server tasks
gulp.task "server-watch", [ "server-watch-coffee" ]

gulp.task "server-watch-coffee", ->
  watch glob: "./src/server/**/*.coffee"
    .pipe using({ prefix: "Compiling server CoffeeScript", color: "red" })
    .pipe sourcemaps.init()
    .pipe coffee()
    .pipe sourcemaps.write()
    .pipe gulp.dest "./build/server/"

gulp.task "coffeelint", ->
  gulp.src "./src/**/*.coffee"
    .pipe coffeelint()
    .pipe coffeelint.reporter()

gulp.task "server", [ "nodemon" ]

gulp.task "client-webserver", ->
  gulp.src "./build/client/"
    .pipe webserver
      livereload: true
      directoryListing: false
      port: 8002

gulp.task "client-connect", ->
  connect.server
    root: "./build/client/"
    port: 8002
    livereload: false

gulp.task "livereload", ->
  watch glob: "./build/client/**/*.js", ->
    #console.log arguments

gulp.task "nodemon", ->
  nodemon
    script: "./build/server/app.js"
    ignore: [ "client/**" ]
    ext: "js"
    nodeArgs: [ "--debug" ]

gulp.task "supervisor", ->
  supervisor "./build/server/app.js",
    watch: "./build/server/"
    forceWatch: true
    extensions: [ "js" ]
    debug: true
    noRestartOn: "exit"

# Client tasks
gulp.task "client-watch", [ "client-watch-coffee", "client-watch-jade" ]

gulp.task "client-watch-coffee", ->
  watch glob: "./src/client/**/*.coffee"
    .pipe using({ prefix: "Compiling client CoffeeScript:", color: "red" })
    .pipe sourcemaps.init()
    .pipe coffee()
    .pipe sourcemaps.write()
    .pipe gulp.dest "./build/client/"

gulp.task "client-watch-jade", ->
  watch glob: "./src/client/**/*.jade"
    .pipe using({ prefix: "Compiling Jade:", color: "red" })
    .pipe jade()
    .pipe gulp.dest "./build/client/"
    #.pipe livereload()
