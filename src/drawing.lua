function draw_vanishing_point(image, pos_x, pos_y, color)
    image:drawPixel(pos_x-1, pos_y, color)
    image:drawPixel(pos_x, pos_y, color)
    image:drawPixel(pos_x+1, pos_y, color)
    image:drawPixel(pos_x, pos_y-1, color)
    image:drawPixel(pos_x, pos_y+1, color)
end

function draw_perspective_line(vp_pos, pilot_pos, color)
    local target_layer = find_layer(GUIDE_LAYER_NAME)

    if not target_layer then
        print("no layer found")
        --TODO: add a dialog asking to create a guide layer if it doesn't exist
        return false
    end

    app.useTool{
        tool="pencil",
        points={pilot_pos, vp_pos},
        color=color,
        layer=target_layer
    }
    
end

--Line code based on Alois Zingl work released under the
--MIT license http://members.chello.at/easyfilter/bresenham.html
function draw_line(image, a_pos, b_pos, color)
    local a = a_pos
    local b = b_pos
    local dx = math.abs(b.x-a.x)
    local sx = 0
    local sy = 0

    if a.x < b.x then
        sx = 1
    else
        sx = -1
    end

    local dy = -math.abs(b.y-a.y)
    if a.y < b.y then
        sy = 1
    else
        sy = -1
    end

    local err = dx + dy
    local e2 = 0

    while true do

        image:drawPixel(a.x, a.y, color)

        local e2 = 2 * err;
        if e2 >= dy then
            if a.x == b.x then
                break
            end
            err = err + dy
            a.x = a.x + sx
        end

        if e2 <= dx then
            if a.y == b.y then
                break
            end

            err = err + dx
            a.y = a.y + sy
        end
    end
end
