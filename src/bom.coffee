fs = require 'fs'
path = require 'path'

async = require 'async'

BOM_CHAR = new Buffer([0xEF, 0xBB, 0xBF]).toString()

check = (string)->
  boms = (bom for bom in string when bom == BOM_CHAR)
  boms.length > 0

check_file = (filepath, callback)->
  fs.stat (filepath), (err, stats)->
    if err then throw err
    if stats.isFile()
      fs.readFile filepath, 'UTF-8',
        (err, data)->
          if err then throw err else callback (check data)
    else
      callback false

check_dir = (dirpath, callback)->
  dir = (path.resolve dirpath) + path.sep
  fs.readdir (dir), (err, files)->
    tasks = for file in files
      do (file) ->
        (callback)->
          check_file (dir + file), (
            (hasBOM)->callback null, [file, hasBOM])

    async.parallel tasks, (err, results)->
      bomfiles = (hasBOM[0] for hasBOM in results when hasBOM[1])
      callback(bomfiles)

main = (files)->
  for filepath in files
    do (filepath) ->
      fs.stat (filepath), (err, stats)->
        if err then return
        if stats.isFile()
          check_file filepath, (hasBOM)->
            if hasBOM then console.log filepath
        if stats.isDirectory()
          check_dir filepath, (bomfiles)->
            for bomfile in bomfiles
              do (bomfile)-> console.log bomfile

module.exports.check = check
module.exports.check_file = check_file
module.exports.check_dir = check_dir
module.exports.BOM_CHAR = BOM_CHAR
main process.argv.slice 2
