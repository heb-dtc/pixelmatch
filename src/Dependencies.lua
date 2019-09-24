push = require 'lib/push'

Class = require 'lib/class'

Timer = require 'lib/knife.timer'
Event = require 'lib/knife.event'
Easing = require 'lib/easing'

require 'src/Util'

require 'src/constants'
require 'src/StateMachine'

require 'src/Board'
require 'src/Tile'

require 'src/ui/Text'
require 'src/ui/TextBox'

require 'src/states/BaseState'
require 'src/states/PlayState'

gTextures = {
    ['pieces'] = love.graphics.newImage('assets/match3.png'),
    ['moves_container'] = love.graphics.newImage('assets/moves_container.png'),
    ['score_container'] = love.graphics.newImage('assets/score_container.png'),
    ['score_target_container'] = love.graphics.newImage('assets/score_target_container.png'),
}

gFrames = {
    ['tiles'] = GenerateQuads(gTextures['pieces'], TILE_SIZE, TILE_SIZE)
}
