require 'TextBox'
require 'CheckBox'
lume = require "lume"
lurker = require "lurker"
gamera = require "gamera"

--Función para calcular instatanameante el autómata sin pasar por todas las reescrituras de pantalla

function love.load(arg)
    init()
end

function love.update(dt) 
    lurker.update()  

     if generationsPerIteration > 1 then
               if iteration % generationsPerIteration == 0 then
                    drawAutomata()
               end      
            else    
                drawAutomata()
            end

    if start == 1 then
        if pause == 0 and configScreen == 0 then
            if generationsPerIteration > 1 then
               for i=iteration, iteration + generationsPerIteration do                 
                    iteration = iteration + 1
                    updateAutomata()  
               end      
            else               
                iteration = iteration + 1
                updateAutomata()  
            end      
        end
    end

    if configScreen == 1 then        
        menu = 0
    end

    love.graphics.setColor(color)
end

function love.draw(dt)

    if(start == 1) then
        cam:draw(function(l,t,w,h)
            cam:setScale(scale)
            cam:setPosition(cameraPosX, cameraPosY)           
           
            drawAutomata()           
          end)   
          showIterarionCounter()  
        if (pause == 1 and hidePauseMenu == 0) or menu == 1 then
            drawMenu()
        end        
    else
        drawMenu()  
    end

    if configScreen == 1 then
        drawConfigScreen()
    end
end

function love.keypressed(key, scancode, isrepeat)
    checkKeyPressed(key, scancode, isrepeat)
end

function love.mousepressed (x, y, buttonIndex)
    UIElementMoussePressed(x,y)
    
    if buttonIndex == 1 then
        mouseISPress = 1
    end

    -- cameraPosX = x
    -- cameraPosY = y
    cam:setPosition(x, y)
end

function love.wheelmoved(x, y)
    if y > 0 then
        scale = scale+0.1
    elseif y < 0 then
        scale = scale-0.1
        if scale <= 0 then
            scale = 0.0
        end
    end
end

function love.mousereleased(x, y, buttonIndex)
	if buttonIndex == 1  then
		mouseISPress = 0
	end
end

function love.mousemoved( x, y, dx, dy, istouch )
    -- if mouseISPress == 1 and (dx >= 1 or dy >= 1) then
    if mouseISPress == 1 then
        cameraPosX = cameraPosX + dx
        cameraPosY = cameraPosY + dy

        -- print(mouseISPress)
        if cameraPosX > (cellWidth * numberOfHorizontalCells) - windowWidth /2 then
            cameraPosX = (cellWidth * numberOfHorizontalCells) - windowWidth /2
        end
        if cameraPosX < windowWidth /2 then
            cameraPosX = windowWidth /2
        end

        if cameraPosY > (cellWidth * numberOfVerticalCells) - windowHeight /2 then
             cameraPosY = (cellWidth * numberOfVerticalCells) - windowHeight /2
        end
        if cameraPosY < windowHeight /2 then
             cameraPosY = windowHeight /2
        end

    end
end

function love.textinput (text)
    if text ~= nill then
        textBoxInput(text)
    end
end

--Own methods

