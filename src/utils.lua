function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function clamp(value, min, max)
    return math.min(max, math.max(min, value))
end

function is_pixel_present(image, color)
    if image then
        for it in image:pixels() do
            if it() == color then
                return true
            end
        end
    end
    return false
end

function find_layer(name)
    local layer = nil
    for i, l in ipairs(app.activeSprite.layers) do
        if l.name == name then
            layer = l
            break
        end
    end

    if not layer then
        return false
    else
        return layer
    end
end

function find_perspective_layer()
    local perspective_layer = find_layer(GUIDE_LAYER_NAME)

    if not perspective_layer then
        return false
    else
        return perspective_layer
    end
end

function update_dialog_data(dialog, data)
    local new_data = dialog.data
    for k, v in pairs(data) do
        new_data[k] = v
    end
    dialog.data = new_data
end

function print_table(table)
    print("---")
    for k, v in pairs(table) do
        print(string.format("%s => %s", k, v))
    end
    print("---")
end

function table_to_string(table)
    local string = ""
    for k, v in pairs(table) do
        string = string .. string.format("%s=%s,", k, v)
    end
    return string
end

function string_to_table(string)
    local t = {}
    for k, v in string.gmatch(string, "([%w_]+)=([%w_ -]+)") do
        if v == "true" then v = true end
        if v == "false" then v = false end
        t[k] = v
    end
    
    return t
end

--Iterates through app.aciveImage looking for a pilot pixel.
--Returns the position of the pixel and executes an undo
--action if successful, otherwise returns false.
function find_pixel_position()
    if not is_pixel_present(app.activeImage, app.pixelColor.rgba(255,0,0)) then
        return false
    end

    local img_w = app.activeImage.width
    local img_h = app.activeImage.height
    local spr_w = app.activeSprite.width
    local spr_h = app.activeSprite.height

    --put two temporary pixels in the corners of the sprite to ensure
    --the size of image matches the sprite
    app.useTool{
        tool="pencil",
        points={Point{0,0}},
        color=app.pixelColor.rgba(0,0,0)
    }
    app.useTool{
        tool="pencil",
        points={Point{spr_w-1,spr_h-1}},
        color=app.pixelColor.rgba(0,0,0)
    }

    local point = nil
    
    for it in app.activeImage:pixels() do
        local pixel_value = it()
        if pixel_value == app.pixelColor.rgba(255,0,0) then

            --undo the two corner pixels placed before
            app.command.Undo()
            app.command.Undo()

            --undo the pilot pixel
            app.command.Undo()

            point = Point{it.x, it.y}
            break
        end
    end

    if point then
        return point
    else
        return false
    end
end

function throw_error(message)
    --print(string.format("ERROR: %s", message))
    app.alert{title="ERROR", text=message}
end

function can_draw_perspective_line()
    if not app.activeSprite then
        return false
    end

    if not find_layer(GUIDE_LAYER_NAME) then
        return false
    end

    return true
end

function clear_active_selection()
    local selection = Selection()
    selection:add(app.activeSprite.selection)
    if not selection.isEmpty then
        app.activeSprite.selection:deselect()
        return selection
    else
        return false
    end
end
