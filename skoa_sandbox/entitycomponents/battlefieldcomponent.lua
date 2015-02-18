local Entity = require "smee.game_core.entity"
local EntityComponent = require "smee.game_core.entitycomponent"
local UnitComponent = require "skoa_sandbox.entitycomponents.unitcomponent"
local EntityDefinitions = require "skoa_sandbox.statics.entitydefinitions"
local Table = require "skoa_sandbox.utl.table"

local BattlefieldComponent = EntityComponent:subclass("BattlefieldComponent")

local PI = 3.14159265359
local myTest = 0
function BattlefieldComponent:initialize(owner)
    EntityComponent.initialize(self, owner)
    self.units = {}
    self.turnOrder = {}
    self.currentActor = 0

    local resourceImages = SMEE.GetGame().resources.images

    resourceImages["arrowImage"] = resourceImages["arrowImage"] or love.graphics.newImage("/skoa_sandbox/resources/tutorial_arrow.png")
    self.arrowImage = resourceImages["arrowImage"]
    self.arrowHalfWidth = self.arrowImage:getWidth() / 2 
    self.arrowHalfHeight = self.arrowImage:getHeight() / 2
end

function BattlefieldComponent:init(owner, battlefieldStatics, playerId)
	-- print("BattlefieldComponent:init(" .. tostring(battlefieldStatics) .. ", " .. tostring(playerId) .. ")")

    local entityManager = SMEE.GetGame().entityManager
    self.entityManager = entityManager
    
	-- Instantiate units.
	for i, unitDescription in ipairs(battlefieldStatics.units) do
		local newUnit = Entity.static.createFromEStat(EntityDefinitions[unitDescription.unitId], 1)
		newUnit:initPosition(unitDescription.pos[1], unitDescription.pos[2])
        entityManager:add(newUnit)
		self.units[newUnit.id] = newUnit
        -- Put units into turn order
        local found = false
        for i,candidateId in ipairs(self.turnOrder) do
            local candidate = self.units[candidateId]
            local candidateUnitComponent = candidate:getComponent("UnitComponent")
            local newUnitUnitComponent = newUnit:getComponent("UnitComponent")
            if candidateUnitComponent.initiative < newUnitUnitComponent.initiative then
                table.insert(self.turnOrder, i, newUnit.id)
                found = true
                break
            end
        end
        if not found then
            table.insert(self.turnOrder, newUnit.id)
        end
		-- dbgprint("Added new unit at: " .. Table.dump(unitDescription.pos))
	end
    self:nextUnitRound()
end

function BattlefieldComponent:update(dt)
    -- myTest = myTest + dt
    -- if myTest > 4 then
    --     self:nextUnitRound()
    --     myTest = myTest - 4
    -- end
end

function BattlefieldComponent:nextUnitRound()
    self.currentActor = (self.currentActor % #self.turnOrder) + 1
    dbgprint(self.currentActor)
    dbgprint(self.turnOrder[self.currentActor])
    -- TODO: Apply roundbased effects here
end

function BattlefieldComponent:draw(dt)
    local currentUnit = self.units[self.turnOrder[self.currentActor]]
    love.graphics.push()
    -- Do weird stuff till the arrow fits
    love.graphics.translate(currentUnit.position.x, currentUnit.position.y)
    love.graphics.rotate(PI)
    love.graphics.scale(0.7)
    love.graphics.translate(-self.arrowHalfWidth, 32)
    love.graphics.draw(self.arrowImage, 0, 0, 0)
    love.graphics.pop()
end

function BattlefieldComponent:removeEntity(entity)
    for idx, existingEntity in ipairs(self.turnOrder) do
    	if existingEntity.id == entity.id then
    		table.remove(self.turnOrder, idx)
    		self.entityManager:remove(entity.id)
            self.units[existingEntity.id] = nil
    	end
    end
end

return BattlefieldComponent