class Perfmeter
  constructor: ->
    @mt1 = process.hrtime()
    @t1 = new Date().getTime()

    @stop = ->
      @mt2 = process.hrtime(@mt1)
      @t2 = new Date().getTime()
      console.log "#{@mt2} (#{@t2 - @t1} ms)"

module.exports = Perfmeter
