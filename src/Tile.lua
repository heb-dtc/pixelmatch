Tile = Class{}

function Tile:init(x, y, color)
    self.gridX = x
    self.gridY = y

    self.x = (self.gridX - 1) * TILE_SIZE
    self.y = (self.gridY - 1) * TILE_SIZE

    self:getColor(color)
end

function Tile:getColor(color)
    if color == 1 then
        self.colorIndex = 1
    elseif color == 2 then
        self.colorIndex = 6 * 1 + 1
    elseif color == 3 then
        self.colorIndex = 6 * 8 + 1
    elseif color == 4 then
        self.colorIndex =  6 * 10 + 1
    elseif color == 5 then
        self.colorIndex = 6 * 11 + 1
    elseif color == 6 then
        self.colorIndex = 6 * 13 + 1
    elseif color == 7 then
        self.colorIndex = 6 * 16 + 1
    end
end

function Tile:render(x, y)

    -- draw shadow
    love.graphics.setColor(34/255, 32/255, 52/255, 255/255)
    love.graphics.draw(gTextures['pieces'], gFrames['tiles'][self.colorIndex], self.x + x + 2, self.y + y + 2)

    -- draw tile itself
    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
    love.graphics.draw(gTextures['pieces'], gFrames['tiles'][self.colorIndex], self.x + x, self.y + y)
end