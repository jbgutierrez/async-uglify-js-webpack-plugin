crypto = require 'crypto'
fs = require 'fs'
path = require 'path'
UglifyJS = require 'uglify-js'
UglifyCSS = require 'uglifycss'

timers = {}
options =
  delay: 5000,
  minifyOptions: {},
  logger: false,
  done: (path, originalContents) -> log "minimized #{path}"
  debug: false

log = (msg...) ->
  console.log msg... if options.logger

debug = (msg...) ->
  console.log msg... if options.debug

md5 = (buffer) ->
  content = buffer.toString()
  hash = crypto.createHash 'md5'
  hash.update content
  hash.digest 'hex'

isStale = (chunk) ->
  hash = md5 fs.readFileSync chunk.path
  stale = hash isnt chunk.fullhash
  log "minification cancelled (file has changed!) #{chunk.path}" if stale
  stale

minimizeTask = (chunk) ->
  ->
    fs.readFile chunk.path, (err, buffer) ->
      throw err if err
      return if isStale chunk

      log "starting minification #{chunk.path}"

      contents = buffer.toString()
      result = if /.js/.test chunk.path
        UglifyJS.minify(contents, options.minifyOptions).code
      else
        UglifyCSS.processString contents, options.minifyOptions

      fs.writeFile chunk.path, result, (err) ->
        throw err if err

        options.done chunk.path, contents

scheduleMinification = (file, delay) ->
  chunk = id: file, file: file
  clearTimeout timers[chunk.id]
  chunk.path = path.resolve options.outputPath, chunk.file
  fs.readFile chunk.path, (err, buffer) ->
    chunk.fullhash = md5 buffer
    timers[chunk.id] = setTimeout minimizeTask(chunk), options.delay

class AsyncUglifyJsPlugin
  constructor: (_options = {}) ->
    options[option] = value for option, value of _options
    options.minifyOptions.fromString = true

  apply: (compiler) ->
    options.outputPath = compiler.options.output.path or '.'
    previousHash = null
    compiler.plugin 'done', (stats) ->
      stats = stats.toJson()
      if previousHash isnt stats.hash
        debug "schedule minification"
        for chunk in stats.chunks
          scheduleMinification file for file in chunk.files
        previousHash = stats.hash

module.exports = AsyncUglifyJsPlugin
