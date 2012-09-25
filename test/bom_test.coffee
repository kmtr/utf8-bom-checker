assert = require 'assert'
path = require 'path'

bom = require '../src/bom'

NO_BOM_FILE_PATH = './test/resources/bom/test_nobom.txt'
BOM_FILE_PATH = './test/resources/bom/test_bom_utf8.txt'
BOM_DIR_PATH = './test/resources/bom'
NO_BOM_DIR_PATH = './test/resources/nobom'

describe 'bom', ()->
  describe 'check', ()->
    it '文字列にBOMが含まれていたら、trueを返す。',
      ()-> assert.equal true, bom.check (bom.BOM_CHAR + "test")

    it '文字列にBOMが含まれていたら、falseを返す。',
      ()-> assert.equal false, bom.check "test"

  describe 'check_file', ()->
    describe '指定したファイルの中身をチェックし', ()->
      it '内容にBOMが含まれていたらtrueを返す。',
        (done)-> bom.check_file BOM_FILE_PATH,
            (hasBOM)->
              assert.equal true, hasBOM
              done()
      it '内容にBOMが含まれていなければfalseを返す。',
        (done)-> bom.check_file NO_BOM_FILE_PATH,
            (hasBOM)->
              assert.equal false, hasBOM
              done()
      it 'ファイル以外が指定された場合falseを返す。',
        (done)-> bom.check_file BOM_DIR_PATH,
            (hasBOM)->
              assert.equal false, hasBOM
              done()

  describe 'check_dir', ()->
    describe '指定したディレクトリ内のファイルをチェックし', ()->
      it 'BOM付きファイルがあれば、そのファイル名の配列を返す。',
        (done)-> bom.check_dir BOM_DIR_PATH,
          (bomfiles)->
            assert.equal (path.basename BOM_FILE_PATH), bomfiles[0]
            done()
      it '1つもBOM付きファイルがなければ空配列を返す。',
        (done)-> bom.check_dir NO_BOM_DIR_PATH,
          (bomfiles)->
            assert.equal 0, bomfiles.length
            done()
