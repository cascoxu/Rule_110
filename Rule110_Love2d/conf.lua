require 'TextBox'

function love.conf(t)
	t.identity = nil                    -- The name of the save directory (string)
    t.appendidentity = false            -- Search files in source directory before save directory (boolean)
    t.version = "11.3"                  -- The LÖVE version this game was made for (string)
    -- To activate console debugging
	t.console = true
    t.accelerometerjoystick = false      -- Enable the accelerometer on iOS and Android by exposing it as a Joystick (boolean)
    t.externalstorage = false           -- True to save files (and read from the save directory) in external storage on Android (boolean) 
    t.gammacorrect = false              -- Enable gamma-correct rendering, when supported by the system (boolean)
 
    t.audio.mic = false                 -- Request and use microphone capabilities in Android (boolean)
    t.audio.mixwithsystem = true        -- Keep background music playing when opening LOVE (boolean, iOS and Android only)

	t.modules.audio = true              -- Enable the audio module (boolean)
    t.modules.data = true               -- Enable the data module (boolean)
    t.modules.event = true              -- Enable the event module (boolean)
    t.modules.font = true               -- Enable the font module (boolean)
    t.modules.graphics = true           -- Enable the graphics module (boolean)
    t.modules.image = true              -- Enable the image module (boolean)
    t.modules.joystick = false           -- Enable the joystick module (boolean)
    t.modules.keyboard = true           -- Enable the keyboard module (boolean)
    t.modules.math = true               -- Enable the math module (boolean)
    t.modules.mouse = true              -- Enable the mouse module (boolean)
    t.modules.physics = false            -- Enable the physics module (boolean)
    t.modules.sound = true              -- Enable the sound module (boolean)
    t.modules.system = true             -- Enable the system module (boolean)
    t.modules.thread = false             -- Enable the thread module (boolean)
    t.modules.timer = true              -- Enable the timer module (boolean), Disabling it will result 0 delta time in love.update
    t.modules.touch = false              -- Enable the touch module (boolean)
    t.modules.video = true              -- Enable the video module (boolean)
    t.modules.window = true             -- Enable the window module (boolean)    
	
	cellWidth = 2
    numberOfHorizontalCells = 1000
    numberOfVerticalCells = 600
    generationsPerIteration = 1
    windowWidth = cellWidth * numberOfHorizontalCells
	windowHeight = cellWidth * numberOfVerticalCells
	windowWidth = 1000
    windowHeight = 600
    
    minimunWidth = 800
    minimunHeight = 600

    black = 
	{
		0, 0, 0
	}
	color = 
	{
		1.00, 0.25, 0.00
    } 

    drawFromTop = 1
    ruleNumber = 110

    if love.filesystem.getInfo('settings.txt') == nil then
		writeConfigFile()   
    else
        readConfigFile()
	end
	
	t.window.title = "Rule 110"        -- The window title (string)
    t.window.icon = nil                 -- Filepath to an image to use as the window's icon (string)
    t.window.width = windowWidth    
	t.window.height = windowHeight
    t.window.borderless = false         -- Remove all border visuals from the window (boolean)
    t.window.resizable = false          -- Let the window be user-resizable (boolean)
    t.window.minwidth = minimunWidth               -- Minimum window width if the window is resizable (number)
    t.window.minheight = minimunHeight             -- Minimum window height if the window is resizable (number)
    t.window.fullscreen = false         -- Enable fullscreen (boolean)
    t.window.fullscreentype = "desktop" -- Choose between "desktop" fullscreen or "exclusive" fullscreen mode (string)
    t.window.vsync = 0                  -- Vertical sync mode (number)
    t.window.msaa = 0                   -- The number of samples to use with multi-sampled antialiasing (number)
    t.window.depth = nil                -- The number of bits per sample in the depth buffer
    t.window.stencil = nil              -- The number of bits per sample in the stencil buffer
    t.window.display = 2                -- Index of the monitor to show the window in (number)
    t.window.highdpi = false            -- Enable high-dpi mode for the window on a Retina display (boolean)
    t.window.usedpiscale = true         -- Enable automatic DPI scaling when highdpi is set to true as well (boolean)
    t.window.x = nil                    -- The x-coordinate of the window's position in the specified display (number)
	t.window.y = nil                    -- The y-coordinate of the window's position in the specified display (number)

    cameraPosX = 0
    cameraPosY = 0
	
	menuHorizontalPos = 220
    menuVerticalPos = 200
    menuOutlineHorizontalPos = 20
    menuOutlineVerticalPos = 220
    menuTextVerticalIncrement = 20
	menuGroupVerticalIncrement = 10
	configScreenAdditionalHorizontalSpace = 10
    menuWidth = 560
	menuHeight = 420
	
	fontsize = 18
	
end

function writeConfigFile()
    f = love.filesystem.newFile('settings.txt')
    f:open("w") 
        f:write(cellWidth .. "\r\n")
        f:write(numberOfHorizontalCells .. "\r\n")
        f:write(numberOfVerticalCells .. "\r\n")
        f:write(generationsPerIteration .. "\r\n")
        f:write(windowWidth .. "\r\n")
        f:write(windowHeight .. "\r\n")
        f:write(minimunWidth .. "\r\n")
        f:write(minimunHeight .. "\r\n")
        f:write(color[1] .. "," .. color[2] .. "," .. color[3] .. "\r\n")
        f:write(drawFromTop .. "\r\n")
        f:write(ruleNumber .. "\r\n")
    f:close()    
end

function readConfigFile()
    contents, size = love.filesystem.read('settings.txt')

    values = split(contents, "\r\n")
    cellWidth = tonumber(values[1])
    numberOfHorizontalCells = tonumber(values[2])
    numberOfVerticalCells = tonumber(values[3])
    generationsPerIteration = tonumber(values[4])
    windowWidth = tonumber(values[5])
	windowHeight = tonumber(values[6])    
    minimunWidth = tonumber(values[7])
    minimunHeight = tonumber(values[8])

    colorAux = split(values[9], ",")
    color = { colorAux[1], colorAux[2], colorAux[3] }
    drawFromTop =  tonumber(values[10])
    ruleNumber =  tonumber(values[11])
end

--Helper Methods
function split(s, delimiter)
    result = {}
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end


num=7
function toBits(num)
    -- returns a table of bits, least significant first.
    local t={} -- will contain the bits
    while num>0 do
        rest=math.fmod(num,2)
        t[#t+1]=rest
        num=(num-rest)/2
    end
    return t
end
bits=toBits(num)
print(table.concat(bits))