function init()

    mouseISPress = 0
    --UI elements
    if configScreen == 1 then
       applyConfig()
    end

    initConfigScreenUIElements()

    cam = gamera.new(0, 0, cellWidth * numberOfHorizontalCells, cellWidth * numberOfVerticalCells)
    cam:setWindow(0, 0, windowWidth, windowHeight)
    -- cam:setWindow(0, 0, cellWidth * numberOfHorizontalCells, cellWidth * numberOfVerticalCells)
    
    scale = 1.0

    if drawFromTop == 0 then
        cameraPosX = (cellWidth * numberOfHorizontalCells) - windowWidth /2
        cameraPosY = (cellWidth * numberOfVerticalCells) - windowHeight /2
    else
        cameraPosX = (cellWidth * numberOfHorizontalCells) - windowWidth /2
        cameraPosY = windowHeight /2
    end

    --print(cameraPosX, cameraPosY)

    cam:setPosition(cameraPosX, cameraPosY)

    --State
    randomColors = 0
    randomExtremes = 0
    randomAllNewLine = 0
    start = 0
    pause = 0
    keepRandom = 0
    configScreen = 0
    menu = 1 
    hidePauseMenu = 0
    showIteration = 0

    iteration = 0
    --For making the matrix a circular queue in the vertical direction
    posInMatrixHeight = 1

    love.keyboard.setKeyRepeat( true )
    love.graphics.setNewFont(fontsize)

    math.randomseed(os.time())

    q=0

    a = {}    -- new array
    for i=1, numberOfHorizontalCells do
      a[i] = 0
    end

    mt = {} 
    mtColor= {}        
    for i=1,numberOfHorizontalCells do
      mt[i] = {}  
      mtColor[i]= {}     
      for j=1,numberOfVerticalCells do
        mt[i][j] = 0
        mtColor[i][j]= {}
        mtColor[i][j][1] = 0
        mtColor[i][j][2] = 0
        mtColor[i][j][3] = 0
      end
    end

    --For making the matrix a circular queue in the vertical direction
    for i=1, numberOfHorizontalCells do
        --mt[i][numberOfVerticalCells] = math.random(0,1)
        mt[i][posInMatrixHeight] = 0
    end
    
    mt[numberOfHorizontalCells][posInMatrixHeight] = 1
    mtColor[numberOfHorizontalCells][posInMatrixHeight][1] = math.random()
    mtColor[numberOfHorizontalCells][posInMatrixHeight][2] = math.random()
    mtColor[numberOfHorizontalCells][posInMatrixHeight][3] = math.random()

end

function updateAutomata()
    
    for i=1, numberOfHorizontalCells do
        --a[i] = mt[i][numberOfVerticalCells]
        --For making the matrix a circular queue in the vertical direction  
        a[i] = mt[i][posInMatrixHeight]        
        --mt[i][numberOfVerticalCells] = 0
    end

    --Randomize the extremes of the last line, to which then is applied the Rule 110 to generate the new line added in the botton of the screen
    --this makes the automata remain random indefinitely. If you delete this the automata will arrive to a stationary state after some hundred iterations
    if(randomExtremes == 1) then
        a[1] = math.random(0,1)
        if a[1] == 1 then
            mtColor[1][posInMatrixHeight][1] = math.random()
            mtColor[1][posInMatrixHeight][2] = math.random()
            mtColor[1][posInMatrixHeight][3] = math.random()
        end
        a[numberOfHorizontalCells] = math.random(0,1)
        if a[numberOfHorizontalCells] == 1 then
            mtColor[numberOfHorizontalCells][posInMatrixHeight][1] = math.random()
            mtColor[numberOfHorizontalCells][posInMatrixHeight][2] = math.random()
            mtColor[numberOfHorizontalCells][posInMatrixHeight][3] = math.random()
        end
    end

    if(randomAllNewLine == 1) then
        for i=1, numberOfHorizontalCells do
            a[i] = math.random(0,1)
        end    
    end

    --For making the matrix a circular queue in the vertical direction   
    posInMatrixHeight = posInMatrixHeight + 1
    if posInMatrixHeight >= numberOfVerticalCells then
        posInMatrixHeight = 1
    end    
    if randomExtremes == 1 or randomAllNewLine == 1 then
        mt[1][posInMatrixHeight] = a[1]
        mt[numberOfHorizontalCells][posInMatrixHeight] = a[numberOfHorizontalCells]
    end

    if keepRandom == 0 then
        randomAllNewLine = 0
    end

    for i=1, numberOfHorizontalCells - 2 do
        
        d = a[i]
        b = a[i+1]
        c = a[i+2]        

       if(d==1 and b==1 and c==1) or (d==1 and b==0 and c==0) or (d==0 and b==0 and c==0) then
            mt[i+1][posInMatrixHeight] = 0

            mtColor[i+1][posInMatrixHeight][1] = 0
            mtColor[i+1][posInMatrixHeight][2] = 0
            mtColor[i+1][posInMatrixHeight][3] = 0
        end

        if(d==1 and b==1 and c==0) or (d==1 and b==0 and c==1) or (d==0 and b==1 and c==1) or (d==0 and b==1 and c==0) or (d==0 and b==0 and c==1) then
            mt[i+1][posInMatrixHeight] = 1

            mtColor[i+1][posInMatrixHeight][1] = math.random()
            mtColor[i+1][posInMatrixHeight][2] = math.random()
            mtColor[i+1][posInMatrixHeight][3] = math.random()
        end
    end
