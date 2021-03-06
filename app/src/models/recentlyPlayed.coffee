_ = require 'underscore'
Spine._ = require 'underscore'

fsUtils = require '../lib/fs-utils'
path = require 'path'
fs = require 'fs'

class RecentlyPlayed extends Spine.Model
  @configure "RecentlyPlayed"

  constructor: ->
    super
    @games = []
    @settings = new App.Settings
    @load()

  filePath: ->
    path.join(@settings.romsPath(), 'recently-played.json') if @settings.romsPath()

  load: ->
    if @filePath() && fsUtils.exists(@filePath())
      data = JSON.parse(fs.readFileSync(@filePath(), 'utf8'))
      @games = []
      
      for gameBlob in data['games']
        romPath = path.join(@settings.romsPath(), gameBlob['gameConsole'], gameBlob['filename'])
        if fsUtils.exists(romPath)
          gameConsole = new App.GameConsole(prefix: gameBlob['gameConsole'])
          @games.push(new App.Game(filePath: romPath, gameConsole: gameConsole))

      _.filter @games, (game) ->
        game.imageExists()

  save: ->
    data = {'games': @games}
    fsUtils.writeSync(@filePath(), JSON.stringify(data))

  addGame: (game) ->
    @games.unshift(game)
    @games = @games.unique()
    @games = @games[0..5]
    @save()


module.exports = RecentlyPlayed
