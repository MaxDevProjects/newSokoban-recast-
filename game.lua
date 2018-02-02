local game = {}

map = {}

map = require("maps/level2")
game.level = map.layers[1].data

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
button = {}
button.col = 0
button.line = 0

currentLvl = 1

game.level.fogGrid = {}
---------------------------------------
--       **fonction reset level**        --
---------------------------------------
function resetLevel(key)
  if key == "r" then
      for b = #lstBox, 1, -1 do
        for s = #lstSprite, 1, -1 do
          table.remove(lstSprite, s)
          table.remove(lstBox, b)
        end
      end
   currentLvl = currentLvl
    print("reset", "lvl:"..currentLvl)
    startGame()
    end
end

function newLevel(key)

  if key == "p" then
    game.level = map.layers[currentLvl].data
     currentLvl = currentLvl + 1
    if currentLvl > #map.layers then
      currentLvl = 1
      print("TODO: Victory screen, all level completed".."\n".."layer"..#map.layers)
    else
      print("layer : "..#map.layers)
    end
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
  mySprites.move = false
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

function createButton()
  lstButton = {}
  local tiles = 25 --nombre de tuiles en longueur
  --print(tiles)
  
  local nbLines =#game.level/(#game.level/game.level.TILE_WIDTH) --taille d'une tuile 64
  --print(nbLines)
  local line, col
  local x,y
  for line = nbLines, 1, -1 do
    for col = 1, tiles do
      local tile= game.level[((line-1)*tiles)+col]
      if tile == 12 then
        button = {}
        button.col = col
        button.line = line
        --resolved = false
        table.insert(lstButton, button)
        print("nbBut : "..#lstButton.." ButtonC : "..button.col.." ButtonL : "..button.line)
      end
    end
  end
end

function isCollideBox(pBox, pDir)
  --collision de caisse à caisse CHECK! 
  
  for _, box in ipairs(lstBox) do
    if box ~= pBox then -- pour ne pas tester la boite avec elle même
      if pDir == "up" then
        if box.line == pBox.line-1 and box.col == pBox.col then
          return true
        end
      elseif pDir == "down" then
        if box.line == pBox.line+1 and box.col == pBox.col then
          return true
        end
      elseif pDir == "left" then
        if box.line == pBox.line and box.col == pBox.col-1 then
          return true
        end
      elseif pDir == "right" then
          if box.line == pBox.line and box.col == pBox.col+1 then
            return true
        end
      end
    end
  end
  return false
end

function updateBox(pCol, pLine, pDir)
      ------------------------------
      --        **BOXES MOVE**        --
      ------------------------------  
      -- revoir le "down", pas de collision avec les mur vers la bas !!!!
      
  for n= #lstBox, 1, -1 do
    local box = lstBox[n]
    --print("box :",box, box.col, box.line, pCol, pLine)
    if box.line == pLine and box.col == pCol then -- collision
      --print("collide box",box, "at",box.col, box.line)
      if pDir == "left" then
        local id = game.level[((pLine-1)*25) + pCol-1]
        --on déplace la box que si elle ne touche pas un mur ni une autre box
        if not game.level.isSolid(id) and not isCollideBox(box, pDir) then
          box.col = box.col - 1
          return true -- ok, la boite à bien bougé
        else
          return false -- oups, la boite reste bloquée, le joueur n'avance plus du coup
        end
        
      elseif pDir == "right" then
        local id = game.level[((pLine-1)*25) + pCol+1]
        print(id)
        if not game.level.isSolid(id) and not isCollideBox(box, pDir) then
          box.col = box.col + 1
          return true
        else
          return false
        end
        
      elseif pDir == "up" then
        local id = game.level[((pLine-2)*25) + pCol]
        print(id)
        if not game.level.isSolid(id) and not isCollideBox(box, pDir) then
          box.line = box.line - 1
          return true
        else
          return false
        end
        
      elseif pDir == "down" then
        local id = game.level[((pLine-2)*25) + pCol]
        print(id)
        if not game.level.isSolid(id) and not isCollideBox(box, pDir) then
          box.line = box.line + 1
          return true
        else
          return false
        end
        
      end
      
    end
  end
end
  

function updateHero(pHero, pBox)
  --------------------------------------
  -- **gestion mouvements case par case** --
  --------------------------------------
  local collideBox = false -- teste la collision contre une box

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
      else
        game.level.clearFogBis(hero.line, hero.col)
      end
    local boxMove = true --test si la boite poussée se déplace ou non cas d'une collision contre un
    -- mur ou une autre boite)
    boxMove = updateBox(pHero.col, pHero.line, pHero.dir)
    -- Bon, finalement, le joueur retourne à sa position initiale, une collision l'empeche
    -- d'avancer
    if boxMove == false then
      pHero.line = oldL
      pHero.col = oldC
    end
    
    pHero.keyPressed = true
  end
    else
      pHero.keyPressed = false
    end
    
    
end

function isResolved()
  local totalBut = 0
  for b = #lstBox, 1, -1 do
    for c = #lstButton, 1, -1 do
      if lstBox[b].col == lstButton[c].col and  lstBox[b].line == lstButton[c].line then
        totalBut = totalBut + 1
      end
    end
  end  
  if totalBut == #lstButton then
    resolved = true
    print("is resolved")
  else
    resolved = false
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
  
  game.level.fogGrid = {}
  
  for l=1, game.level.TILE_WIDTH do
    game.level.fogGrid[l] = {}
    for c=1, game.level.TILE_HEIGHT do
      game.level.fogGrid[l][c] = 1
    end
  end
    game.level.clearFogBis(hero.line, hero.col)

    
   
end

function startGame()
  -------------------------------
  -- **creation du sprite "hero"** --
  -------------------------------
  currentLvl = currentLvl
  hero = createSprite("player", pCol, pLine, 2,2)
  hero.col = pCol
  hero.line = pLine
  createBox("box", pBc, pBl, 1, 1)
  createButton()

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
  updateHero(hero, button)
  isResolved()
end


function game.level.clearFogBis(pLine, pColumn)
  local c, l
  for l=1, game.level.TILE_WIDTH do
    for c=1, game.level.TILE_HEIGHT do
      if c>0 and c <= game.level.TILE_WIDTH and l>0 and l <=game.level.TILE_HEIGHT then
        local dist = math.dist(c, l, pColumn, pLine)
        if dist <4 then
          local alpha = dist /4
          if game.level.fogGrid[l][c] > alpha then
            game.level.fogGrid[l][c] = alpha*2
          end
        else 
          game.level.fogGrid[l][c] = dist
        end
      end
    end
  end  
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
         if game.level.fogGrid[line][col] > 0 then
          love.graphics.setColor(0,0,0,25 * game.level.fogGrid[line][col])
          love.graphics.rectangle("fill", x, y, game.level.TILE_WIDTH, game.level.TILE_HEIGHT)
          love.graphics.setColor(255,255,255)
        end
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
      love.graphics.print("reset : r", 10, hScreen - 30, 0, 2, 2)
      love.graphics.print("resolved : "..tostring(resolved), 125, hScreen - 30, 0, 2, 2)
end 

function game.Draw()
  -------------------------------------
  -- **appel de la fonction drawGame()** --
  -------------------------------------
  drawGame()
  -- trace une grille de controle de position
  --love.graphics.setColor(255,0,0,120)
  --for i = 0, 1400, 64 do
  --  love.graphics.line(i, 0, i, 700)
  --end
  --for i = 0, 700, 64 do
  --  love.graphics.line(0, i, 1400, i)
  --end
  --
  --love.graphics.setColor(255,255,255)
end

function game.KeyPressed(pKey)
  resetLevel(pKey)
  newLevel(pKey)
end




return game 