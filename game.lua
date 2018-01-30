local game = {}

map = {}
map.currentLevel = 0
map[map.currentLevel] = require("maps/level"..tostring(map.currentLevel))
game.level = map[map.currentLevel].layers[1].data

imgTiles = {}
game.tileTextures = {}
game.tileSheet = nil
game.tileType = {}

game.level.TILE_WIDTH = 64
game.level.TILE_HEIGHT = 64

lstSprite = {}
hero = {}
hero.col = 0
hero.line = 0
lstBox = {}
box = {}
box.col = 0
box.line = 0


---------------------------------------
--       **fonction reset level**        --
---------------------------------------
function resetLevel(key)
  if key == "r" then
   map[map.currentLevel] = map[map.currentLevel]
    print("reset")
    return startGame()
    end
end

function newLevel(key)
  if key == "p" then
     map[map.currentLevel] = map[map.currentLevel] + 1
    print("lvl:"..map[map.currentLevel])
  end
end
---------------------------------------
-- **fonction collisions avec les murs** --
---------------------------------------
function game.level.isSolid(pID)
  
  tileType = game.tileType[pID]
  
  if tileType == "wall" then
    return true
  end
  return false
end


--------------------------------------
-- **CREATION DE LA LISTE DES SPRITES** --
--------------------------------------
function createSprite(pNomImage ,pCol, pLine, sX, sY)
  mySprites = {}
  
  mySprites.image = love.graphics.newImage("images/"..pNomImage..".png")
  mySprites.col = pCol
  mySprites.line = pLine
  mySprites.sX = sX
  mySprites.sY = sY
  mySprites.dir = ""
  mySprites.delete = false
  mySprites.colide = false
  
  table.insert(lstSprite, mySprites)
  return mySprites
end

------------------------------
-- **CREATION DES SPRITES BOX** --
------------------------------
function createBox(pImg, pCol, pLine, sX, sY)
  
  lstBox = {}
  local tiles = 25 --nombre de tuiles en longueur
  --print(tiles)
  
  local nbLines =#game.level/(#game.level/game.level.TILE_WIDTH) --taille d'une tuile 64
  --print(nbLines)
  local line, col
  local x,y
  for line = nbLines, 1, -1 do
    for col = 1, tiles do
      local tile= game.level[((line-1)*tiles)+col]
      if tile == 13 then
        local box = createSprite(pImg, col, line, sX, sY)
        
        box.col = col
        box.line = line
        box.move = false
        table.insert(lstBox, box)
        print("c : "..box.col.." l : "..box.line)
      end
    end
  end
  --return lstBox
end

function updateBox()
        ------------------------------
      --        **BOXES MOVE**        --
      ------------------------------  
      --if tileType == "box" then 
      for i = 1, #lstSprite do
        for n= #lstBox, 1, -1 do
          
          if lstSprite[i].col == lstBox[n].col 
          and lstSprite[i].line == lstBox[n].line then
          local newC = 0
          local newL = 0 
          oldL = newL
          oldC = newC
          
         if lstSprite[i].dir == "left" then
          lstBox[n].move = true
          lstBox[n].col = lstBox[n].col - 1
          lstBox[n].line = lstBox[n].line
          newC = lstBox[n].col
          newL = lstBox[n].line
          print("boxTouchedIs:"..n)
          print("newC = "..newC.." newL = "..newL)
        end
        if lstSprite[i].dir == "right" then
          lstBox[n].move = true
          lstBox[n].col = lstBox[n].col + 1 
          lstBox[n].line = lstBox[n].line
          newC = lstBox[n].col
          newL = lstBox[n].line
          print("boxTouchedIs:"..n)
          print("newC = "..newC.." newL = "..newL)

        end
        if lstSprite[i].dir == "up" then
          lstBox[n].move = true
          lstBox[n].line = lstBox[n].line - 1 
          lstBox[n].col = lstBox[n].col
          newC = lstBox[n].col
          newL = lstBox[n].line
          print("boxTouchedIs:"..n)
          print("newC = "..newC.." newL = "..newL)

        end
        if lstSprite[i].dir == "down" then
          lstBox[n].move = true
          lstBox[n].line = lstBox[n].line + 1 
          lstBox[n].col = lstBox[n].col
          newC = lstBox[n].col
          newL = lstBox[n].line
          print("boxTouchedIs:"..n)
          print("newC = "..newC.." newL = "..newL)
        end
        print(tostring(lstBox[n].move))
        
        local l = newL
        local c = newC
        local id = game.level[((l-1)*25) + c]
        if game.level.isSolid(id) then
          
          if lstSprite[i].dir == "left" then
            lstBox[n].col = newC + 1
            lstBox[n].line = newL
            lstSprite[i].col = lstSprite[i].col+1
          end
          if lstSprite[i].dir == "right" then
            lstBox[n].col = newC - 1
            lstBox[n].line = newL
            lstSprite[i].col = lstSprite[i].col-1
          end
          if lstSprite[i].dir == "up" then
            lstBox[n].line = newL + 1
            lstBox[n].col = newC
            lstSprite[i].line = lstSprite[i].line+1
          end 
          if lstSprite[i].dir == "down" then
            lstBox[n].line = newL - 1
            lstBox[n].col = newC
            lstSprite[i].line = lstSprite[i].line-1
          end
        end
        
        end
        --print("box --> "..lstBox[n].col, lstBox[n].line)
      end
    end
  end
  

