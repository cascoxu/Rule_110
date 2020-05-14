local utf8 = require("utf8")

TextBox = {}
TextBox._index = TextBox

function TextBox:Create(posX, posY, widthP, heightP, backColor, textColor, foreColor, textP, validationPatternP)
    local this = 
    {
        x = posX,
        y = posY,
        width = widthP,
        height = heightP,
        text = textP,
        active = false,
        cursor = '|',
        frame = 0,
        cursorFrames=20,
        validationPattern=validationPatternP,
        colors = {
            background = backColor,
            text = textColor,
            outline = foreColor
        }
    }

    function this:Draw() 
        love.graphics.setColor(this.colors.outline)
        love.graphics.setLineWidth( 2 )
        love.graphics.rectangle("line", this.x,  this.y, this.width, this.height)
        love.graphics.printf(this.text, this.x+4, this.y+2, this.width, 'left')
        if this.active == true then
            this.DrawCursor()
        end
    end

    function this:DrawCursor()
        this.frame = this.frame + 1
        if(this.frame >= this.cursorFrames*2) then
            this.frame = 0
        end
        -- love.graphics.setColor(0,0,1)
        -- love.graphics.rectangle("fill", this.x+2,  this.y+2, this.width-4, this.height-4)
        font = love.graphics.getFont()
        if this.frame < this.cursorFrames then
            love.graphics.printf(this.cursor, this.x + font:getWidth(this.text)+3, this.y,this.width, 'left')
        end
    end    

    function this:Activate(mouseX, mouseY)       
        if
            mouseX >= this.x and
            mouseX <= this.x + this.width and
            mouseY >= this.y and
            mouseY <= this.y + this.height
        then
            this.active = true
        elseif this.active then
            this.active = false
        end
    end

    function this:SetText(text)  
        if this.active == true and string.match(text, this.validationPattern) then
            font = love.graphics.getFont()
            if font:getWidth(this.text .. this.cursor) + font:getWidth(text) < this.width then
                this.text = this.text .. text
            end
        end
    end

    function this:DeleteCharacter(key)
        if key == "backspace" and this.active then
            -- get the byte offset to the last UTF-8 character in the string.
            local byteoffset = utf8.offset(this.text, -1)
     
            if byteoffset then
                -- remove the last UTF-8 character.
                -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
                this.text = string.sub(this.text, 1, byteoffset - 1)
            end
        end
    end

    function this:Deactivate()
        this.active = false
    end

    function this:GetText()
    -- print(this.text)
        return this.text
    end

    setmetatable(this, TextBox)
    return this
end


