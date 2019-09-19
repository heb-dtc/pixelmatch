PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.boardHighlightX = 0
    self.boardHighlightY = 0

    self.highlightedTile = nil

    self.target = 10000
    self.moves = 15
    self.score = 0

    Timer.every(0.5, function()
        self.rectHighlighted = not self.rectHighlighted
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
        self.boardHighlightY = math.min(ROW_NUMBER - 1, self.boardHighlightY + 1)
    elseif love.keyboard.wasPressed('left') then
        self.boardHighlightX = math.max(0, self.boardHighlightX - 1)
    elseif love.keyboard.wasPressed('right') then
        self.boardHighlightX = math.min(COL_NUMBER - 1, self.boardHighlightX + 1)
    end

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then

        -- if same tile as currently highlighted, deselect
        local x = self.boardHighlightX + 1
        local y = self.boardHighlightY + 1

        -- if nothing is highlighted, highlight current tile
        if not self.highlightedTile then
            self.highlightedTile = self.board.tiles[y][x]

            -- if we select the position already highlighted, remove highlight
        elseif self.highlightedTile == self.board.tiles[y][x] then
            self.highlightedTile = nil

            -- if the difference between X and Y combined of this highlighted tile
            -- vs the previous is not equal to 1, also remove highlight
        elseif math.abs(self.highlightedTile.gridX - x) + math.abs(self.highlightedTile.gridY - y) > 1 then
            self.highlightedTile = nil
        else

            -- swap grid positions of tiles
            local tempX = self.highlightedTile.gridX
            local tempY = self.highlightedTile.gridY

            local newTile = self.board.tiles[y][x]

            self.highlightedTile.gridX = newTile.gridX
            self.highlightedTile.gridY = newTile.gridY
            newTile.gridX = tempX
            newTile.gridY = tempY

            -- swap tiles in the tiles table
            self.board.tiles[self.highlightedTile.gridY][self.highlightedTile.gridX] =
            self.highlightedTile

            self.board.tiles[newTile.gridY][newTile.gridX] = newTile

            -- tween coordinates between the two so they swap
            Timer.tween(0.1, {
                [self.highlightedTile] = {x = newTile.x, y = newTile.y},
                [newTile] = {x = self.highlightedTile.x, y = self.highlightedTile.y}
            })

            -- once the swap is finished, we can tween falling blocks as needed
                 :finish(function()
                self:calculateMatches()
            end)
        end
    end

    --self:calculateMatches()

    Timer.update(dt)
end

function PlayState:calculateMatches()
    local matches = self.board:calculateMatches()
    if matches then
        print('there are ', #matches, ' matches found')
        for k, match in pairs(matches) do

            local matchPoints = 0
            for w, tile in pairs(match) do
                matchPoints = matchPoints + 10
            end

            self.score = self.score + matchPoints + #match * 50
        end

        -- remove any tiles that matched from the board, making empty spaces
        self.board:removeMatches()

        -- gets a table with tween values for tiles that should now fall
        local tilesToFall = self.board:getFallingTiles()

        -- tween new tiles that spawn from the ceiling over 0.25s to fill in
        -- the new upper gaps that exist
        Timer.tween(0.25, tilesToFall):finish(function()

            -- recursively call function in case new matches have been created
            -- as a result of falling blocks once new blocks have finished falling
            self:calculateMatches()
        end)
    end
end

function PlayState:render()
    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)

    love.graphics.setFont(titleFont)
    love.graphics.print(self.target, VIRTUAL_WIDTH / 2 - 90, 5)

    love.graphics.setFont(largeFont)
    love.graphics.print(self.moves, 32 + 4, self.board.y + (ROW_NUMBER * TILE_SIZE) + 4)
    love.graphics.print(self.score, VIRTUAL_WIDTH - 42, self.board.y + (ROW_NUMBER * TILE_SIZE) + 4)

    self.board:render()

    -- render highlighted tile if it exists
    if self.highlightedTile then

        -- multiply so drawing white rect makes it brighter
        love.graphics.setBlendMode('add')

        love.graphics.setColor(255/255, 255/255, 255/255, 96/255)
        love.graphics.rectangle('fill', (self.highlightedTile.gridX - 1) * TILE_SIZE + self.board.x,
                (self.highlightedTile.gridY - 1) * TILE_SIZE + self.board.y, TILE_SIZE, TILE_SIZE, 4)

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