end

function drawAutomata()

    if drawFromTop == 1 then
        for j=1, numberOfVerticalCells do
            for i=1, numberOfHorizontalCells do
                if mt[i][j] == 1 then    
                    if(randomColors == 1) then
                        love.graphics.setColor( mtColor[i][j][1], mtColor[i][j][2], mtColor[i][j][3]);   
                    end   
                    love.graphics.rectangle("fill", (i-1)*cellWidth, (j-1)*cellWidth, cellWidth, cellWidth )           
                end
            end       
        end
    else
        m = numberOfVerticalCells
        for j=posInMatrixHeight, 1, -1 do
         
            for i=1, numberOfHorizontalCells do
                if mt[i][j] == 1 then    
                    if(randomColors == 1) then
                        love.graphics.setColor( mtColor[i][j][1], mtColor[i][j][2], mtColor[i][j][3]);   
                    end   
                    love.graphics.rectangle("fill", (i-1)*cellWidth, (m-1)*cellWidth, cellWidth, cellWidth )           
                end
            end
            m = m-1
        end

        m=2
         for j=posInMatrixHeight+1, numberOfVerticalCells do         
            for i=1, numberOfHorizontalCells do
                if mt[i][j] == 1 then    
                    if(randomColors == 1) then
                        love.graphics.setColor( mtColor[i][j][1], mtColor[i][j][2], mtColor[i][j][3]);   
                    end   
                    love.graphics.rectangle("fill", (i-1)*cellWidth, (m-1)*cellWidth, cellWidth, cellWidth )           
                end
            end
            m = m+1
        end
    end
end

function showIterarionCounter()
    if(showIteration == 1) then    
        
        disVer = 280
        counterWitdh =  200
        counterHight = 50  
        posHor = windowWidth/2 - counterWitdh/2        
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", posHor,  windowHeight/2 - disVer, counterWitdh, counterHight)
        love.graphics.setColor(color)
        love.graphics.setLineWidth( 4 )
        love.graphics.rectangle("line", posHor,  windowHeight/2 - disVer, counterWitdh, counterHight)
        iter = "Iterarion: " ..iteration 
        font = love.graphics.getFont()
        posText =  windowWidth/2 - font:getWidth(iter)/2
        love.graphics.print(iter , posText, windowHeight/2 - disVer + 15, 0, 1, 1, 0, 0, 0, 0 )   
    end       
            
end

function drawMenu()
    drawMenuBackground()
    drawMenuTexts()   
end

function drawMenuBackground()
    posHor = windowWidth/2 - menuWidth/2
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", posHor,  windowHeight/2 - menuOutlineVerticalPos, menuWidth, menuHeight)
    love.graphics.setColor(color)
    love.graphics.setLineWidth( 4 )
    love.graphics.rectangle("line", posHor,  windowHeight/2 - menuOutlineVerticalPos, menuWidth, menuHeight)
end

