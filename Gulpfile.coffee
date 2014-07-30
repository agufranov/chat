gulp = require "gulp"

gulp_require = (name) ->
  eval "#{name} = require(\"gulp-#{name}\")"

[gulp_require name for name in [
  "watch"
  "coffee"
  "coffeelint"
  "jade"
  "less"
  "sourcemaps"
  "using"
  "nodemon"
  "supervisor"
  "webserver"
  "livereload"
]]

lazypipe = require "lazypipe"

src =
  serverCoffee: [ "./src/**/*.coffee", "!./src/public/**" ]

gulp.task "default", [ "server", "server-watch", "client-watch", "client-webserver", "livereload" ]

# Server tasks
gulp.task "server-watch", [ "server-watch-coffee" ]

gulp.task "server-only", [ "server", "server-watch" ]

gulp.task "server-watch-coffee", ->
  watch glob: src.serverCoffee
    .pipe compileCoffee()

gulp.task "coffeelint", ->
  gulp.src "./src/**/*.coffee"
    .pipe coffeelint()
    .pipe coffeelint.reporter()

compileCoffee = lazypipe()
  .pipe using, prefix: "Compiling CoffeeScipt", color: "red"
  .pipe sourcemaps.init
  .pipe coffee
  .pipe sourcemaps.write
  .pipe gulp.dest, "./build/"

gulp.task "server-compile-coffee", ->
  gulp.src src.serverCoffee
    .pipe compileCoffee()

gulp.task "server", [ "nodemon" ]

gulp.task "nodemon", ->
  nodemon
    script: "./build/app.js"
    ignore: [ "public/**" ]
    ext: "js"
    nodeArgs: [ "--debug" ]

gulp.task "monitor", ->
  nodemon
    script: "./build/monitor/monitor.js"
    ignore: [ "**/*.*" ]

gulp.task "supervisor", ->
  supervisor "./build/server/app.js",
    watch: "./build/server/"
    forceWatch: true
    extensions: [ "js" ]
    debug: true
    noRestartOn: "exit"

# Client tasks
gulp.task "client-watch", [ "client-watch-coffee", "client-watch-jade", "client-watch-less" ]

gulp.task "client-watch-coffee", ->
  watch glob: "./src/public/**/*.coffee"
    .pipe using({ prefix: "Compiling client CoffeeScript:", color: "red" })
    .pipe sourcemaps.init()
    .pipe coffee()
    .pipe sourcemaps.write()
    .pipe gulp.dest "./build/public/"

gulp.task "client-watch-jade", ->
  watch glob: "./src/public/**/*.jade"
    .pipe using({ prefix: "Compiling Jade:", color: "red" })
    .pipe jade()
    .pipe gulp.dest "./build/public/"

gulp.task "client-watch-less", ->
  watch glob: "./src/public/**/*.less"
    .pipe using({ prefix: "Compiling Sass:", color: "red" })
    .pipe less()
    .pipe gulp.dest "./build/public/"

gulp.task "client-webserver", ->
  gulp.src "./build/public/**"
    .pipe webserver
      livereload: true
      directoryListing: false
      port: 8002

gulp.task "client-connect", ->
  connect.server
    root: "./build/public/"
    port: 8002
    livereload: false

gulp.task "livereload", ->
  watch glob: "./build/public/**/*.js", ->
    #console.log arguments
