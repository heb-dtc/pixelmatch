Text = Class{}

function Text:init(params)
    self.x = params.x
    self.length = params.length
    self.height = params.height
    self.y = params.y + (self.height / 2) - (params.font:getHeight() / 2)
    self.alignMode = params.alignMode
end

function Text:render(text)
    love.graphics.printf(text, self.x, self.y, self.length, self.alignMode)
end