function drawMenuTexts()
    posHor = windowWidth/2 - menuWidth/2 + 40
    groupOrder = 0
    order = 0
    love.graphics.print( "Press s to start", posHor, windowHeight/2 - menuVerticalPos + ( order*menuTextVerticalIncrement) + (groupOrder* menuGroupVerticalIncrement), 0, 1, 1, 0, 0, 0, 0 )
    order = order + 1
    love.graphics.print( "Press Esc to restart automata", posHor, windowHeight/2 - menuVerticalPos + ( order*menuTextVerticalIncrement) + (groupOrder* menuGroupVerticalIncrement), 0, 1, 1, 0, 0, 0, 0 )
    order = order + 1
    love.graphics.print( "Press p to pause/unpause automata", posHor, windowHeight/2 - menuVerticalPos + (order*menuTextVerticalIncrement) + (groupOrder* menuGroupVerticalIncrement), 0, 1, 1, 0, 0, 0, 0 )
    order = order + 1
    love.graphics.print( "Press x to open/close config menu", posHor, windowHeight/2 - menuVerticalPos + (order*menuTextVerticalIncrement) + (groupOrder* menuGroupVerticalIncrement), 0, 1, 1, 0, 0, 0, 0 )
    order = order + 1
    love.graphics.print( "Press m to open/close menu during execution", posHor, windowHeight/2 - menuVerticalPos + (order*menuTextVerticalIncrement) + (groupOrder* menuGroupVerticalIncrement), 0, 1, 1, 0, 0, 0, 0 )
    order = order + 1
    love.graphics.print( "Press h to hide/unhide pause menu", posHor, windowHeight/2 - menuVerticalPos + (order*menuTextVerticalIncrement) + (groupOrder* menuGroupVerticalIncrement), 0, 1, 1, 0, 0, 0, 0 )
    order = order + 1
    love.graphics.print( "Press i to show/hide iterations counter", posHor, windowHeight/2 - menuVerticalPos + (order*menuTextVerticalIncrement) + (groupOrder* menuGroupVerticalIncrement), 0, 1, 1, 0, 0, 0, 0 )
    order = order + 1
    love.graphics.print( "Press v/b or turn mouse wheel  to zoom in/out", posHor, windowHeight/2 - menuVerticalPos + (order*menuTextVerticalIncrement) + (groupOrder* menuGroupVerticalIncrement), 0, 1, 1, 0, 0, 0, 0 )
    order = order + 1
    love.graphics.print( "Press q to quit application", posHor, windowHeight/2 - menuVerticalPos + (order*menuTextVerticalIncrement) + (groupOrder* menuGroupVerticalIncrement), 0, 1, 1, 0, 0, 0, 0 )
    
    groupOrder = groupOrder + 1
    order = order + 1
    love.graphics.print( "Press c to activate/deactivate random colors", posHor, windowHeight/2  - menuVerticalPos + (order*menuTextVerticalIncrement) + (groupOrder* menuGroupVerticalIncrement), 0, 1, 1, 0, 0, 0, 0 )
    order = order + 1
    love.graphics.print( "Press e to activate/deactivate random line extremes", posHor, windowHeight/2 - menuVerticalPos + (order*menuTextVerticalIncrement) + (groupOrder* menuGroupVerticalIncrement), 0, 1, 1, 0, 0, 0, 0 )
    order = order + 1
    love.graphics.print( "Press r to create a random new line", posHor, windowHeight/2 - menuVerticalPos + (order*menuTextVerticalIncrement) + (groupOrder* menuGroupVerticalIncrement), 0, 1, 1, 0, 0, 0, 0 )
    order = order + 1
    love.graphics.print( "Press k to activate/deactivate continous random lines", posHor, windowHeight/2 - menuVerticalPos + (order*menuTextVerticalIncrement) + (groupOrder* menuGroupVerticalIncrement), 0, 1, 1, 0, 0, 0, 0 )
    order = order + 1
    love.graphics.print( "Press i to show iterations counter", posHor, windowHeight/2 - menuVerticalPos + (order*menuTextVerticalIncrement) + (groupOrder* menuGroupVerticalIncrement), 0, 1, 1, 0, 0, 0, 0 )

    groupOrder = groupOrder + 1
    order = order + 1
    love.graphics.print( "Random Colors: " .. randomColors, posHor, windowHeight/2 - menuVerticalPos + (order*menuTextVerticalIncrement) + (groupOrder* menuGroupVerticalIncrement), 0, 1, 1, 0, 0, 0, 0 )
    order = order + 1
    love.graphics.print( "Random Extremes: " .. randomExtremes, posHor, windowHeight/2 - menuVerticalPos + (order*menuTextVerticalIncrement) + (groupOrder* menuGroupVerticalIncrement), 0, 1, 1, 0, 0, 0, 0 )
    order = order + 1
    love.graphics.print( "Random New Line: " .. randomAllNewLine, posHor, windowHeight/2 - menuVerticalPos + (order*menuTextVerticalIncrement) + (groupOrder* menuGroupVerticalIncrement), 0, 1, 1, 0, 0, 0, 0 )
    order = order + 1
    love.graphics.print( "Keep generating random lines: " .. keepRandom, posHor, windowHeight/2 - menuVerticalPos + (order*menuTextVerticalIncrement) + (groupOrder* menuGroupVerticalIncrement), 0, 1, 1, 0, 0, 0, 0 )    
