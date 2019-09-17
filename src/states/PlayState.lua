PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.boardHighlightX = 0
    self.boardHighlightY = 0

    self.highlightedTile = nil

    self.score = 0
    self.timer = 60

    Timer.every(0.5, function()
        self.rectHighlighted = not self.rectHighlighted
    end)

    Timer.every(1, function()
        self.timer = self.timer - 1
    end)
end

function PlayState:enter(params)
    self.board = Board(32, 64)
end

function PlayState:update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    -- move cursor around based on bounds of grid, playing sounds
    if love.keyboard.wasPressed('up') then
        self.boardHighlightY = math.max(0, self.boardHighlightY - 1)
    elseif love.keyboard.wasPressed('down') then
        self.boardHighlightY = math.min(COL_NUMBER - 1, self.boardHighlightY + 1)
    elseif love.keyboard.wasPressed('left') then
        self.boardHighlightX = math.max(0, self.boardHighlightX - 1)
    elseif love.keyboard.wasPressed('right') then
        self.boardHighlightX = math.min(ROW_NUMBER - 1, self.boardHighlightX + 1)
    end

    Timer.update(dt)
end

function PlayState:render()
    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)

    self.board:render()

    -- render highlighted tile if it exists
    if self.highlightedTile then

        -- multiply so drawing white rect makes it brighter
        love.graphics.setBlendMode('add')

        love.graphics.setColor(255/255, 255/255, 255/255, 96/255)
        love.graphics.rectangle('fill', (self.highlightedTile.gridX - 1) * 32 + (VIRTUAL_WIDTH - 272),
                (self.highlightedTile.gridY - 1) * 32 + 16, 32, 32, 4)

        -- back to alpha
        love.graphics.setBlendMode('alpha')
    end

    -- render highlight rect color based on timer
    if self.rectHighlighted then
        love.graphics.setColor(217/255, 87/255, 99/255, 255/255)
    else
        love.graphics.setColor(172/255, 50/255, 50/255, 255/255)
    end

    -- draw actual cursor rect
    love.graphics.setLineWidth(4)
    love.graphics.rectangle('line', self.boardHighlightX * TILE_SIZE + self.board.x,
            self.boardHighlightY * TILE_SIZE + self.board.y, TILE_SIZE, TILE_SIZE, 4)
end