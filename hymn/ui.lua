local quickie = require "libs.quickie"
local LogicCore = require "hymn.logiccore"
local ui = {}

local inputHandler
local entityManager

local cursor = love.graphics.newImage("images/ui/mouseCursor.png")
local pathFlag = love.graphics.newImage("images/ui/heart.png")

function ui.load()
    -- preload fonts
    fonts = {
        [12] = love.graphics.newFont("fonts/Edson_Comics_Bold.ttf", 28),
        [20] = love.graphics.newFont("fonts/Edson_Comics_Bold.ttf", 45),
    }
    love.graphics.setBackgroundColor(17,17,17)
    love.graphics.setFont(fonts[12])

    -- group defaults
    quickie.group.default.size[1] = 150
    quickie.group.default.size[2] = 25
    quickie.group.default.spacing = 5

    -- quickie.mouse.disable()

    inputHandler = LogicCore.inputHandler
    entityManager = LogicCore.entityManager

    ui.windowWidth, ui.windowHeight = love.graphics.getDimensions()
end

function ui.update(dt)
    if quickie.Button { text = "Build", pos = { 10, ui.windowHeight - 40 } } then
        inputHandler:setMode("build")
    end
    if inputHandler.selection and quickie.Button { text = "Path", pos = { 170, ui.windowHeight - 40 } } then
        inputHandler:setMode("path")
    end
end

function ui.draw()
    love.graphics.translate(inputHandler.translate.x, inputHandler.translate.y)

    for id, entity in pairs(entityManager.entities) do
        if entity.health then
            ui.drawHealthBar(entity)
        end
    end

    -- draw selection
    local entity = inputHandler.selection and entityManager.entities[inputHandler.selection]
    if entity then
        love.graphics.draw(cursor, entity.position.x-96, entity.position.y-96)
        if entity.path then
            local startPoint = entity.position
            for _, endPoint in ipairs(entity.path) do
                love.graphics.line(startPoint.x, startPoint.y, endPoint.x, endPoint.y)
                love.graphics.draw(pathFlag, endPoint.x-18, endPoint.y-18)
                startPoint = endPoint
            end
        end
    end

    love.graphics.translate(-inputHandler.translate.x, -inputHandler.translate.y)
    love.graphics.rectangle("fill", 0, ui.windowHeight - 50, ui.windowWidth, 50)
    quickie.core.draw()
end

function ui.drawHealthBar(entity)
    local width = 50
    local height = 5
    local x = entity.position.x - width/2
    local y = entity.position.y - 30
    love.graphics.setColor(0, 16, 0, 255)
    love.graphics.rectangle("fill", x-1, y-1, width+2, height+2 )
    love.graphics.setColor(0, 128, 0, 255)
    love.graphics.rectangle("fill", x, y, width*entity.health/entity.maxHealth, height )
    love.graphics.setColor(255, 255, 255, 255)

end

function ui.resize(w, h)
    ui.windowWidth = w
    ui.windowHeight = h
end

return ui