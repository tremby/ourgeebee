child_process = require 'child_process'
pngparse = require 'pngparse'
fs = require 'fs'

pngToBoard = (string, board, callback) ->
	pngparse.parse string, (err, data) ->
		if err?
			callback err
			return
		unless data.channels is 3
			callback new Error 'only accept 3-channel PNGs'
			return
		rows = []
		for row in [0...data.height]
			colours = []
			for col in [0...data.width]
				offset = (row * data.width + col) * data.channels
				pixel =
					red: data.data[offset]
					green: data.data[offset + 1]
					blue: data.data[offset + 2]
				for colour, value of pixel
					unless value is 0 or value is 255
						callback new Error "#{colour} component of pixel (#{col},#{row}) of image #{file} isn't either fully off or on"
						return
				if pixel.red
					if pixel.green
						if pixel.blue
							c = 'w'
						else
							c = 'y'
					else
						if pixel.blue
							c = 'm'
						else
							c = 'r'
				else
					if pixel.green
						if pixel.blue
							c = 'c'
						else
							c = 'g'
					else
						if pixel.blue
							c = 'b'
						else
							c = 'k'

				colours.push c
			rows.push colours.join ''
		board.solution = rows.join ','
		callback null, board

makeBoard = (board, callback) ->
	if /\.png$/.test board.source
		fs.readFile board.source, (err, data) ->
			if err?
				throw err
			pngToBoard data, board, callback
	else
		p = child_process.spawn 'xcf2png', [board.source]
		stdoutChunks = []
		stderrChunks = []
		p.stdout.on 'data', (data) -> stdoutChunks.push data
		p.stderr.on 'data', (data) -> stderrChunks.push data
		p.on 'close', (code) ->
			if stderrChunks.length
				callback new Error "got stderr: #{stderrChunks}"
				return
			if code isnt 0
				callback new Error "got non-success error code #{code}"
				return
			length = 0
			for chunk in stdoutChunks
				length += chunk.length
			stdout = new Buffer length
			offset = 0
			for chunk in stdoutChunks
				chunk.copy stdout, offset, 0, chunk.length
				offset += chunk.length
			pngToBoard stdout, board, callback

module.exports = {
	makeBoard
}
