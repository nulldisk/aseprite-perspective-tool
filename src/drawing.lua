function draw_vanishing_point(image, pos_x, pos_y, color)
    image:drawPixel(pos_x-1, pos_y, color)
    image:drawPixel(pos_x, pos_y, color)
    image:drawPixel(pos_x+1, pos_y, color)
    image:drawPixel(pos_x, pos_y-1, color)
    image:drawPixel(pos_x, pos_y+1, color)
end

function draw_perspective_line(vp_pos, horizon_height, pilot_pos)
    local target_layer = find_layer(GUIDE_LAYER_NAME)
    pilot_pos = pilot_pos or find_pixel_position()

    if target_layer then
        local line_color = app.pixelColor.rgba(0,0,0)

        if pilot_pos then
            local vp_point = Point{vp_pos, horizon_height}

            local removed_selection = clear_active_selection()

            app.useTool{
                tool="pencil",
                points={pilot_pos, vp_point},
                color=line_color,
                layer=target_layer
            }

        end
    end
end

function draw_perspective_lines(points)
    local pilot_pos = find_pixel_position()

    if pilot_pos then
        app.transaction(
            function()
                for _, point in ipairs(points) do
                    draw_perspective_line(point[1], point[2], pilot_pos)
                end
            end
        )
    end
end

--Line code based on Alois Zingl work released under the
--MIT license http://members.chello.at/easyfilter/bresenham.html
function draw_line(image, a_pos, b_pos, color)
    local a = Point(a_pos.x, a_pos.y)
    local b = Point(b_pos.x, b_pos.y)
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
