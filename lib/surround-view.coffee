{View} = require 'atom'

module.exports =
class SurroundView extends View
  @content: ->
    @div class: 'surround overlay from-top', =>
      @div "The Surround package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "surround:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "SurroundView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
