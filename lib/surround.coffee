_ = require 'underscore'
{Point, Range} = require 'atom'

module.exports = new
class Surround
  @shiftKey    = 16
  @surrounders =
    '222' : open: '\'', close: '\'', padded: false
    's222': open: '"',  close: '"',  padded: false
    's57' : open: "(",  close: ')',  padded: false
    '219' : open: '[',  close: ']',  padded: false
    's219': open: '{',  close: '}',  padded: false

  Object.defineProperty @prototype, 'view',
    get: ->
      atom.workspaceView.getActiveView()

  Object.defineProperty @prototype, 'editor',
    get: ->
      atom.workspace.getActiveEditor()

  Object.defineProperty @prototype, 'cursor',
    get: =>
      atom.workspace.getActiveEditor().getCursor()

  constructor: ->
    _.bindAll @, 'disable', 'keydown'

  activate: (state) ->
    atom.workspaceView.command 'surround:surround', => @surround()
    atom.workspaceView.command 'surround:delete'  , => @remove()

  surround: ->
    @action = 'Surround'
    @view.on 'keydown', @keydown

  remove: ->
    @action = 'Remove'
    @view.on 'keydown', @keydown

  keydown: (e) ->
    e.preventDefault()

    if e.which == Surround.shiftKey
      @shifted = true
      @view.on 'keyup', @disable
      return

    surrounder = @getSurrounder(e.which)

    if surrounder
      @editor.transact => @["do#{@action}"](surrounder)
    @disable()

  doRemove: (surrounder) ->
    startPosition   = @editor.getCursorBufferPosition()
    currentPosition = startPosition

    offset = 0
    value  = null

    until (offset <= 0 && value == surrounder.open) || (currentPosition.column == 0)
      [currentPosition, value] = @seekBack(currentPosition)
      if value == surrounder.open
        offset -= 1
      else if value == surrounder.close
        offset += 1

    if offset <= 0 && value == surrounder.open
      openPosition = currentPosition

    currentPosition = startPosition

    offsert = 0
    value   = @characterAt(currentPosition)

    until (offset <= 0 && value == surrounder.close) || (currentPosition.column == 1000)
      [currentPosition, value] = @seekForward(currentPosition)
      if value == surrounder.close
        offset -= 1
      else if value == surrounder.open
        offset += 1

    if offset <= 0 && value == surrounder.close
      closePosition = currentPosition

    if openPosition && closePosition
      @editor.setCursorBufferPosition(openPosition)
      @editor.delete()
      @editor.setCursorBufferPosition(new Point(closePosition.row, closePosition.column - 1))
      @editor.delete()
      @editor.setCursorBufferPosition(new Point(startPosition.row, startPosition.column - 1))

  seekBack: (position) ->
    newPosition = new Point(position.row, position.column - 1)
    text = @characterAt(newPosition)
    [newPosition, text]

  seekForward: (position) ->
    newPosition = new Point(position.row, position.column + 1)
    text = @characterAt(newPosition)
    [newPosition, text]

  characterAt: (start) ->
    @editor.getTextInRange([start, new Point(start.row, start.column + 1)])

  doSurround: (surrounder) ->
    selection = @getSelection()
    selection.insertText("#{surrounder.open}#{selection.getText()}#{surrounder.close}")

  getSelection: ->
    if @editor.getSelection().getText()
      @editor.getSelection()
    else
      @editor.selectWord()
      @editor.getSelection()

  getSurrounder: (keycode) ->
    if @shifted
      keycode = "s#{keycode}"
    Surround.surrounders[keycode.toString()]

  disable: ->
    @shifted = false
    @view.off 'keydown', @keydown
    @view.off 'keyup',   @keyup