function updateHero(pHero, pBox)
  --------------------------------------
  -- **gestion mouvements case par case** --
  --------------------------------------
  if love.keyboard.isDown("z","q","s","d") then
    if pHero.keyPressed == false then
      local oldC = pHero.col
      local oldL = pHero.line
      if love.keyboard.isDown("z") then
        pHero.line = pHero.line - 1 
        pHero.dir = "up"
      end
      if love.keyboard.isDown("s") then
        pHero.line = pHero.line + 1 
        pHero.dir = "down"
      end
      if love.keyboard.isDown("q") then
        pHero.col = pHero.col - 1 
        pHero.dir = "left"
      end
      if love.keyboard.isDown("d") then
        pHero.col = pHero.col + 1 
        pHero.dir = "right"
      end
      --print(pHero.dir, pHero.col, pHero.line)
      -----------------------------
      -- **collision avec les murs** --
      -----------------------------
      local l = pHero.line
      local c = pHero.col
      local id = game.level[((l-1)*25) + c]
      if game.level.isSolid(id) then
        pHero.line = oldL
        pHero.col = oldC     
      
    end
      
    updateBox()
      
    pHero.keyPressed = true
  end
    else
      pHero.keyPressed = false
      
    end
    
    
end



function game.Load()
  
  wScreen = love.graphics.getWidth()
  hScreen = love.graphics.getHeight()
  
  
  print("chargement des tuiles...")
  
  game.tileSheet = love.graphics.newImage("images/tileSheet.png")
  local nbCol = game.tileSheet:getWidth()/game.level.TILE_WIDTH
  local nbLine = game.tileSheet:getHeight()/game.level.TILE_HEIGHT
  
  game.tileTextures[0] = nil
  
  local l,c
  local id = 1
  
  for l=1, nbLine do
    for c=1, nbCol do
      game.tileTextures[id] = love.graphics.newQuad(
        (c-1) * game.level.TILE_WIDTH,
        (l-1) * game.level.TILE_HEIGHT,
        game.level.TILE_WIDTH,
        game.level.TILE_HEIGHT,
        game.tileSheet:getWidth(),
        game.tileSheet:getHeight()
      )      
      id = id + 1   
    end
  end
    
  print("fin de chargement des tuiles.")
  
  -----------------------------------------
  --         **TYPE DE TUILES** 
  -----------------------------------------
  game.tileType[1]  ="wall" 
  game.tileType[2]  ="wall"
  game.tileType[8]  ="wall"
  game.tileType[16] ="wall"
  game.tileType[55] ="wall"
  game.tileType[56] ="wall"
  game.tileType[48] ="wall"
  game.tileType[42] ="wall"
  game.tileType[41] ="wall"
  game.tileType[54] ="wall"
  game.tileType[53] ="wall"
  game.tileType[47] ="wall"
  game.tileType[43] ="wall"
  game.tileType[9]  ="wall"
  game.tileType[18] ="wall"
  game.tileType[19] ="wall"
  game.tileType[20] ="wall"
  game.tileType[26] ="wall"
  game.tileType[23] ="wall"
  game.tileType[39] ="wall"
  game.tileType[34] ="wall"
  game.tileType[35] ="wall"
  game.tileType[36] ="wall"
  game.tileType[31] ="wall"
  game.tileType[17] ="wall"
  game.tileType[33] ="wall"
  game.tileType[24] ="wall"
  game.tileType[40] ="wall"
  game.tileType[37] ="wall"
  game.tileType[19] ="wall"
  game.tileType[20] ="wall"
  game.tileType[22] ="wall"
  game.tileType[24] ="wall"
  game.tileType[27] ="wall"
  game.tileType[21] ="wall"
  game.tileType[29] ="wall" 
  game.tileType[30] ="wall" 
  game.tileType[37] ="wall" 
  game.tileType[38] ="wall" 
  game.tileType[31] ="wall" 
  
  game.tileType[13] ="box"
  game.tileType[12] ="button"
  
  game.tileType[4] = "door"
  game.tileType[5] = "door"
  game.tileType[6] = "door"
  game.tileType[25] ="door"
  game.tileType[32] ="door"
  game.tileType[44] ="door"
  game.tileType[45] ="door"
  game.tileType[46] ="door"

  game.tileType[11] ="floor"
  game.tileType[10] ="floor"
  
  -- APPEL DU STARTGAME
  startGame()