end

function initConfigScreenUIElements()
    textBoxWidth = 80
    textBoxHeight = 25
    textBoxDisplacementRight = 220
    groupOrder = 0
    order = 0
    validationPattern = '[0-9]'
    validationPatternRGB='[0-9]?%.?[0-9]?[0-9]?,?[0-9]?%.?[0-9]?[0-9]?,?[0-9]?%.?[0-9]?[0-9]?'
    validationPatternRGB=''    
    textBoxScreenWidth = TextBox:Create(windowWidth/2 + textBoxDisplacementRight, windowHeight/2 - menuVerticalPos + ( order*menuTextVerticalIncrement + order*configScreenAdditionalHorizontalSpace) + (groupOrder* menuGroupVerticalIncrement), textBoxWidth, textBoxHeight, black, color, color, windowWidth, validationPattern)
    order = order + 1
    textBoxScreenHeight = TextBox:Create(windowWidth/2 + textBoxDisplacementRight, windowHeight/2 - menuVerticalPos + ( order*menuTextVerticalIncrement + order*configScreenAdditionalHorizontalSpace) + (groupOrder* menuGroupVerticalIncrement) , textBoxWidth, textBoxHeight, black, color, color, windowHeight, validationPattern)

    groupOrder = groupOrder + 1
    order = order + 1
    textBoxHorizontalCells = TextBox:Create(windowWidth/2 + textBoxDisplacementRight, windowHeight/2 - menuVerticalPos + ( order*menuTextVerticalIncrement + order*configScreenAdditionalHorizontalSpace) + (groupOrder* menuGroupVerticalIncrement) , textBoxWidth, textBoxHeight, black, color, color, numberOfHorizontalCells, validationPattern)
    order = order + 1
    textBoxVerticalCells = TextBox:Create(windowWidth/2 + textBoxDisplacementRight, windowHeight/2 - menuVerticalPos + ( order*menuTextVerticalIncrement + order*configScreenAdditionalHorizontalSpace) + (groupOrder* menuGroupVerticalIncrement) , textBoxWidth, textBoxHeight, black, color, color, numberOfVerticalCells, validationPattern)
    order = order + 1
    textBoxCellSize = TextBox:Create(windowWidth/2 + textBoxDisplacementRight, windowHeight/2 - menuVerticalPos + ( order*menuTextVerticalIncrement + order*configScreenAdditionalHorizontalSpace) + (groupOrder* menuGroupVerticalIncrement) ,textBoxWidth, textBoxHeight, black, color, color, cellWidth, validationPattern)

    groupOrder = groupOrder + 1
    order = order + 1
    textBoxGenerationsPerIteration = TextBox:Create(windowWidth/2 + textBoxDisplacementRight, windowHeight/2 - menuVerticalPos + ( order*menuTextVerticalIncrement + order*configScreenAdditionalHorizontalSpace) + (groupOrder* menuGroupVerticalIncrement) , textBoxWidth, textBoxHeight, black, color, color, generationsPerIteration, validationPattern)
    
    groupOrder = groupOrder + 1
    order = order + 1
    colorString = color[1] .. "," .. color[2] .. "," .. color[3]
    textBoxColor = TextBox:Create(windowWidth/2 + textBoxDisplacementRight - 60, windowHeight/2 - menuVerticalPos + ( order*menuTextVerticalIncrement + order*configScreenAdditionalHorizontalSpace) + (groupOrder* menuGroupVerticalIncrement) , 140, textBoxHeight, black, color, color, colorString, validationPatternRGB)

    groupOrder = groupOrder + 1
    order = order + 1
    checkBoxDrawFromTop = CheckBox:Create(windowWidth/2 + textBoxDisplacementRight + 60, windowHeight/2 - menuVerticalPos + ( order*menuTextVerticalIncrement + order*configScreenAdditionalHorizontalSpace) + (groupOrder* menuGroupVerticalIncrement) , 20, 20, black, color, color, drawFromTop)
    order = order + 1
    textBoxRuleNumber = TextBox:Create(windowWidth/2 + textBoxDisplacementRight, windowHeight/2 - menuVerticalPos + ( order*menuTextVerticalIncrement + order*configScreenAdditionalHorizontalSpace) + (groupOrder* menuGroupVerticalIncrement) , textBoxWidth, textBoxHeight, black, color, color, ruleNumber, validationPattern)
    
