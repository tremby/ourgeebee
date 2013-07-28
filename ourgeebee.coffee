###
Our Gee B nonograms
===================

An RGB nonogram game

*for Gee's birthday, 2013*

By Bart Nagel <bart@tremby.net>

Licence undecided: email me to enquire
###

$ ->
	boards = []
	board = null
	boardNum = 0
	boardsComplete = []
	gameActive = false
	customboard = false

	$.cookie.json = true
	boardsComplete = $.cookie 'boardsComplete' if $.cookie 'boardsComplete'
	boardNum = $.cookie 'boardNum' if $.cookie 'boardNum'

	k = r: false, g: false, b: false
	r = r: true, g: false, b: false
	y = r: true, g: true, b: false
	g = r: false, g: true, b: false
	c = r: false, g: true, b: true
	b = r: false, g: false, b: true
	m = r: true, g: false, b: true
	w = r: true, g: true, b: true

	parseSolution = (string) ->
		solution = []
		for row, rowString of string.split ','
			rowArray = []
			for col, char of rowString.split ''
				switch char
					when 'k' then rowArray.push k
					when 'b' then rowArray.push b
					when 'g' then rowArray.push g
					when 'c' then rowArray.push c
					when 'r' then rowArray.push r
					when 'm' then rowArray.push m
					when 'y' then rowArray.push y
					when 'w' then rowArray.push w
					else throw new Error "unexpected character #{char}"
			solution.push rowArray
		return solution

	$document = $ document
	$window = $ window
	$loading = $ '#loading'
	$board = $ '#board'
	$boardArea = $ '#board-area'
	$previewBoard = $ '#preview-board'
	$body = $ 'body'
	$clue = $ '#clue'
	$win = $ '#win'
	$winMessage = $win.find '.message'
	$boardList = $ '#choose-board'
	$tama = $ '#tama'

	initBoard = ($board, board) ->
		$board.empty()
		$table = $('<table/>').addClass('board').appendTo $board
		$tbody = $('<tbody/>').appendTo $table
		$tr = $('<tr/>').appendTo $tbody
		for col in [-1...board.solution[0].length]
			$th = $('<th/>').appendTo $tr
			if col >= 0
				cells = []
				for row in [0...board.solution.length]
					cells.push board.solution[row][col]
				$th.append groupElements calculateGroups cells
		for row in [0...board.solution.length]
			$tr = $('<tr/>').appendTo $tbody
			$th = $('<th/>').prependTo $tr
			for col in [0...board.solution[0].length]
				$('<td/>').append('<div/>').data('solution', board.solution[row][col]).appendTo $tr
			$th.append groupElements calculateGroups board.solution[row]

	getRow = ($td) -> $td.parent().index() - 1
	getCol = ($td) -> $td.index() - 1
	getCellByCoords = (row, col, $b = $board) ->
		$b.find('tr:eq(' + (row + 1) + ') td:eq(' + col + ')')
	getCells = ($b = $board) -> $b.find 'td'

	checkForWin = ->
		allGood = true
		for colour in ['red', 'green', 'blue']
			ccorrect = correctColour colour
			$tama.find('.' + colour).toggleClass 'tama', ccorrect
			unless ccorrect
				allGood = false
		if allGood
			endGame()
			$win.show('slow')
			$winMessage.text board.win
			if boardNum not in boardsComplete
				boardsComplete.push boardNum
				unless customBoard
					$.cookie.json = true
					$.cookie 'boardsComplete', boardsComplete, expires: 3650
					showBoardThumbnail boardNum

	correctColour = (colour) ->
		allGood = true
		getCells().each ->
			$td = $ @
			col = getCol $td
			row = getRow $td
			correctStatus = board.solution[row][col][colour.substr 0, 1]
			unless $td.hasClass(colour) and correctStatus or $td.hasClass('not-' + colour) and not correctStatus
				allGood = false
				return false
		return allGood

	calculateGroups = (cells) ->
		colourGroups =
			red: [0]
			green: [0]
			blue: [0]
		for index in [0...cells.length]
			for colour, groups of colourGroups
				if cells[index][colour.substr 0, 1]
					groups[groups.length - 1]++
				else unless groups[groups.length - 1] is 0
					groups.push 0
		for colour, groups of colourGroups
			# remove trailing zero if there is at least one positive group
			if groups.length > 1 and groups[groups.length - 1] is 0
				groups.pop()
		return colourGroups

	groupElements = (colourGroups) ->
		$elements = $()
		for colour, groups of colourGroups
			$div = $('<div/>').addClass(colour).addClass('groups')
			$('<div/>').addClass('group').text(group).appendTo $div for group in groups
			$elements = $elements.add $div
		return $elements

	checkGroups = (colourGroups, $cells, $th) ->
		for colour, groups of colourGroups
			$groups = $th.find('.' + colour + '.groups .group')
			$groups.removeClass 'complete'

			# iterate over the cells and return true if we should iterate over 
			# them again in reverse order
			iterate = (groups, $groups, $cells) ->
				numberOn = $cells.filter('.' + colour).length
				numberOff = $cells.filter('.not-' + colour).length
				numberShouldBeOn = 0
				numberShouldBeOn += group for group in groups
				numberUnknown = $cells.length - numberOn - numberOff

				# special case for empty row -- only mark it as complete if all 
				# cells are marked empty
				if numberShouldBeOn is 0
					if numberUnknown is 0 and numberOn is 0
						$groups.addClass 'complete'
					doInReverse = false
					return doInReverse

				# step from one edge until an unknown or the end of the row is 
				# reached, checking off complete groups as they are found
				doInReverse = false
				groupNum = 0
				matched = 0
				$cells.each (i) ->
					$td = $ @
					tdStatus = undefined
					if $td.hasClass colour
						tdStatus = true
					if $td.hasClass('not-' + colour)
						tdStatus = false
					unless tdStatus?
						doInReverse = true
						return false # $.each break
					if tdStatus
						# switched on cell
						if matched >= groups[groupNum]
							# too many for the current group -- abort and search 
							# from the other side
							doInReverse = true
							return false # $.each break
						else
							matched++

							# if this is the last cell of the row and we've just 
							# completed a group, mark it complete
							if i >= $cells.length - 1 and matched is groups[groupNum]
								$groups.eq(groupNum).addClass 'complete'

							# if all groups are already complete and this is an 
							# extra switched on cell, mark the last group as 
							# incomplete and abort
							if groupNum > groups.length - 1
								$groups.last().removeClass 'complete'
					else
						# switched off cell
						if matched is groups[groupNum]
							$groups.eq(groupNum).addClass 'complete'
							groupNum++
							matched = 0
						else if matched > 0
							doInReverse = true
							return false # $.each break

				return doInReverse

			# choose which direction to do first -- whichever side the first 
			# switched on cell is closest to
			closestToStart = Infinity
			closestToEnd = Infinity
			$tmpCells = $cells
			$tmpCells.each (i) ->
				$td = $ @
				if $td.hasClass colour
					closestToStart = Math.min closestToStart, i
					closestToEnd = Math.min closestToEnd, ($tmpCells.length - 1 - i)
			if closestToStart > closestToEnd
				groups = groups.reverse()
				$groups = $($groups.get().reverse())
				$tmpCells = $($tmpCells.get().reverse())

			if iterate groups, $groups, $tmpCells
				iterate groups.reverse(), $($groups.get().reverse()), $($tmpCells.get().reverse())

	getColTh = (col) -> $board.find "tr:first th:eq(#{col + 1})"
	getTr = (row) -> $board.find "tr:eq(#{row + 1})"
	getRowTh = (row) -> getTr(row).find 'th'

	checkColGroups = (col) ->
		cells = []
		$cells = $()
		for row in [0...board.solution.length]
			cells.push board.solution[row][col]
			$cells = $cells.add getCellByCoords row, col
		colourGroups = calculateGroups cells
		checkGroups colourGroups, $cells, getColTh col
	checkRowGroups = (row) ->
		$tr = getTr row
		$cells = $tr.find 'td'
		$th = $tr.find 'th'
		colourGroups = calculateGroups board.solution[row]
		checkGroups colourGroups, $cells, $th
	checkAllGroups = ->
		for col in [0...board.solution[0].length]
			checkColGroups col
		for row in [0...board.solution.length]
			checkRowGroups row

	showSolution = ($b = $board, b = board) ->
		getCells($b).each ->
			$td = $ @
			col = getCol $td
			row = getRow $td
			for colour in ['red', 'green', 'blue']
				$td.toggleClass colour, b.solution[row][col][colour.substr 0, 1]
				$td.toggleClass 'not-' + colour, not b.solution[row][col][colour.substr 0, 1]

	handleKeyModeColour = (e) ->
		char = String.fromCharCode e.keyCode
		switch char
			when '`', 'À', 'W'
				modeColour 'all'
			when '1', 'R'
				modeColour 'red'
			when '2', 'G'
				modeColour 'green'
			when '3', 'B'
				modeColour 'blue'
			else
				return
		e.preventDefault()

	handleKeyModeAction = (e) ->
		if $('input[name="mode-action"]:checked').val() is 'keyboard'
			switch e.keyCode
				when 16, 39 # shift, right
					modeAction if e.type is 'keydown' then 'on' else 'unknown'
				when 17, 38 # control, up
					modeAction if e.type is 'keydown' then 'off' else 'unknown'
				else
					return
			e.preventDefault()

	handleKeyModeSingleToggle = (e) ->
		if e.charCode is 32
			$('input[name="mode-single"]').click()
			e.preventDefault()

	initGame = (newBoard, state) ->
		gameActive = true
		board = newBoard
		$clue.text board.clue
		$win.hide()
		$winMessage.empty()
		initBoard $board, board
		initBoard $previewBoard, board
		checkGroups()
		$document.on 'keydown', handleKeyModeColour
		$document.on 'keydown keyup', handleKeyModeAction
		$document.on 'keypress', handleKeyModeSingleToggle
		$board.on 'mousedown', 'td', cellMouseDown
		$body.on 'mouseup', cellMouseUp
		$body.on 'mousemove', cellDrag
		modeColour 'all'
		modeAction 'unknown'
		$('input[name="mode-action"][value="keyboard"]').click()
		$('input[name="mode-single"]').removeAttr 'checked'
		$boardList.find('li').removeClass('current').eq(boardNum).addClass('current')
		$previewBoard.show()
		if state?
			loadState state
		else
			$.cookie.json = false
			$.removeCookie 'state'
		checkAllGroups()
		checkForWin()
		$previewBoard.width() # force re-flow
		resizeHandler()
		$previewBoard.height $previewBoard.width() * board.solution.length / board.solution[0].length

	endGame = ->
		$document.off 'keydown', handleKeyModeColour
		$document.off 'keydown keyup', handleKeyModeAction
		$document.off 'keypress', handleKeyModeSingleToggle
		$board.off 'mousedown', 'td', cellMouseDown
		$body.off 'mouseup', cellMouseUp
		$body.off 'mousemove', cellDrag
		$body.removeClass 'mode-red mode-green mode-blue mode-off mode-unknown mode-on mode-single'
		$previewBoard.hide()
		gameActive = false

	modeColour = (colour) ->
		if colour is 'all'
			$body.addClass 'mode-red mode-green mode-blue'
		else
			$body.toggleClass 'mode-red', colour is 'red'
			$body.toggleClass 'mode-green', colour is 'green'
			$body.toggleClass 'mode-blue', colour is 'blue'
		$('input[name="mode-colour"][value="' + colour + '"]').click()

	modeAction = (action) ->
		$body.toggleClass 'mode-off', action is 'off'
		$body.toggleClass 'mode-unknown', action is 'unknown'
		$body.toggleClass 'mode-on', action is 'on'

	modeSingle = ->
		$body.toggleClass 'mode-single', $('input[name="mode-single"]').is ':checked'

	$dragStart = null

	cellMouseDown = (e) ->
		e.preventDefault()
		$dragStart = $ @
		cellDrag e

	cellMouseUp = (e) ->
		$td = if $(e.target).is('td') then $(e.target) else $(e.target).closest 'td'
		unless $td.length
			clearDrag()
			return
		e.preventDefault()
		$cells = draggedCells(e)
		$cells.each ->
			paintCell $ @
		clearDrag()

	draggedCells = (e) ->
		unless e and $dragStart
			return $()
		$td = if $(e.target).is('td') then $(e.target) else $(e.target).closest 'td'
		unless $td.length
			return $()
		startRow = getRow $dragStart
		startCol = getCol $dragStart
		endRow = getRow $td
		endCol = getCol $td
		$cells = $()
		if startRow is endRow
			for i in [startCol..endCol]
				$cells = $cells.add getCellByCoords startRow, i
		else if startCol is endCol
			for i in [startRow..endRow]
				$cells = $cells.add getCellByCoords i, startCol
		return $cells

	cellDrag = (e) ->
		$cells = draggedCells e
		getCells().filter($cells).addClass('selected').end().not($cells).removeClass('selected')

	clearDrag = ->
		$dragStart = null
		cellDrag()

	paintCell = ($td) ->
		$previewTd = getCellByCoords getRow($td), getCol($td), $previewBoard
		if $body.is '.mode-red'
			$td.add($previewTd).toggleClass 'red', $body.is '.mode-on'
			$td.add($previewTd).toggleClass 'not-red', $body.is '.mode-off'
		if $body.is '.mode-green'
			$td.add($previewTd).toggleClass 'green', $body.is '.mode-on'
			$td.add($previewTd).toggleClass 'not-green', $body.is '.mode-off'
		if $body.is '.mode-blue'
			$td.add($previewTd).toggleClass 'blue', $body.is '.mode-on'
			$td.add($previewTd).toggleClass 'not-blue', $body.is '.mode-off'
		checkRowGroups getRow $td
		checkColGroups getCol $td
		checkForWin()
		unless customBoard
			debouncedSaveState()

	$('input[name="mode-colour"]').on 'change', ->
		$(@).blur()
		modeColour $(@).val()

	$('input[name="mode-action"]').on 'change', ->
		$(@).blur()
		modeAction $(@).val()

	$('input[name="mode-single"]').on 'change', ->
		$(@).blur()
		modeSingle()

	$('button[name="clear-current"]').on 'click', ->
		$(@).blur()
		for colour in ['red', 'green', 'blue']
			if $body.is ".mode-#{colour}"
				getCells().add(getCells $previewBoard).removeClass "#{colour} not-#{colour}"
		checkAllGroups()
		checkForWin()

	$('.show-gallery').on 'click', (e) ->
		e.preventDefault()
		$ul = $ '#gallery ul'
		if $ul.is ':visible'
			$ul.hide()
			return
		$ul.empty()
		$ul.show()
		for i in [0...boards.length] when i in boardsComplete
			$li = $ '<li/>'
			$li.append $('<h4/>').text boards[i].clue
			$li.append $('<p/>').text boards[i].win
			$div = $ '<div/>'
			$li.append $div
			$li.appendTo $ul
			initBoard $div, boards[i]
			showSolution $div, boards[i]
			$div.height $div.width() * boards[i].solution.length / boards[i].solution[0].length

	$boardList.on 'click', 'li', ->
		$li = $ @
		if not $li.hasClass('current')
			saveState()
			changeBoard $li.index(), $.cookie('state_' + $li.index())

	$previewBoard.click ->
		$el = $ @
		wwidth = $window.width()
		$el.css
			left: if $el.position().left > wwidth / 2 then 10 else wwidth - $el.width() - 10

	$win.find('#next-board').click ->
		changeBoard boardNum + 1

	changeBoard = (num, state) ->
		endGame()
		boardNum = num
		$.cookie.json = true
		$.cookie 'boardNum', boardNum, expires: 3650
		initGame boards[boardNum], state

	showBoardThumbnail = (boardNum) ->
		$li = $boardList.find('li:eq(' + boardNum + ')')
		$li.addClass 'complete'
		$li.text ''
		initBoard $li, boards[boardNum]
		showSolution $li, boards[boardNum]

	saveState = ->
		state = []
		getCells().each ->
			$td = $ @
			col = getCol $td
			row = getRow $td
			pixel = 0
			for colour, index in ['red', 'green', 'blue']
				trit = if $td.hasClass colour then 2 else if $td.hasClass "not-#{colour}" then 0 else 1
				pixel += trit * Math.pow 3, index
			state.push String.fromCharCode(0x40 + pixel)
		state = state.join ''
		$.cookie.json = false
		$.cookie 'state_' + boardNum, state, expires: 3650
	debouncedSaveState = _.debounce saveState, 500

	loadState = (state) ->
		$cells = getCells()
		for char, index in state.split ''
			$td = $cells.eq(index)
			unless $td.length
				return
			$tds = $td.add getCellByCoords getRow($td), getCol($td), $previewBoard
			pixel = char.charCodeAt(0) - 0x40
			for colour, index in ['red', 'green', 'blue']
				trit = Math.floor(pixel / Math.pow(3, index)) % 3
				$tds.toggleClass colour, trit is 2
				$tds.toggleClass "not-#{colour}", trit is 0

	resizeHandler = ->
		# vertically centre the tama indicators
		$tama.css
			top: ($boardArea.height() - $tama.outerHeight()) / 2

		# make sure preview is within the screen
		wwidth = $window.width()
		$previewBoard.css
			left: if $previewBoard.position().left <= wwidth / 2 then 10 else wwidth - $previewBoard.width() - 10
	$window.resize _.debounce resizeHandler, 100
	resizeHandler()

	if /[?&]board=/.test window.location.search
		base64 = window.location.search.replace /[?&]board=(.*?)($|&)/, '$1'
		board = $.parseJSON atob base64
		board.solution = parseSolution board.solution
		boards = [board]
		customBoard = true
		changeBoard 0
		$boardList.hide()
		$('#gallery').hide()
		$loading.delay(500).fadeOut()
	else
		$.getJSON 'boards.json', (data) ->
			$.each data, (k, v) ->
				data[k].solution = parseSolution v.solution
			boards = data
			$.cookie.json = false
			changeBoard boardNum, $.cookie('state_' + boardNum)

			$template = $boardList.find('li:first').removeClass 'current complete'
			$boardList.empty()
			for i in [0...boards.length]
				$li = $template.clone()
				if i is boardNum
					$li.addClass 'current'
				$li.appendTo $boardList
				$li.width $li.height() * boards[i].solution[0].length / boards[i].solution.length
				if i in boardsComplete
					showBoardThumbnail i
					$li.attr 'title', boards[i].win
				else
					$li.attr 'title', boards[i].clue
			$loading.delay(500).fadeOut()