end

function startGame()
  -------------------------------
  -- **creation du sprite "hero"** --
  -------------------------------
  
  hero = createSprite("player", pCol, pLine, 2,2)
  hero.col = pCol
  hero.line = pLine
  createBox("box", pBc, pBl, 1, 1)
  box.col = pBc
  box.line = pBl
  
  local tiles = 25 --nombre de tuiles en longueur
  --print(tiles)
  ------------------------------
  -- **position initial du hero** --
  ------------------------------
  local nbLines =#game.level/(#game.level/game.level.TILE_WIDTH) --taille d'une tuile 64
  --print(nbLines)
  local line, col
  local x,y
  for line = nbLines, 1, -1 do
    for col = 1, tiles do
      local tile= game.level[((line-1)*tiles)+col]
      --local texQuad=game.tileTextures[tile]
      -----------------------------------------------------------
      -- **position du hero sur la tuile "door" de chaque niveau** --
      -----------------------------------------------------------
        if tile ==  4 
        or tile ==  5
        or tile ==  6 
        or tile ==  25
        or tile ==  32 
        or tile ==  44
        or tile ==  45
        or tile ==  46 then
          hero.line = line
          hero.col = col
          print("lHero:"..hero.line,"cHero :"..hero.col)
          print(#lstSprite)
        end

    end
  end
end

function game.Update()
  -- **appel de la function update du hero pour les mouvements et les collisions**
  updateHero(hero, box)
end

function drawGame()
  --------------------------------------------
  -- **affichage des textures de la tilesheet** --
  --------------------------------------------
  local tiles = 25 --nombre de tuiles en longueur
  --print(tiles)
  
local nbLines =#game.level/(#game.level/game.level.TILE_WIDTH) --taille d'une tuile 64
  --print(nbLines)
  local line, col
  local x,y
  for line = nbLines, 1, -1 do
    for col = 1, tiles do
      local tile= game.level[((line-1)*tiles)+col]
      local texQuad=game.tileTextures[tile]
      local x= ((col-1)*game.level.TILE_WIDTH)
      local y= ((line-1)*game.level.TILE_HEIGHT)
      if texQuad~=nil then
        love.graphics.draw(game.tileSheet, texQuad, x, y)  
      end
    end
  end
  
  ---------------------------------------
  -- **affichage de la liste des sprites** --
  ---------------------------------------
  local n
  for n = #lstSprite, 1, -1 do
        local s = lstSprite[n]
        local c = ((s.col -1) * game.level.TILE_WIDTH)
        local l = ((s.line -1) * game.level.TILE_HEIGHT)
          love.graphics.draw(s.image, c, l, 0, s.sX, s.sY)
      end
      --love.graphics.print("nb box : "..#lstBox)
end 

function game.Draw()
  -------------------------------------
  -- **appel de la fonction drawGame()** --
  -------------------------------------
  drawGame()
end

function game.KeyPressed(pKey)
  resetLevel(pKey)
  newLevel(pKey)
end




return game 