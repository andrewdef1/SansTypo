--[[
SANS TYPO
]]

Timer = require 'lib/knife.timer'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

ALPHABET = "abcdefghijklmnopqrstuvwxyz'-./"

local font = love.graphics.newFont('fonts/UbuntuCondensed-Regular.ttf', 64)

local currentTime = 60
local currentCharIndex = 1
local score = 0

local words = {}
local fullString
local halfString

local start = true
local gameOver = false
local cursor = false

local background

function love.load()
   
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    
    background = love.graphics.newImage('WoodBackground.png')

    love.graphics.setFont(font)

    Timer.every(1, function()
        currentTime = currentTime - 1
        if currentTime == 0 then
            gameOver = true
            currentTime = 60
        end
    end)

    Timer.every(0.5, function()
        cursor = not cursor
    end)

    math.randomseed(os.time())

    initializeDictionary()
    chooseWord()
    
    Timer.game_paused = false
end



function love.keypressed(key, unicode)
  
 if key == 'return' then game_paused = not game_paused end

    if key == 'escape' then
        love.event.quit()
    end

    if start and key == 'space' then
        start = false
    end

    if gameOver and key == 'space' then
        gameOver = false
        score = 0
        chooseWord()
        
    end
        

    if not start and not gameOver then
        for i = 1, #ALPHABET do
            local char = ALPHABET:sub(i, i)
            
                        
            -- if we have pressed this key of the alphabet...
            if key == char then

                -- if we have typed the current correct letter...
                if char == fullString:sub(currentCharIndex, currentCharIndex) then

                    -- successfully typed full word
                    if currentCharIndex == fullString:len() then
                        score = score + fullString:len()
                        chooseWord()
                    else
                        currentCharIndex = currentCharIndex + 1
                    end
                else

                    -- else if we typed the wrong letter...
                    currentCharIndex = 1
                end
            end
        end
    end
end

function love.update(dt)
   
    if not start and not gameOver and not game_paused then
        Timer.update(dt)
    end
    

end

function love.draw()
  
if game_paused then 
  local sx = love.graphics.getWidth() / background:getWidth()
  local sy = love.graphics.getHeight() / background:getHeight()
  love.graphics.draw(background, 0, 0, 0, sx, sy) -- x: 0, y: 0, rot: 0, scale x and scale y
  
  love.graphics.setColor(1, 1, 0, 1)
  if math.floor(love.timer.getTime()) % 2 == 0 then
  love.graphics.print("GAME DI PAUSE" ,WINDOW_WIDTH / 2 - font:getWidth("GAME DI PAUSE") / 2, WINDOW_HEIGHT / 2 - 32)
end
love.graphics.setColor(1, 1, 1, 1)
  return 
  end

  --background overall
  local sx = love.graphics.getWidth() / background:getWidth()
  local sy = love.graphics.getHeight() / background:getHeight()
  love.graphics.draw(background, 0, 0, 0, sx, sy) -- x: 0, y: 0, rot: 0, scale x and scale y
  
    -- draw the current goal word in yellow
    love.graphics.setColor(1, 1, 0, 1)
    love.graphics.print(fullString, WINDOW_WIDTH / 2 - font:getWidth(fullString) / 2, WINDOW_HEIGHT / 2 - 32)
    love.graphics.setColor(1, 1, 1, 1)

    -- draw the progress of the word we're typing in white
    local halfString = currentCharIndex == 1 and '' or fullString:sub(1, currentCharIndex - 1)
    love.graphics.print(halfString, WINDOW_WIDTH / 2 - font:getWidth(fullString) / 2, WINDOW_HEIGHT / 2 + 16)
    
    -- add cursor to the half-string text based on cursor state
    if cursor then
        love.graphics.print('|', WINDOW_WIDTH / 2 - font:getWidth(fullString) / 2 + font:getWidth(halfString), WINDOW_HEIGHT / 2 + 16)
    end

    -- draw the timer in the top-left
    love.graphics.print(tostring(currentTime))

    -- draw the score in the top-right
    love.graphics.printf(tostring(score), 0, 0, WINDOW_WIDTH, 'right')

    love.graphics.printf(tostring(#words) .. ' kata telah dimuat!',
        0, 64, WINDOW_WIDTH, 'center')

    -- draw starting panel
    if start then
        love.graphics.setColor(0.43, 0.28, 0.01, 1)
        love.graphics.rectangle('fill', 128, 128, WINDOW_WIDTH - 256, WINDOW_HEIGHT - 256)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf('Tekan SPACE untuk Mulai', 0, WINDOW_HEIGHT / 2 - 110, WINDOW_WIDTH, 'center')
        love.graphics.printf('Tekan ENTER untuk Pause', 0, WINDOW_HEIGHT / 2 - 55, WINDOW_WIDTH, 'center')
        love.graphics.printf('Tekan esc untuk Keluar', 0, WINDOW_HEIGHT / 2 - 1, WINDOW_WIDTH, 'center')
        
    end

    if gameOver then
        love.graphics.setColor(0.43, 0.28, 0.01, 1)
        love.graphics.rectangle('fill', 128, 128, WINDOW_WIDTH - 256, WINDOW_HEIGHT - 256)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf('END GAME', 0, WINDOW_HEIGHT / 3 - 20, WINDOW_WIDTH, 'center')
        love.graphics.printf('Skor kamu: ' .. tostring(score), 0, WINDOW_HEIGHT / 2 - 70, WINDOW_WIDTH, 'center')
        love.graphics.printf('Tekan SPACE untuk Ngulang', 0, WINDOW_HEIGHT / 2 - 5, WINDOW_WIDTH, 'center')

    end
end

function initializeDictionary()
    for line in love.filesystem.lines('large.txt') do
        table.insert(words, line) 
    end
end

function chooseWord()
    currentCharIndex = 1
    fullString = words[math.random(#words)]
end