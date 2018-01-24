io.stdout:setvbuf("no")
--debug
if arg[#arg] == "-debug" then require("mobdebug").start() end
--pixelisation
love.graphics.setDefaultFilter("nearest")player = {}

-- Returns the distance between two points.
function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end

local game = require("game")

__LKID = love.keyboard.isDown
function love.load()
  love.window.setTitle("Sokoban gameCodeur GameJam#12")
  love.window.setMode(1400, 700, {resizable = true})
  wScreen = love.graphics.getWidth()
  hScreen = love.graphics.getHeight()
  game.Load()
end

function love.update(dt)
  game.Update()
end

function love.draw()
  game.Draw()
  
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
  print(key)
  
end