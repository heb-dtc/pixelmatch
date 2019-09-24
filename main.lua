love.graphics.setDefaultFilter('nearest', 'nearest')

require 'src/Dependencies'

function love.load()
    love.window.setTitle('PixelMatch')

    smallFont = love.graphics.newFont('fonts/font.ttf', 8)
    largeFont = love.graphics.newFont('fonts/font.ttf', 16)
    titleFont = love.graphics.newFont('fonts/font.ttf', 64)

    love.graphics.setFont(smallFont)

    math.randomseed(os.time())

    -- TODO extract to some AppSettingsConfigurator class
    local settings
    local screenWidth, screenHeight = love.window.getDesktopDimensions()
    if love.system.getOS() == 'iOS' or love.system.getOS() == 'Android' then
        settings = {
            fullscreen = false,
            resizable = false,
            vsync = true,
            highdpi = true
        }
        screenHeight, screenWidth = love.window.getDesktopDimensions()
        print(screenWidth, screenHeight)
    else
        settings = {
            fullscreen = false,
            resizable = true,
            vsync = true
        }
        screenHeight, screenWidth = WINDOW_HEIGHT, WINDOW_WIDTH
    end

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, screenWidth, screenHeight, settings)

    gStateMachine = StateMachine {
        ['play'] = function()
            return PlayState()
        end
    }
    gStateMachine:change('play')

    love.keyboard.keysPressed = {}
    love.mouse.buttonPressed = {}
    love.mouse.dragEvent = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    Timer.update(dt)
    gStateMachine:update(dt)
    love.keyboard.keysPressed = {}
    love.mouse.buttonPressed = {}

    -- clear dragging events only once over
    if #love.mouse.dragEvent > 0 then
        if love.mouse.dragEvent[1].isOver == true then
            love.mouse.dragEvent = {}
        end
    end
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true

    if key == 'escape' then
        love.event.quit()
    elseif key == 'r' then
        gStateMachine:change('play')
    end
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.mousepressed(x, y, button, istouch)
    mx, my = push:toGame(x, y)

    if mx ~= nil and my ~= nil then
        love.mouse.buttonPressed[button] = { x = mx, y = my }
        love.mouse.dragEvent[button] = { startX = mx, startY = my, isOver = false }
    end
end

function love.mousereleased(x, y, button, istouch)
    mx, my = push:toGame(x, y)

    if mx ~= nil and my ~= nil then
        local event = love.mouse.dragEvent[button]
        -- check if event is not nil
        if event ~= nil then
            event.endX = mx
            event.endY = my
            event.isOver = true
            love.mouse.dragEvent[button] = event
        end
    end
end

function love.mouse.wasPressed(button)
    return love.mouse.buttonPressed[button]
end

function love.draw()
    push:start()

    love.graphics.setColor(255 / 255, 0.4, 1, 255 / 255)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    love.graphics.setColor(255 / 255, 255 / 255, 255 / 255, 255 / 255)
    gStateMachine:render()

    push:finish()
end