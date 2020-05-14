-- local utf8 = require("utf8")

CheckBox = {}
CheckBox._index = CheckBox

function CheckBox:Create(posX, posY, widthP, heightP, backColor, xColor, foreColor, value)
    local this = 
    {
        x = posX,
        y = posY,
        width = widthP,
        height = heightP,
        active = value,        
        colors = {
            background = backColor,
            x = xColor,
            outline = foreColor
        }
    }

    function this:Draw() 
        love.graphics.setColor(this.colors.outline)
        love.graphics.setLineWidth( 2 )
        love.graphics.rectangle("line", this.x,  this.y, this.width, this.height)
        if this.active == 1 then
            this.DrawX()
        end
    end

    function this:DrawX()
        love.graphics.circle("fill", this.x + this.width/2 ,  this.y + this.height/2, this.width/2 - 4)   
    end    

    function this:Activate(mouseX, mouseY)       
        if
            mouseX >= this.x and
            mouseX <= this.x + this.width and
            mouseY >= this.y and
            mouseY <= this.y + this.height
        then
            if this.active == 1 then
                this.active = 0
            else
                this.active = 1
            end
        end
    end

    function this:SetValue(value)
        this.active = value
    end

    function this:GetValue()
        return this.active
    end

    setmetatable(this, CheckBox)

    return this
end


