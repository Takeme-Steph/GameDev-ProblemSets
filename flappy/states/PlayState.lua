--[[
    PlayState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The PlayState class is the bulk of the game, where the player actually controls the bird and
    avoids pipes. When the player collides with a pipe, we should go to the GameOver state, where
    we then go back to the main menu.
]]

PlayState = Class{__includes = BaseState}

PIPE_SPEED = 60
PIPE_WIDTH = 70
PIPE_HEIGHT = 288
gSPAWN_INTERVAL = 2

BIRD_WIDTH = 38
BIRD_HEIGHT = 24


function PlayState:init()
    self.bird = Bird()
    self.pipePairs = {}
    self.timer = 0
    self.score = 0

    -- clear previous pause status when starting a new game
    gPAUSED = false
    PauseTimer = 0
    gPauseSwitch = false
    PauseCount = 3
    

    -- initialize our last recorded Y value for a gap placement to base other gaps off of
    self.lastY = -PIPE_HEIGHT + math.random(80) + 20
end

function PlayState:update(dt)
    --check if game is paused before running update
    if not gPAUSED  then

        --Timer after unpausing
        if gPauseSwitch then
            PauseTimer = PauseTimer + dt
            if PauseTimer > COUNTDOWN_TIME then
                PauseTimer = PauseTimer % COUNTDOWN_TIME
                PauseCount = PauseCount - 1

                --if unpause timer ends, reset counters and unpause the game and resume music
                if PauseCount == 0 then
                    gPauseSwitch = false
                    PauseCount = 3
                    PauseTimer = 0
                    love.audio.play(sounds['music'])
                end
            end
        end
        --continue the game after counter ends
        if not gPauseSwitch then
            -- update timer for pipe spawning
            self.timer = self.timer + dt

            -- spawn a new pipe pair at the pipe spawn interval
            if self.timer > gSPAWN_INTERVAL then
                -- modify the last Y coordinate we placed so pipe gaps aren't too far apart
                -- no higher than 10 pixels below the top edge of the screen,
                -- and no lower than a gap length (90 pixels) from the bottom

                --update pipe gap height to random numbers
                gGAP_HEIGHT = math.max((20 * math.random(4,8)), 90)

                local y = math.max(-PIPE_HEIGHT + 10, 
                    math.min(self.lastY + math.random(-20, 20), VIRTUAL_HEIGHT - gGAP_HEIGHT - PIPE_HEIGHT))
                self.lastY = y

                -- add a new pipe pair at the end of the screen at our new Y
                table.insert(self.pipePairs, PipePair(y))

                -- reset timer
                self.timer = 0
                --reset a random pipe spanw interval
                gSPAWN_INTERVAL = math.random(2,4)
            end

            -- for every pair of pipes..
            for k, pair in pairs(self.pipePairs) do
                -- score a point if the pipe has gone past the bird to the left all the way
                -- be sure to ignore it if it's already been scored
                if not pair.scored then
                    if pair.x + PIPE_WIDTH < self.bird.x then
                        self.score = self.score + 1
                        pair.scored = true
                        sounds['score']:play()
                    end
                end

                -- update position of pair
                pair:update(dt)
            end

            -- we need this second loop, rather than deleting in the previous loop, because
            -- modifying the table in-place without explicit keys will result in skipping the
            -- next pipe, since all implicit keys (numerical indices) are automatically shifted
            -- down after a table removal
            for k, pair in pairs(self.pipePairs) do
                if pair.remove then
                    table.remove(self.pipePairs, k)
                end
            end

        -- simple collision between bird and all pipes in pairs
            for k, pair in pairs(self.pipePairs) do
                for l, pipe in pairs(pair.pipes) do
                    if self.bird:collides(pipe) then
                        sounds['explosion']:play()
                        sounds['hurt']:play()

                        gStateMachine:change('score', {
                            score = self.score
                        })
                    end
                end
            end

            -- update bird based on gravity and input
            self.bird:update(dt)

            -- reset if we get to the ground
            if self.bird.y > VIRTUAL_HEIGHT - 15 then
                sounds['explosion']:play()
                sounds['hurt']:play()

                gStateMachine:change('score', {
                    score = self.score
                })
            end
        end

    end
end

function PlayState:render()
    for k, pair in pairs(self.pipePairs) do
        pair:render()
    end

    love.graphics.setFont(flappyFont)
    love.graphics.print('Score: ' .. tostring(self.score), 8, 8)

    self.bird:render()

    --display message when paused
    if gPAUSED then
        love.graphics.setFont(hugeFont)
        love.graphics.printf('PAUSED', 0, 64, VIRTUAL_WIDTH, 'center')
    end

    if gPauseSwitch then
        love.graphics.setFont(hugeFont)
        love.graphics.printf(tostring(PauseCount), 0, 120, VIRTUAL_WIDTH, 'center')
    end
end

--[[
    Called when this state is transitioned to from another state.
]]
function PlayState:enter()
    -- if we're coming from death, restart scrolling
    scrolling = true
end

--[[
    Called when this state changes to another state.
]]
function PlayState:exit()
    -- stop scrolling for the death/score screen
    scrolling = false
end