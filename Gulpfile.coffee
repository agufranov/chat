gulp = require "gulp"

gulp_require = (name) ->
  eval "#{name} = require(\"gulp-#{name}\")"

[gulp_require name for name in [
  "watch"
  "coffee"
  "sourcemaps"
  "using"
  "nodemon"
  "supervisor"
  "jade"
]]

gulp.task "default", [ "server-watch", "server", "client-watch" ]

# Server tasks
gulp.task "server-watch", [ "server-watch-coffee" ]

gulp.task "server-watch-coffee", ->
  watch glob: "./src/server/**/*.coffee"
    .pipe using({ prefix: "Compiling server CoffeeScript", color: "red" })
    .pipe sourcemaps.init()
    .pipe coffee()
    .pipe sourcemaps.write()
    .pipe gulp.dest "./build/server/"

gulp.task "server", [ "nodemon" ]

gulp.task "nodemon", ->
  nodemon
    script: "./build/server/app.js"
    ignore: [ "client/**" ]
    ext: "js"
    nodeArgs: [ "--debug" ]

gulp.task "supervisor", ->
  supervisor "./build/server/app.js",
    watch: "./build/server"
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