end

function drawConfigScreen()
    love.graphics.clear()

    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", windowWidth/2 - menuHorizontalPos - menuOutlineHorizontalPos,  windowHeight/2 - menuOutlineVerticalPos, menuWidth, menuHeight)
    love.graphics.setColor(color)
    love.graphics.setLineWidth( 4 )
    love.graphics.rectangle("line", windowWidth/2 - menuHorizontalPos - menuOutlineHorizontalPos,  windowHeight/2 - menuOutlineVerticalPos, menuWidth, menuHeight)

    groupOrder = 0
    order = 0
    love.graphics.print( "Screen Width: ", windowWidth/2 - menuHorizontalPos, windowHeight/2 - menuVerticalPos + ( order*menuTextVerticalIncrement + order*configScreenAdditionalHorizontalSpace) + (groupOrder* menuGroupVerticalIncrement), 0, 1, 1, 0, 0, 0, 0 )
    order = order + 1
    love.graphics.print( "Screen Height: ", windowWidth/2 - menuHorizontalPos, windowHeight/2 - menuVerticalPos + ( order*menuTextVerticalIncrement + order*configScreenAdditionalHorizontalSpace) + (groupOrder* menuGroupVerticalIncrement), 0, 1, 1, 0, 0, 0, 0 )
    
    groupOrder = groupOrder + 1
    order = order + 1
    love.graphics.print( "Number of Horizotal Cells : ", windowWidth/2 - menuHorizontalPos, windowHeight/2 - menuVerticalPos + ( order*menuTextVerticalIncrement + order*configScreenAdditionalHorizontalSpace) + (groupOrder* menuGroupVerticalIncrement), 0, 1, 1, 0, 0, 0, 0 )
    order = order + 1
    love.graphics.print( "Number of Vertical Cells: ", windowWidth/2 - menuHorizontalPos, windowHeight/2 - menuVerticalPos + ( order*menuTextVerticalIncrement + order*configScreenAdditionalHorizontalSpace) + (groupOrder* menuGroupVerticalIncrement), 0, 1, 1, 0, 0, 0, 0 )
    order = order + 1
    love.graphics.print( "Cell Size: ", windowWidth/2 - menuHorizontalPos, windowHeight/2 - menuVerticalPos + ( order*menuTextVerticalIncrement + order*configScreenAdditionalHorizontalSpace) + (groupOrder* menuGroupVerticalIncrement), 0, 1, 1, 0, 0, 0, 0 )

    groupOrder = groupOrder + 1
    order = order + 1
    love.graphics.print( "Generations Per Iterarion: ", windowWidth/2 - menuHorizontalPos, windowHeight/2 - menuVerticalPos + ( order*menuTextVerticalIncrement + order*configScreenAdditionalHorizontalSpace) + (groupOrder* menuGroupVerticalIncrement), 0, 1, 1, 0, 0, 0, 0 )
    
    groupOrder = groupOrder + 1
    order = order + 1
    love.graphics.print( "Color (R,G,B)(Values 0.00 to 1.00): ", windowWidth/2 - menuHorizontalPos, windowHeight/2 - menuVerticalPos + ( order*menuTextVerticalIncrement + order*configScreenAdditionalHorizontalSpace) + (groupOrder* menuGroupVerticalIncrement), 0, 1, 1, 0, 0, 0, 0 )

    groupOrder = groupOrder + 1
    order = order + 1
    love.graphics.print( "Generate automata from top: ", windowWidth/2 - menuHorizontalPos, windowHeight/2 - menuVerticalPos + ( order*menuTextVerticalIncrement + order*configScreenAdditionalHorizontalSpace) + (groupOrder* menuGroupVerticalIncrement), 0, 1, 1, 0, 0, 0, 0 )
    order = order + 1
    love.graphics.print( "Rule number (Values in the range 0-255): ", windowWidth/2 - menuHorizontalPos, windowHeight/2 - menuVerticalPos + ( order*menuTextVerticalIncrement + order*configScreenAdditionalHorizontalSpace) + (groupOrder* menuGroupVerticalIncrement), 0, 1, 1, 0, 0, 0, 0 )
  
    love.graphics.print( "Press Esc to apply changes ", windowWidth/2 - 100, windowHeight/2 + 125, 0, 1, 1, 0, 0, 0, 0 )

    drawUIElements()
