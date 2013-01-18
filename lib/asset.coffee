crypto = require 'crypto'
path = require 'path'
EventEmitter = require('events').EventEmitter

class exports.Asset extends EventEmitter
  constructor: (@config, callback) ->
    throw new Error 'must provide config' if not @config?
    @src = @config.src or throw new Error 'must provide src parameter'
    @dst = @config.dst or @src
    @on 'newListener', (event, listener) =>
      listener() if event == 'complete' and @data?
    @on 'complete', =>
      @md5 = crypto.createHash('md5').update(@data).digest 'hex'
      @ext = path.extname @dst
      @url = "#{@dst.slice(0, @dst.length - @ext.length)}-#{@md5}#{@ext}"
      switch @type
        when 'text/javascript'
          @tag = "<script type='text/javascript' src='#{@url}'></script>"
        when 'text/css'
          @tag = "<link ref='stylesheet' href='#{@url}' />"
        else
          @tag = @url
      callback @ if callback
    super()
    @wrap() if callback

  wrap: ->
    throw new Error 'override me!'
