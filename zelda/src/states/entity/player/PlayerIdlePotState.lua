PlayerIdlePotState = Class{__includes = EntityIdleState}


function PlayerIdlePotState:init(player, dungeon)
    -- store map and player details upon initiation for referencing
    self.dungeon = dungeon
    self.entity = player
    self.entity:changeAnimation('idle-pot-' .. self.entity.direction)

    -- used for AI waiting
    self.waitDuration = 0
    self.waitTimer = 0

end

function PlayerIdlePotState:enter(params)
    -- render offset for spaced character sprite (negated in render function of state)
    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

function PlayerIdlePotState:update(dt)

    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.entity:changeState('walk-pot')
    end

    -- throw pot when spave is pressed
    if love.keyboard.wasPressed('space') then
        self.entity:changeAnimation('throw-pot-' .. self.entity.direction)
    end
    if self.entity.currentAnimation.timesPlayed > 0 then
        self.entity.currentAnimation.timesPlayed = 0
        for i, item in pairs(self.entity.inventoryHand) do
            item:fire(self.entity)
        end
        self.entity:changeState('idle')
    end
end