

LevelUpState = Class{__includes = BaseState}

function LevelUpState:init(OldStats, NewStats, StatChange, callback)
    self.panel = Panel(6, 6, VIRTUAL_WIDTH - 12, VIRTUAL_HEIGHT - 30)
    self.callback = callback or function() end
    self.OldStats = OldStats
    self.NewStats = NewStats
    self.StatChange = StatChange
end

function LevelUpState:update(dt)
    if love.keyboard.wasPressed('space') or love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateStack:pop()
    end
end

function LevelUpState:render()
    self.panel:render()
    
    love.graphics.setFont(gFonts['medium'])
    love.graphics.print("Old Stats", 13, 9 )
    love.graphics.print("New Stats", VIRTUAL_WIDTH/2, 9 )

    love.graphics.setFont(gFonts['small'])
    local k = 1
    for stat, value in pairs(self.OldStats) do
        love.graphics.print(stat, 13, 40 + (k - 1) * 16)
        love.graphics.print(value, 80, 40 + (k - 1) * 16)
        k = k + 1
    end

    k = 1
    for stat, value in pairs(self.NewStats) do
        love.graphics.print(stat, VIRTUAL_WIDTH/2 , 40 + (k - 1) * 16)
        love.graphics.print(value, (VIRTUAL_WIDTH/2) + 70 , 40 + (k - 1) * 16)
        k = k + 1
    end

    k = 1
    love.graphics.setColor(0, 1, 0)
    for stat, value in pairs(self.StatChange) do
        love.graphics.print("  +  "..value, 90, 40 + (k - 1) * 16)
        k = k + 1
    end
    love.graphics.setColor(1, 1, 1)
end