end

function drawUIElements()
    textBoxScreenWidth:Draw()
    textBoxScreenHeight:Draw()
    textBoxHorizontalCells:Draw()
    textBoxVerticalCells:Draw()
    textBoxCellSize:Draw()
    textBoxGenerationsPerIteration:Draw()
    textBoxColor:Draw()
    textBoxRuleNumber:Draw()

print(checkBoxDrawFromTop.GetValue())
    checkBoxDrawFromTop:Draw()
end

function textBoxKeyPressed(key)
    textBoxScreenWidth:DeleteCharacter(key)
    textBoxScreenHeight:DeleteCharacter(key)
    textBoxHorizontalCells:DeleteCharacter(key)
    textBoxVerticalCells:DeleteCharacter(key)
    textBoxCellSize:DeleteCharacter(key)
    textBoxGenerationsPerIteration:DeleteCharacter(key)
    textBoxColor:DeleteCharacter(key)
    textBoxRuleNumber:DeleteCharacter(key)
end

function UIElementMoussePressed(x,y)
    textBoxScreenWidth:Activate(x,y)
    textBoxScreenHeight:Activate(x,y)
    textBoxHorizontalCells:Activate(x,y)
    textBoxVerticalCells:Activate(x,y)
    textBoxCellSize:Activate(x,y)
    textBoxGenerationsPerIteration:Activate(x,y)
    textBoxColor:Activate(x,y)
    textBoxRuleNumber:Activate(x,y)

    checkBoxDrawFromTop:Activate(x,y)
end

function textBoxInput(text)
    if text ~= nil then
        textBoxScreenWidth:SetText(text)
        textBoxScreenHeight:SetText(text)
        textBoxHorizontalCells:SetText(text)
        textBoxVerticalCells:SetText(text)
        textBoxCellSize:SetText(text)
        textBoxGenerationsPerIteration:SetText(text)
        textBoxColor:SetText(text)
        textBoxRuleNumber:SetText(text)

        if textBoxRuleNumber:GetText() ~= nil and textBoxRuleNumber:GetText() ~= '' then
            aux = tonumber(textBoxRuleNumber:GetText())
            if aux < 0 then
                textBoxRuleNumber:SetText("0")
            end
            if aux > 255 then
                textBoxRuleNumber:SetText("255")
            end
        end
    end
end

function UIElementDeactivate()
    textBoxScreenWidth:Deactivate()
    textBoxScreenHeight:Deactivate()
    textBoxHorizontalCells:Deactivate()
    textBoxVerticalCells:Deactivate()
    textBoxCellSize:Deactivate()
    textBoxGenerationsPerIteration:Deactivate()
    textBoxColor:Deactivate()
    textBoxRuleNumber:Deactivate()
end

