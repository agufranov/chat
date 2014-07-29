class Perfmeter
  constructor: ->
    @reset = ->
      @mt1 = process.hrtime()
      @t1 = new Date().getTime()

    @reset()

    @restart = (msg) ->
      @dmt = process.hrtime(@mt1)
      @dt = new Date().getTime() - @t1
      @reset()
      if @dt > 1000
        console.log "#{msg} #{@dmt} (#{@dt} ms)"

module.exports = Perfmeter
