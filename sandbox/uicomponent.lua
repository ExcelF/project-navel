local GameComponent         = require "smee.game_core.gamecomponent"
local loveframes            = require("libs.loveframes")
local Table                 = require("sandbox.utl.table")
local GameMath              = require "smee.logic.gamemath"
local CombatLogic           = require "sandbox.combatlogic"
local CollisionComponent    = require "sandbox.entitycomponents.collisioncomponent"
local EntityDefinitions     = require "sandbox.statics.entitydefinitions"
local Abilities             = require "sandbox.statics.abilitiydefinitions"

local UiComponent = {}
UiComponent = GameComponent:subclass("UiComponent")

local instance

local fonts = {}
for i=1, 40 do
    fonts[i] = love.graphics.newFont(i)
end
UiComponent.fonts = fonts

local States = {
    Select = 1,
    Attack = 2,
    Move = 3,
    UseAbility = 4,
}

local battlefieldQuery = function(entity)
    if entity:getComponent("BattlefieldComponent") then
        return true
    end
    return false
end

local function getBattlefield()
    -- GET BATTLEFIELD
    local entityManager = SMEE.GetGame().entityManager
    local result = entityManager:findAllEntities(battlefieldQuery)
    -- ONLY EXACTLY 1 BATTLEFIELD ALLOWED
    assert(#result < 2 , "More than 1 battlefield found")
    assert(#result > 0 , "No battlefield found")
    return result[1]
end

local function attackClick()
    if instance.currentState == States.Attack then
        instance.currentState = States.Select
    else
        instance.currentState = States.Attack
        instance.actorUnitComponent = instance.selectedUnit:getComponent("UnitComponent")
    end
end

local function moveClick()
    if instance.currentState == States.Move then
        dbgprint("State was MOVE, so i set it to SELECT")
        instance.currentState = States.Select
    else
        dbgprint("Set State to MOVE")
        instance.currentState = States.Move
        instance.actorUnitComponent = instance.selectedUnit:getComponent("UnitComponent")
    end
end

local function abilityClick(abilityName)
    if instance.currentState == States.UseAbility then
        instance.currentState = States.Select
    else
        instance.currentState = States.UseAbility
        instance.actorUnitComponent = instance.selectedUnit:getComponent("UnitComponent")
        instance.abilityName = abilityName
    end
end

local function endTurnClick()
    -- GET BATTLEFIELD
    local battlefield = getBattlefield()
    -- END TURN
    battlefield:getComponent("BattlefieldComponent"):nextUnitRound()
    local newActor = battlefield:getComponent("BattlefieldComponent"):getCurrentActorEntity()
    instance:unitSelected(newActor)
    -- SHOW WHOSE TURN IT IS
    instance.overheadText = newActor:getComponent("UnitComponent").name .. "'s Turn"
    instance.overheadTextScale = 1
    SMEE.Flux.to(instance, 1, {overheadTextScale = 2}):ease("linear"):oncomplete(function()
                                                                    instance.overheadText = nil
                                                                    instance.overheadTextScale = 1
                                                                    end)
end

local function onActionButton(object, x, y)
    -- GENERAL COMMANDS
    if object.text == "End Turn" then
        endTurnClick()
    end

    -- UNIT BASED COMMANDS:
    if not instance.selectedUnit then
        return
    end
    -- GET BATTLEFIELD
    local battlefield = getBattlefield()
    -- CHECK THAT WE HAVE CURRENT ACTOR SELECTED
    local currentActor = battlefield:getComponent("BattlefieldComponent"):getCurrentActorEntity()
    if not (currentActor == instance.selectedUnit) then
        return
    end
    if object.action == "Attack" then
        attackClick()
    elseif object.action == "Move" then
        moveClick()
    elseif object.action == "Ability" then
        abilityClick(object.abilityName)
    end
end

local buttons = {
    { text = "Attack",   action = "Attack",   onClickFunction = onActionButton,   iconPath = "/sandbox/resources/ui_pictures/icon_attack.png" },
    { text = "Move",     action = "Move",     onClickFunction = onActionButton,   iconPath = "/sandbox/resources/ui_pictures/icon_move.png" },
    { text = "Ability",  action = "Ability",  onClickFunction = onActionButton,   iconPath = "/sandbox/resources/ui_pictures/icon_useability.png" },
    { text = "Ability",  action = "Ability",  onClickFunction = onActionButton,   iconPath = "/sandbox/resources/ui_pictures/icon_useability.png" },
    { text = "Ability",  action = "Ability",  onClickFunction = onActionButton,   iconPath = "/sandbox/resources/ui_pictures/icon_useability.png" },
    { text = "End Turn", action = "EndTurn",  onClickFunction = onActionButton,   iconPath = "/sandbox/resources/ui_pictures/icon_endturn.png" },
}

local textUiConfigs = {
    { title = "Health" },
    { title = "Damage" },
    { title = "Defense" },
    { title = "Speed" },
    { title = "AP" },
}

function UiComponent:initialize()
    assert(not instance, "UiComponent is a Singleton!!")
    instance = self

    local game = SMEE.GetGame()
    self.game = game
    assert(game.entityManager, "The Game has no entityManager GameComponent, which is required for this input handler")
    self.entityManager = game.entityManager

    self.currentState = States.Select

    self.overheadText = nil
    self.overheadTextScale = 1

    -- Create frame which holds UI elements.
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local unitDetails = loveframes.Create("frame")
    self.unitDetails = unitDetails
    self.unitDataContainer = unitDetails
    unitDetails:SetName("Click on a unit to see its details"):SetSize(screenWidth, 150):SetDraggable(false):ShowCloseButton(false)
    unitDetails:SetPos(0, screenHeight - unitDetails:GetHeight())
    
    -- Create form to add UI elements from left to right.
    local form = loveframes.Create("form", unitDetails)
    form:SetPos(5, 25)
    form:SetSize(unitDetails:GetWidth(), 100):SetName("Overview")
    form:SetLayoutType("horizontal")
    
    -- Create grid with unit stats.
    self.unitStatsGrid = loveframes.Create("list")
    for idx, textUiConfig in ipairs(textUiConfigs) do
        local titleText = loveframes.Create("text")
        titleText:SetText(textUiConfig.title)
        self.unitStatsGrid:AddItem(titleText, idx, 1)
    end
    self.unitStatsGrid:SetHeight(100)
    form:AddItem(self.unitStatsGrid)
    
    -- Create command buttons. Ability buttons are stored in a seperate table to access them later.
    self.abilityButtons = {}
    local resources = SMEE.GetGame():getResources()
    for buttonName, buttonDef in pairs(buttons) do
        local button = loveframes.Create("imagebutton")
        button:SetSize(100, 100):SetText(buttonDef.text):SetEnabled(true):SetImage(buttonDef.iconPath)
        button.OnClick = buttonDef.onClickFunction
        button.action = buttonDef.action
        form:AddItem(button)
        if button.action == "Ability" then
            table.insert(self.abilityButtons, button)
        end
    end
end

function UiComponent:unitSelected(unitEntity)
    -- Unselect former selected unit.
    if self.selectedUnit then
        local simpleIconComponent = self.selectedUnit:getComponent("SimpleIconComponent")
        if simpleIconComponent then
            simpleIconComponent.selected = false
        end
    end
    self.selectedUnit = unitEntity
    
    local unitComponent = unitEntity:getComponent("UnitComponent")
    
    -- Set abilities.
    local idx = 1
    dbgprint("EntityDefinitions: " .. Table.dump(EntityDefinitions))
    dbgprint("type: " .. unitComponent.type)
    for idx, abilityName in ipairs(EntityDefinitions[unitComponent.type].UnitComponent.abilities) do
    	local button = self.abilityButtons[idx]
    	button:SetText(abilityName):SetImage(Abilities.Definitions[abilityName].icon)
    	button.abilityName = abilityName
    	idx = idx + 1
    end
    
    self.unitDataContainer:SetName(unitComponent.name)
    
    local statsTextFields = self.unitStatsGrid:GetChildren()
    local textFieldHealth = statsTextFields[1]
    textFieldHealth:SetText("Health: " .. unitComponent.current.health .. "/" .. unitComponent.max.health)

    local textFieldDamage = statsTextFields[2]
    textFieldDamage:SetText("Damage: " .. unitComponent.current.damage)

    local textFieldDefense = statsTextFields[3]
    textFieldDefense:SetText("Defense: " .. unitComponent.current.defense)
    
    local textFieldSpeed = statsTextFields[4]
    textFieldSpeed:SetText("Speed: " .. unitComponent.current.walkRate)

    local textFieldActionPts = statsTextFields[5]
    textFieldActionPts:SetText("AP: " .. unitComponent.base.actionPts .. "/" .. unitComponent.current.maxActionPts)
    
    local simpleIconComponent = unitEntity:getComponent("SimpleIconComponent")
    if simpleIconComponent then
        simpleIconComponent.selected = true
    end

    self.selectedUnit = unitEntity
end

function UiComponent:update(dt)    
    loveframes.update(dt)
    if self.selectedUnit then
        -- TODO: very inefficient... all those string concatenations every update...
        local unitComponent = self.selectedUnit:getComponent("UnitComponent")
        local statsTextFields = self.unitStatsGrid:GetChildren()
        local textFieldHealth = statsTextFields[1]
        textFieldHealth:SetText("Health: " .. unitComponent.current.health .. "/" .. unitComponent.max.health)

        local textFieldDamage = statsTextFields[2]
        textFieldDamage:SetText("Damage: " .. unitComponent.current.damage)

        local textFieldDefense = statsTextFields[3]
        textFieldDefense:SetText("Defense: " .. unitComponent.current.defense)
        
        local textFieldSpeed = statsTextFields[4]
        textFieldSpeed:SetText("Speed: " .. unitComponent.current.walkRate)

        local textFieldActionPts = statsTextFields[5]
        textFieldActionPts:SetText("AP: " .. unitComponent.base.actionPts .. "/" .. unitComponent.current.maxActionPts)
        if self.currentState == States.Move then
            local mousePos = GameMath.Vector2:new(love.mouse.getPosition())
            local distance = GameMath.Vector2.distance(self.selectedUnit.position, mousePos)
            self.moveCostAP = self.selectedUnit:getComponent("MovementComponent"):getDistanceInAP(distance)
            self.moveCostAP = math.min(self.moveCostAP, unitComponent.base.actionPts)
        end
    end

end

function UiComponent:draw()
    loveframes.draw()

    if self.currentState == States.Move then
        love.graphics.setColor(0, 0, 0, 64)
        local pos = self.selectedUnit.position
        love.graphics.circle("fill", pos.x, pos.y, self.actorUnitComponent:getMaxMoveDistance())
        love.graphics.setColor(0xff, 0xff, 0xff, 0xff)
        if self.moveCostAP and self.selectedUnit then
            local mousePosX, mousePosY = love.mouse.getPosition()
            love.graphics.print("AP "..self.moveCostAP, mousePosX+10, mousePosY+10)
        end
    elseif self.currentState == States.Attack then
        local pos = self.selectedUnit.position
        love.graphics.setColor(128, 0, 0, 64)
        local pos = self.selectedUnit.position
        love.graphics.circle("fill", pos.x, pos.y, self.actorUnitComponent.current.attackRange)
        love.graphics.setColor(0xff, 0xff, 0xff, 0xff)
    elseif self.currentState == States.UseAbility then
        love.graphics.setColor(20, 20, 220, 64)
        local pos = self.selectedUnit.position
        love.graphics.circle("fill", pos.x, pos.y, Abilities.Definitions[self.abilityName].range)
        love.graphics.setColor(0xff, 0xff, 0xff, 0xff)
    end

    -- SHOW NICE OVERHEAD TEXT
    if self.overheadText then
        local oldFont = love.graphics.getFont()
        love.graphics.setFont(fonts[28])
        love.graphics.setColor(220, 170, 0)
        -- TODO: very inefficient, instead of scaling into all directions were constantly repositioning
        local windowWidth, windowHeight = love.graphics.getDimensions()
        local xPos = windowWidth/2 - fonts[28]:getWidth(self.overheadText)/2 * self.overheadTextScale
        local yPos = windowHeight/4 - fonts[28]:getHeight(self.overheadText)/2 * self.overheadTextScale
        love.graphics.print(self.overheadText, xPos, yPos, 0, self.overheadTextScale, self.overheadTextScale)
        love.graphics.setFont(oldFont)
        love.graphics.setColor(255,255,255,255)
    end
    
end

function UiComponent:keypressed(key, unicode)
    loveframes.keypressed(key, unicode)
end

function UiComponent:mousepressed(x, y, button)
    loveframes.mousepressed(x, y, button)
end

function UiComponent:mousereleased(x, y, button)
    loveframes.mousereleased(x, y, button)

    if y < self.unitDetails.y then
        local battlefieldComponent = getBattlefield():getComponent("BattlefieldComponent")
        local clickPos = GameMath.Vector2:new(x,y)
        local clickedEntities = self.entityManager:findAllEntities(CollisionComponent.static.checkClicked, clickPos)
        assert(#clickedEntities <= 1, "Cannot click on more than one entity")
        if #clickedEntities > 0 then
            -- If we clicked on an entity, perform stuff
            local entity = clickedEntities[1]

            if self.currentState == States.Move then
                battlefieldComponent:performAction(CombatLogic.performMove, self.selectedUnit, entity.position)
            elseif self.currentState == States.Select then
                self:unitSelected(entity)
            elseif self.currentState == States.Attack then
                battlefieldComponent:performAction(CombatLogic.performAttack, self.selectedUnit, entity)
            elseif self.currentState == States.UseAbility then
                battlefieldComponent:performAction(CombatLogic.applyAbilityOnEntity, self.selectedUnit, self.abilityName, entity)
            end
            self.currentState = States.Select
        elseif self.currentState == States.Move then
            -- If no entity was clicked, but we're in move mode, go there.
            battlefieldComponent:performAction(CombatLogic.performMove, self.selectedUnit, clickPos)
            self.currentState = States.Select
        elseif self.currentState == States.UseAbility then
            battlefieldComponent:performAction(CombatLogic.applyAbilityOnPosition, self.selectedUnit, self.abilityName, clickPos)
            self.currentState = States.Select
        end
    end

end

function UiComponent:textinput(text)
    loveframes.textinput(text)
end

return UiComponent
