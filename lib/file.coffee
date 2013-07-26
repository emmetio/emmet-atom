# Plugin used by emmet to identify file paths

Path = require 'path'
Fs = require 'fs'

module.exports =
  locateFile: (editorFile, imgPath) ->
    # creates realImgPath based on CSS file and image filename
    Path.join(Path.dirname(editorFile), imgPath)

  read: (realImgPath, callback) ->
    Fs.readFile(realImgPath, 'binary', callback)

  getExt: (realImgPath) ->
    Path.extname(realImgPath)
