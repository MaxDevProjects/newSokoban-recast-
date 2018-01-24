local game = {}
game.currentLevel = 1
map = require("maps/level"..tonumber(game.currentLevel))

game.level = map.layers[1].data

imgTiles = {}
game.tileTextures = {}
game.tileSheet = nil
game.tileType = {}

game.level.TILE_WIDTH = 64
game.level.TILE_HEIGHT = 64

lstSprite = {}
lstBox = {}
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
  
  table.insert(lstSprite, mySprites)
  return mySprites
end

------------------------------
-- **CREATION DES SPRITES BOX** --
------------------------------
function createBox(pImg, pCol, pLine, sX, sY)
  
  local box = createSprite(pImg, pCol, pLine, sX, sY)
  box.col = pCol
  box.line = pLine
  table.insert(lstBox, box)
end

function updateHero(pHero, pBox, pCol, pLine)
  --------------------------------------
  -- **gestion mouvements case par case** --
  --------------------------------------
  if love.keyboard.isDown("z","q","s","d") then
    if pHero.keyPressed == false then
      local oldC = pHero.col
      local oldL = pHero.line
      hero.dir = ""
      if love.keyboard.isDown("z") then
        pHero.line = pHero.line - 1 
        hero.dir = "up"
      end
      if love.keyboard.isDown("s") then
        pHero.line = pHero.line + 1 
        hero.dir = "down"
      end
      if love.keyboard.isDown("q") then
        pHero.col = pHero.col - 1 
        hero.dir = "left"
      end
      if love.keyboard.isDown("d") then
        pHero.col = pHero.col + 1 
        hero.dir = "right"
      end
      print(hero.dir)
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
      
      if id == 13 and pHero.dir == "left" then
        pBox.col = pBox.col - 1 
    end
      
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
  box = createSprite("box", pBc, pBl, 1, 1)
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
        end
        
        if tile == 13 then
          box.col = col
          box.line = line
          table.insert(lstBox, tile)
          print("lstBox: "..#lstBox)
          print("l:"..box.line,"c :"..box.col)
        end
      end
    end
end

function game.Update()
  -- **appel de la function update du hero pour les mouvements et les collisions**
  updateHero(hero, box, hero.col, hero.line)
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
  for n = 1, #lstSprite do
        local s = lstSprite[n]
        local c = ((s.col -1) * game.level.TILE_WIDTH)
        local l = ((s.line -1) * game.level.TILE_HEIGHT)
          love.graphics.draw(s.image, (s.col-1) * 64, (s.line - 1) * 64,0 ,s.sX, s.sY)
      end
end 

function game.Draw()
  -------------------------------------
  -- **appel de la fonction drawGame()** --
  -------------------------------------
  drawGame()
end



return game 