function applyConfig()
    if textBoxScreenWidth:GetText() ~= nil and textBoxScreenWidth:GetText() ~= '' then
        aux = tonumber(textBoxScreenWidth:GetText())
        if aux >= minimunWidth then
            windowWidth = aux
        end
    end
    if textBoxScreenHeight:GetText() ~= nil and textBoxScreenHeight:GetText() ~= '' then
        aux = tonumber(textBoxScreenHeight:GetText())
        if aux >= minimunHeight then
            windowHeight = aux
        end
    end
    if textBoxHorizontalCells:GetText() ~= nil and textBoxHorizontalCells:GetText() ~= ''  then
        numberOfHorizontalCells = tonumber(textBoxHorizontalCells:GetText())
    end
    if textBoxVerticalCells:GetText() ~= nil and textBoxVerticalCells:GetText() ~= '' then
        numberOfVerticalCells = tonumber(textBoxVerticalCells:GetText())
    end
    if textBoxCellSize:GetText() ~= nil and textBoxCellSize:GetText() ~= '' then
        cellWidth = tonumber(textBoxCellSize:GetText())
    end
    if textBoxGenerationsPerIteration:GetText() ~= nil and textBoxGenerationsPerIteration:GetText() ~= '' then
        aux = tonumber(textBoxGenerationsPerIteration:GetText())
        if aux >= 1 then
            generationsPerIteration = aux
        end
    end
    if textBoxColor:GetText() ~= nil and textBoxColor:GetText() ~= '' then
        colorValues = split(textBoxColor:GetText(), ",")
        color = { colorValues[1], colorValues[2], colorValues[3]}
    end
    if textBoxRuleNumber:GetText() ~= nil and textBoxRuleNumber:GetText() ~= '' then
        aux = tonumber(textBoxRuleNumber:GetText())
        if aux >= 1 then
            ruleNumber = aux
        end
    end

        drawFromTop = checkBoxDrawFromTop:GetValue()

    writeConfigFile()

    love.window.setMode(windowWidth, windowHeight, {resizable=false, display=2})
end

function checkKeyPressed(key, scancode, isrepeat)
    if key == "escape" then
       init()
    end

    if key == "q" then
        love.event.quit()
     end

    if key == "c" then
        if randomColors == 0 then
            randomColors = 1
        else
            randomColors = 0
        end
    end

    if key == "e" then
        if randomExtremes== 0 then
            randomExtremes = 1
        else
            randomExtremes = 0
        end
    end

    if key == "r" then
        if randomAllNewLine== 0 then
            randomAllNewLine = 1
        else
            randomAllNewLine = 0
        end
    end

    if key == "s" then
        if start== 0 then
            start = 1
            menu = 0
            pause = 0
            hidePauseMenu = 0
        else
            start = 0
        end
    end

    if key == "p" then
        if pause== 0 then
            pause = 1
        else
            pause = 0
        end
    end

    if key == "k" then
        if keepRandom == 0 then
            keepRandom = 1
        else
            keepRandom = 0
        end
    end

    if key == "i" then
        if showIteration == 0 then
            showIteration = 1
        else
            showIteration = 0
        end
    end

    if key == "x" then
        if configScreen == 0 then
            configScreen = 1
        else
            configScreen = 0
            UIElementDeactivate()
        end
    end

    if key == "m" then
        if menu == 0 then
            menu = 1
        else
            menu = 0
        end
    end

    if key == "h" then
        if hidePauseMenu == 0 then
            hidePauseMenu = 1
        else
            hidePauseMenu = 0
        end
    end

    if key == "up" then
        if cameraPosY >= 0 then
            cameraPosY = cameraPosY - 30
        end
    end

    if key == "down" then
        cameraPosY = cameraPosY + 30
    end

    if key == "left" then
        if cameraPosX >= 0 then
            cameraPosX = cameraPosX - 30   
        end
    end

    if key == "right" then
        cameraPosX = cameraPosX + 30 
    end

    if key == "v" then
        scale = scale-0.1
        if scale <= 0 then
            scale = 0.0
        end        
    end

    if key == "b" then
        scale = scale+0.1 
    end

    textBoxKeyPressed(key)
end

