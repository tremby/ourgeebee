pngparse = require 'pngparse'
async = require 'async'
child_process = require 'child_process'
fs = require 'fs'
glob = require 'glob'

boards = [
	{
		source: 'boards/w.xcf'
		clue: "Stick with \"all channels\" mode for this first one"
		win: "It's a letter W in white"
	}
	{
		source: 'boards/r.xcf'
		clue: "Now let's go one channel at a time"
		win: "A red letter R for Rogie"
	}
	{
		source: 'boards/g.xcf'
		clue: "Also pretty easy..."
		win: "It's your other letter!"
	}
	{
		source: 'boards/b.xcf'
		clue: "My turn now"
		win: "Bees are fuzzy."
	}
	{
		source: 'boards/star.xcf'
		clue: "This time some colours are mixed"
		win: "YOU ARE A STAR PLAYER"
	}
	{
		source: 'boards/sunset.xcf'
		clue: "A nice time of day"
		win: "That's meant to be a boat"
	}
	{
		source: 'boards/birdie.xcf'
		clue: "A thing you are welcome to enjoy for your birthday"
		win: "If you like"
	}
	{
		source: 'boards/flower.xcf'
		clue: "Something I like a lot to play with"
		win: "Flower"
	}
	{
		source: 'boards/breakfast.xcf'
		clue: "Something you keep telling me I should have"
		win: "You might have to squint a bit, but there are meant to be eggs and bacon and beans"
	}
	{
		source: 'boards/icecream.xcf'
		clue: "Another thing you like"
		win: "Maybe it's coffee flavoured, but it doesn't look like it (mainly because I don't have brown available)"
	}
	{
		source: 'boards/rainbow.xcf'
		clue: "Something colourful, but alas only a single one"
		win: "All the way across the sky"
	}
	{
		source: 'boards/watchmen.xcf'
		clue: "Not sure if you've seen this"
		win: "Watchmen logo"
	}
	{
		source: 'boards/beer.xcf'
		clue: "One of my favourite things"
		win: "Yay beer"
	}
	{
		source: 'boards/wine.xcf'
		clue: "And while we're on the subject"
		win: "Yay wine"
	}
	{
		source: 'boards/finn.xcf'
		clue: "One heroic dude"
		win: "It's Finn the Human!"
	}
	{
		source: 'boards/jakeface.xcf'
		clue: "Another cool guy, full of secrets"
		win: "Jake!"
	}
	{
		source: 'boards/lsp.xcf'
		clue: "Duchess Gummybuns"
		win: "Drama bomb!"
	}
	{
		source: 'boards/ladyrainicorn.xcf'
		clue: "A very nice Korean lady"
		win: "I'm puppies?"
	}
	{
		source: 'boards/pizza.xcf'
		clue: "Yum yum"
		win: "15 pixels isn't enough room for all the toppings"
	}
	{
		source: 'boards/sushi.xcf'
		clue: "Our favourite thing to eat"
		win: "What do you think is in it?"
	}
]

makeBoard = (board, callback) ->
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
		pngparse.parse stdout, (err, data) ->
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

async.map boards, makeBoard, (err, results) ->
	throw err if err?
	console.log JSON.stringify results

xcfs = glob.sync('boards/*.xcf')
console.warn "Unused board: #{xcf}" for xcf in xcfs when xcf not in (board.source for board in boards)
