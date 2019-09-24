TextBox = Class{}

function TextBox:init(params)
    self.x = params.x
    self.y = params.y
    self.font = params.font
    self.image = gTextures[params.texture]
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()

    self.text = Text {
        x = self.x,
        y = self.y,
        font = params.font,
        height = self.height,
        length = self.width,
        alignMode = 'center'
    }
end

function TextBox:render(text)
    love.graphics.setFont(self.font)
    love.graphics.draw(self.image, self.x, self.y)
    self.text:render(text)
end