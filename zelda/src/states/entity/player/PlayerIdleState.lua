--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerIdleState = Class{__includes = EntityIdleState}


function PlayerIdleState:init(player, dungeon)
    -- store map and player details upon initiation for referencing
    self.dungeon = dungeon
    self.entity = player
    self.entity:changeAnimation('idle-' .. self.entity.direction)

    -- used for AI waiting
    self.waitDuration = 0
    self.waitTimer = 0

end

function PlayerIdleState:enter(params)
    -- render offset for spaced character sprite (negated in render function of state)
    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

function PlayerIdleState:update(dt)

    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.entity:changeState('walk')
    end

    if love.keyboard.wasPressed('space') then

        local projectiles = self.dungeon.currentRoom.projectiles
        -- used to prevent enetering swing sword state if we have entered lift pot state
        t = false

        -- search for all pots in the map
        for k, proj in pairs(projectiles) do
            if proj.type == 'projectile'then

                -- check if the player is diretly infront of a pot and facing it
                -- check when player is facing right
                if self.entity.direction == 'right' and ((self.entity.x + self.entity.width) <= proj.x + 3)
                -- Leftmost X bound
                and (self.entity.x >= (proj.x - self.entity.width - 10))
                -- Upper Y bound 
                and (self.entity.y >= (proj.y - self.entity.height))
                -- lower Y bound 
                and self.entity.y <= (proj.y + proj.height - 5) then
                    -- switch to lift pot state
                    self.entity:changeState('lift-pot')
                    proj.status = 'lift'
                    table.insert(self.entity.inventoryHand, proj) 
                    t = true
                    
                -- check when player is facing left
                elseif self.entity.direction == 'left' and (self.entity.x >= (proj.x + proj.width - 3))
                and (self.entity.x <= (proj.x + proj.width + self.entity.width - 1))
                -- upper Y bound
                and ((self.entity.y + self.entity.height) >= proj.y - 3)
                -- lower Y bound
                and self.entity.y <= (proj.y + proj.height - 5)
                 then
                    -- switch to lift pot state
                    self.entity:changeState('lift-pot')
                    proj.status = 'lift'
                    table.insert(self.entity.inventoryHand, proj)
                    t = true 
                
                -- check when player is facing down
                elseif self.entity.direction == 'down' 
                -- upper Y bound
                and ((self.entity.y + self.entity.height) >= proj.y - 5)
                -- lower Y bound
                and self.entity.y <= (proj.y + proj.height - 15)
                -- Leftmost x bound
                and (self.entity.x >= (proj.x - self.entity.width - 5))
                -- rightmost bound
                and (self.entity.x <= (proj.x + proj.width + self.entity.width - 10))
                then
                    -- switch to lift pot state
                    self.entity:changeState('lift-pot')
                    proj.status = 'lift'
                    table.insert(self.entity.inventoryHand, proj)
                    t = true
                    
                -- check when player is facing down
                elseif self.entity.direction == 'up' 
                -- upper Y bound
                and (self.entity.y >= (proj.y + proj.height - 10))
                -- lower Y bound
                and self.entity.y <= (proj.y + proj.height + self.entity.height - 20)
                  -- Leftmost x bound
                  and (self.entity.x >= (proj.x - self.entity.width - 5))
                  -- rightmost bound
                  and (self.entity.x <= (proj.x + proj.width + self.entity.width - 10))              
                then
                    -- switch to lift pot state
                    self.entity:changeState('lift-pot')
                    proj.status = 'lift'
                    table.insert(self.entity.inventoryHand, proj)
                    t = true 
                end
            end
        end

        -- if we are not infront of any pot then swing sword
        if not t then
            self.entity:changeState('swing-sword')
        end
    end
end