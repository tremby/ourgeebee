async = require 'async'
glob = require 'glob'
makeboard = require './makeboard'

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
		source: 'boards/ladyrainicorn.xcf'
		clue: "A very nice Korean lady"
		win: "I'm puppies?"
	}
	{
		source: 'boards/kitty.xcf'
		clue: "Meow"
		win: "It's a kitty!"
	}
	{
		source: 'boards/pizza.xcf'
		clue: "Yum yum"
		win: "15 pixels isn't enough room for all the toppings"
	}
	{
		source: 'boards/lsp.xcf'
		clue: "Duchess Gummybuns"
		win: "Drama bomb!"
	}
	{
		source: 'boards/sushi.xcf'
		clue: "Our favourite thing to eat"
		win: "What do you think is in it?"
	}
	{
		source: 'boards/strawberrymilkshake.xcf'
		clue: "Slurp slurp"
		win: "Shame actual pink isn't available"
	}
	{
		source: 'boards/captainviridian.xcf'
		clue: "Virtuous voyager"
		win: "It's Captain Viridian!"
	}
	{
		source: 'boards/pirateship.xcf'
		clue: "Do gee and bee, then aggressively guess in the most prominent part of arr. You'll get it."
		win: "Arrrrrr"
	}
	{
		source: 'boards/speedtriple.xcf'
		clue: "Vroom. Do red last."
		win: "Speedy woooo"
	}
	{
		source: 'boards/hellokitty.xcf'
		clue: "An easy one"
		win: "Hi-eeeey"
	}
	{
		source: 'boards/nyancat.xcf'
		clue: "Colourful, delicious, magical and cute all at once"
		win: "Nya nya nyanya nya nyanyanya nya nya nya nyanyanyanyanyanyanyanyanyanyanyanyanyanyanya nya nyanyanyanyanyanyanyanyanyanyanyanyanya nyanyanyanyanyanyanyanyanya nya nya"
	}
	{
		source: 'boards/sadface.xcf'
		clue: "I'm sorry"
		win: "Please forgive me"
	}
	{
		source: 'boards/us-in-manila.xcf'
		clue: "If you'll excuse the Simpsonization"
		win: "I wonder if you know which photo this is from"
	}
	{
		source: 'boards/beach.xcf'
		clue: "A place nice on shine days"
		win: "Do you know which island that is?"
	}
	{
		source: 'boards/caesar.xcf'
		clue: "Brunch companion"
		win: "Meant to be lime and celery."
	}
	{
		source: 'boards/finnjake.xcf'
		clue: "Best buds"
		win: "Let's always be stupid, forever!"
	}
	{
		source: 'boards/penguin.xcf'
		clue: "Down south"
		win: "Pingu pingu pingu pingu"
	}
	{
		source: 'boards/puppy.xcf'
		clue: "When my dad was a kid he ate egg shells with one of these"
		win: "He was called Bow Wow"
	}
	{
		source: 'boards/philippine-flag.xcf'
		clue: "Think of your old home"
		win: "Have a good trip!"
	}
	{
		source: 'boards/grus.xcf'
		clue: "A very good boy"
		win: "Not a pest"
	}
	{
		source: 'boards/yellow-cat.xcf'
		clue: "Litte harder but you already know what it is"
		win: "Kitty kitty kitty kitty"
	}
	{
		source: 'boards/pokeball.xcf'
		clue: "Throw to catch"
		win: "’em all"
	}
]

async.map boards, makeboard.makeBoard, (err, results) ->
	throw err if err?
	console.log JSON.stringify results

xcfs = glob.sync('boards/*.xcf')
console.warn "Unused board: #{xcf}" for xcf in xcfs when xcf not in (board.source for board in boards)
