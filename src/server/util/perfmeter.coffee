class Perfmeter
  constructor: ->
    @t1 = process.hrtime()

    @stop = ->
      @t2 = process.hrtime(@t1)
      console.log @t2

module.exports = Perfmeter
