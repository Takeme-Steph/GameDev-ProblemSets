--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Projectile = Class{}

function Projectile:init(def, x, y)

    self.status = 'idle'
    self.direction = 'down'
    self.speed = 60
    self.delete = false
    
    -- string identifying this object type
    self.type = def.type

    self.texture = def.texture
    self.frame = def.frame or 14

    -- whether it acts as an obstacle or not
    self.solid = def.solid

    self.defaultState = def.defaultState
    self.state = self.defaultState
    self.states = def.states

    -- dimensions
    self.x = x
    self.y = y
    self.width = def.width
    self.height = def.height

    -- track how far the projectile has travelled
    self.travel = 0

    -- flags for flashing the projectile when hit
    self.broken = false
    self.brokenDuration = 1
    self.brokenTimer = 0

    -- timer for turning transparency on and off, flashing
    self.flashTimer = 0

    -- default empty collision callback
    self.onCollide = function() end
end

function Projectile:update(dt, player, entities)
    -- check if pot is broken flash and delete it
    if self.broken then
        self.flashTimer = self.flashTimer + dt
        self.brokenTimer = self.brokenTimer + dt

        if self.brokenTimer > self.brokenDuration then
            self.broken = false
            self.brokenTimer = 0
            self.flashTimer = 0
            self.delete = true
        end
    end 

    -- lift the projectile to the top of the players head
    if self.status == 'lift' then
        self.x = player.x
        self.y = player.y - self.height + 2

    -- throw projectile in direction of the player
    elseif self.status == 'throw' then
        if self.direction == 'left' then
            self.x = self.x - (dt * self.speed)
            self.travel = self.travel + (dt * self.speed)
        elseif self.direction == 'right' then
            self.x = self.x + (dt * self.speed)
            self.travel = self.travel + (dt * self.speed)
        elseif self.direction == 'up' then
            self.y = self.y - (dt * self.speed)
            self.travel = self.travel + (dt * self.speed)
        elseif self.direction == 'down' then
            self.y = self.y + (dt * self.speed)
            self.travel = self.travel + (dt * self.speed)
        end
        -- check for collision with enemy 
        for i, entity in pairs(entities) do
            if not entity.dead and entity:collides(self) then
                entity:damage(1)
                gSounds['hit-enemy']:play()
                self.state = 'broken'
                self.status = 'broken'
                self.broken = true
                self.travel = 0
            end
        end
        -- check for collision against wall
        if self:hitWall() then
            self.state = 'broken'
            self.status = 'broken'
            self.broken = true
            self.travel = 0   
        end
        -- check if the pot has traveled 4 blocks
        if self.travel >= (16*4) then
            self.travel = 0
            self.status = 'broken'
            self.state = 'broken' 
            self.broken = true   
        end
    end
end

function Projectile:fire(player)
    self.status = 'throw'
    self.direction = player.direction

    if self.direction == 'right' then
        self.x = self.x + player.width + 5
        self.y = player.y
    elseif self.direction == 'left' then
        self.y = player.y
        self.x = self.x - player.width - 2
    elseif self.direction == 'down' then
        self.y = self.y + player.height + 12 
    end
end

function Projectile:hitWall()
    
    -- assume we didn't hit a wall
    local bumped = false
    -- boundary checking on all sides, allowing us to avoid collision detection on tiles
    if self.direction == 'left' then
        if self.x <= MAP_RENDER_OFFSET_X + TILE_SIZE then 
            self.x = MAP_RENDER_OFFSET_X + TILE_SIZE
            bumped = true
        end
    elseif self.direction == 'right' then
        if self.x + self.width >= VIRTUAL_WIDTH - TILE_SIZE * 2 then
            self.x = VIRTUAL_WIDTH - TILE_SIZE * 2 - self.width
            bumped = true
        end
    elseif self.direction == 'up' then
        if self.y <= MAP_RENDER_OFFSET_Y + TILE_SIZE - self.height / 2 then 
            self.y = MAP_RENDER_OFFSET_Y + TILE_SIZE - self.height / 2
            bumped = true
        end
    elseif self.direction == 'down' then
        local bottomEdge = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) 
            + MAP_RENDER_OFFSET_Y - TILE_SIZE

        if self.y + self.height >= bottomEdge then
            self.y = bottomEdge - self.height
            bumped = true
        end
    end

    return bumped
end

function Projectile:render(adjacentOffsetX, adjacentOffsetY)
    -- draw sprite slightly transparent if invulnerable every 0.04 seconds
    if self.broken and self.flashTimer > 0.06 then
        self.flashTimer = 0
        love.graphics.setColor(1, 1, 1, 64/255)
    end

    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.states[self.state].frame or self.frame],
        self.x + adjacentOffsetX, self.y + adjacentOffsetY)
end