SurroundView = require './surround-view'

module.exports =
  surroundView: null

  activate: (state) ->
    @surroundView = new SurroundView(state.surroundViewState)

  deactivate: ->
    @surroundView.destroy()

  serialize: ->
    surroundViewState: @surroundView.serialize()
