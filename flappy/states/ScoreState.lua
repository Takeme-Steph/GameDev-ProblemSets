--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

ScoreState = Class{__includes = BaseState}

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:enter(params)
    self.score = params.score
end

local LowScore = love.graphics.newImage('ribbon0.png')
local MedScore = love.graphics.newImage('ribbon1.png')
local HighScore = love.graphics.newImage('ribbonhigh.png')


function ScoreState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    -- simply render the score to the middle of the screen
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Oof! You lost!', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')
    
    --display ribbon graphics based on score
    if self.score >= 6 then
        love.graphics.draw(HighScore, VIRTUAL_WIDTH/2 + 30, VIRTUAL_HEIGHT/2 - 50)
    elseif self.score >= 3 then
        love.graphics.draw(MedScore, VIRTUAL_WIDTH/2 + 30, VIRTUAL_HEIGHT/2 - 50)
    elseif self.score >= 1 then
        love.graphics.draw(LowScore, VIRTUAL_WIDTH/2 + 30, VIRTUAL_HEIGHT/2 - 55 )
    end

    love.graphics.printf('Press Enter to Play Again!', 0, 160, VIRTUAL_WIDTH, 'center')
end