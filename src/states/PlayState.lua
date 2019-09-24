PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.target = 10000
    self.moves = 15
    self.score = 0

    self.scoreBox = TextBox {
        x = 0,
        y = VIRTUAL_HEIGHT - 32,
        texture = 'score_target_container',
        font = largeFont
    }
    self.movesBox = TextBox {
        x = 0,
        y = 12,
        texture = 'moves_container',
        font = smallFont
    }
    self.scoreTargetBox = TextBox {
        x = VIRTUAL_WIDTH - 80,
        y = 12,
        texture = 'score_container',
        font = largeFont
    }
end

function PlayState:enter(params)
    self.board = Board(BOARD_X, BOARD_Y)
end

function PlayState:getTile(x, y)
    -- offset the x and y coords with the board coords
    x = x - BOARD_X
    y = y - BOARD_Y

    print('getting tile @coords ', x, ' and ', y)
    local column = (x / TILE_SIZE) + 1
    column = column - (column % 1)

    local row = (y / TILE_SIZE) + 1
    row = row - (row % 1)

    print('row ', row, ' - col ', column)

    local tile = self.board.tiles[row][column]
    print_r(tile)
    return tile
end

function PlayState:swapTiles(tileA, tileB)
    if math.abs(tileA.gridX - tileB.gridX) + math.abs(tileA.gridY - tileB.gridY) > 1 then
        print('tiles are too far, cant swap!')
    else
        print('tiles can swap')
        -- swap grid positions of tiles
        local tempX = tileA.gridX
        local tempY = tileA.gridY

        tileA.gridX = tileB.gridX
        tileA.gridY = tileB.gridY
        tileB.gridX = tempX
        tileB.gridY = tempY

        -- swap tiles in the tiles table
        self.board.tiles[tileA.gridY][tileA.gridX] =
        tileA

        self.board.tiles[tileB.gridY][tileB.gridX] = tileB

        -- tween coordinates between the two so they swap
        Timer.tween(0.1, {
            [tileA] = {x = tileB.x, y = tileB.y},
            [tileB] = {x = tileA.x, y = tileA.y}
        })

        -- once the swap is finished, we can tween falling blocks as needed
             :finish(function()
            self:calculateMatches()
        end)
    end
end

function PlayState:update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    -- check if a drag event occured
    if #love.mouse.dragEvent > 0 then
        local dragEvent = love.mouse.dragEvent[1]
        -- if the drag event is over, it will be consumed
        if dragEvent.isOver then
            local startTile = self:getTile(dragEvent.startX, dragEvent.startY)
            local endTile = self:getTile(dragEvent.endX, dragEvent.endY)
            self:swapTiles(startTile, endTile)
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

    self.movesBox:render(self.moves)
    self.scoreTargetBox:render(self.target)
    self.scoreBox:render(self.score)

    self.board:render()
end