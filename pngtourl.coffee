makeboard = require './makeboard'

process.argv.shift()
process.argv.shift()

if process.argv.length is 0
	console.log "Usage: coffee pngtourl.coffee <path to PNG or XCF> <clue message> <magaling message>"
	process.exit 1
unless process.argv.length is 3
	throw new Error 'expected 3 arguments: path to PNG or XCF file, clue message, magaling message'

filename = process.argv[0]
clue = process.argv[1]
magaling = process.argv[2]

makeboard.makeBoard
	source: filename
	clue: clue
	win: magaling
, (err, board) ->
	if err?
		throw err
	console.log 'http://tremby.net/ourgeebee/?board=' + new Buffer(JSON.stringify board).toString('base64')
