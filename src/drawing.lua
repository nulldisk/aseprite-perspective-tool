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

function draw_vp_line(image, p1, p2, color)
    local canvas_w = app.activeSprite.width
    local canvas_h = app.activeSprite.height
    local canvas_center = Point(canvas_w/2, canvas_h/2)
    local length = line_length(p1, p2)
    local offset = diagonal_length - length
    local v_norm = line_length(p1, p2)

    local diagonal_length = 0
    if p1.x <= canvas_center.x and p1.y <= canvas_center.y then
        diagonal_length = line_length(p1, Point(canvas_w, canvas_h))
    end

    if p1.x <= canvas_center.x and p1.y >= canvas_center.y then
        diagonal_length = line_length(p1, Point(canvas_w, 0))
    end

    if p1.x >= canvas_center.x and p1.y >= canvas_center.y then
        diagonal_length = line_length(p1, Point(0, 0))
    end

    if p1.x >= canvas_center.x and p1.y <= canvas_center.y then
        diagonal_length = line_length(p1, Point(0, canvas_h))
    end

    -- Making sure all lines are long enough to cover the whole canvas
    p2.x = p2.x + offset * (p2.x - p1.x)/v_norm
    p2.y = p2.y + offset * (p2.y - p1.y)/v_norm

    local rect = {0, 0, app.activeSprite.width, app.activeSprite.height}
    local xs = check_intersection(p1, p2, rect) 
    if xs then
        draw_line(image, Point{xs[1], xs[2]}, Point{xs[3], xs[4]}, color)
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
