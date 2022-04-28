---------------------------------------------------------------------------------
-- Functions related to drawing and manipulating the perspective preview layer --
---------------------------------------------------------------------------------

-- Global variable for storing baked perspective pixel data.
oven = nil

function check_intersection(x1, y1, x2, y2, rect_xmin, rect_xmax, rect_ymin, rect_ymax)
    local t0 = 0
    local t1 = 1
    local dx = x2 - x1
    local dy = y2 - y1
    local p, q, r

    for i=1,4 do
        if i == 1 then
            p = -dx
            q = -(rect_xmin - x1)
        end

        if i == 2 then
            p = dx
            q = (rect_xmax - x1)
        end

        if i == 3 then
            p = -dy
            q = -(rect_ymin - y1)
        end

        if i == 4 then
            p = dy
            q = (rect_ymax - y1)
        end

        r = q/p

        if p == 0 and q < 0 then 
            return false -- don't draw anything
        end

        if p < 0 then
            if r > t1 then
                return false -- don't draw anything
            end
            
            if r > t0 then
                t0 = r -- line is clipped
            end
        end

        if p > 0 then
            if r < t0 then
                return false -- don't draw anything
            end

            if r < t1 then
                t1 = r -- line is clipped
            end
        end
    end

    local px1 = x1 + t0 * dx
    local py1 = y1 + t0 * dy
    local px2 = x1 + t1 * dx
    local py2 = y1 + t1 * dy

    return {px1, py1, px2, py2}

end

--Draws current perspective preview onto a preview layer
--using data from the provided dialog object.
--
--Setting "bake" to true causes the preview to be
--written onto the guide layer instead.
--
--Returns false if the target layer was not found.
function draw_preview(dialog, bake)
    local dialog_data = dialog.data
    local preview_layer = nil
    local preview_image = nil
    bake = bake or false
   
    if bake then
        preview_layer = find_layer(GUIDE_LAYER_NAME)
    else
        preview_layer = find_layer(PREVIEW_LAYER_NAME)
    end

    if preview_layer then
        app.activeLayer = preview_layer

        if app.activeSprite.selection then
            app.activeSprite.selection:deselect()
        end

        -- Make a brush stroke to make sure the image is initialized.
        app.useTool{
            tool="pencil",
            brush=horizon_brush,
            points={Point{0, 0}},
            color=horizon_color
        }

        app.useTool{
            tool="pencil",
            brush=horizon_brush,
            points={Point{app.activeSprite.width - 1, app.activeSprite.height - 1}},
            color=horizon_color
        }

        preview_image = app.activeImage

    else
        return false
    end
    
    if dialog_data["show_preview"] == true then
        local perspective_type = tonumber(string.sub(dialog_data["perspective_type"], 1, 1))
        local horizon_height = dialog_data["horizon_height"]
        local vhorizon_height = dialog_data["vertical_horizon_height"]
        local vp1_pos = dialog_data["vp1_pos"]
        local vp2_pos = dialog_data["vp2_pos"]
        local vp3_pos = dialog_data["vp3_pos"]
        local line_count = dialog_data["line_count"]
        local line_spread = dialog_data["line_spread"]
        local cel = app.activeCel
        local line_opacity = dialog_data["line_opacity"]
        local color_enabled = dialog_data["color"]

        if cel then
            cel.image:clear(app.pixelColor.rgba(0,0,0,1))
        end

        local vp_brush = Brush{
            type=BrushType.CIRCLE,
            size=3
        }

        local horizon_brush = Brush{
            type=BrushType.CIRCLE,
            size=1
        }

        local line_brush = Brush{
            type=BrushType.CIRCLE,
            size=1
        }

        local h_sprite_center = app.activeSprite.width/2
        local v_sprite_center = app.activeSprite.height/2
        
        local v_spread = {0 - line_spread, app.activeSprite.height + line_spread}
        local h_spread = {0 - line_spread, app.activeSprite.width + line_spread}
        local v_step = (math.abs(v_spread[1]) + math.abs(v_spread[2]))/line_count
        local h_step = (math.abs(h_spread[1]) + math.abs(h_spread[2]))/line_count

        local pc = app.pixelColor
        local vp1_line_color = pc.rgba(0,0,0,line_opacity)
        local vp2_line_color = pc.rgba(0,0,0,line_opacity)
        local vp3_line_color = pc.rgba(0,0,0,line_opacity)
        local horizon_color = pc.rgba(0,0,0,line_opacity)
        local vp1_point_color = pc.rgba(0,0,0,line_opacity)
        local vp2_point_color = pc.rgba(0,0,0,line_opacity)

        if color_enabled then
            vp1_line_color = pc.rgba(0,80,0,line_opacity)
            vp2_line_color = pc.rgba(0,0,80,line_opacity)
            vp3_line_color = pc.rgba(80,0,0,line_opacity)
            horizon_color = pc.rgba(200,0,200,line_opacity)
            vp1_point_color = pc.rgba(0,200,0,line_opacity)
            vp2_point_color = pc.rgba(0,0,200,line_opacity)
            vp3_point_color = pc.rgba(200,0,0,line_opacity)
        end

        for i = 0, line_count, 1 do

            -- Drawing VP1 --
            local x1 = vp1_pos
            local y1 = horizon_height

            local x2 = vhorizon_height
            local y2 = v_spread[1] + (v_step * i)

            local offset = math.abs(x1) + app.activeSprite.width
            local v_norm = math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
            local x2 = x2 + offset * (x2-x1)/v_norm
            local y2 = y2 + offset * (y2-y1)/v_norm

            local xs = check_intersection(x1, y1, x2, y2, 0, app.activeSprite.width, 0, app.activeSprite.height) 
            if xs then
                draw_line(preview_image, Point{xs[1], xs[2]}, Point{xs[3], xs[4]}, vp1_line_color)
            end

            -- Drawing VP2 --
            if perspective_type >= 2 then
                local x1 = vp2_pos
                local y1 = horizon_height

                local x2 = vhorizon_height
                local y2 = v_spread[1] + (v_step * i)

                local offset = math.abs(x1)
                local v_norm = math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
                local x2 = x2 + offset * (x2-x1)/v_norm
                local y2 = y2 + offset * (y2-y1)/v_norm

                local xs = check_intersection(x1, y1, x2, y2, 0, app.activeSprite.width, 0, app.activeSprite.height) 
                if xs then
                    draw_line(app.activeImage, Point{xs[1], xs[2]}, Point{xs[3], xs[4]}, vp2_line_color)
                end
            end

            -- Drawing VP3 --
            if perspective_type >= 3 then
                local x1 = vhorizon_height
                local y1 = vp3_pos

                local x2 = h_spread[1] + (h_step * i)
                local y2 = horizon_height

                local offset = app.activeSprite.height
                local v_norm = math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
                local x2 = x2 + offset * (x2-x1)/v_norm
                local y2 = y2 + offset * (y2-y1)/v_norm

                local xs = check_intersection(x1, y1, x2, y2, 0, app.activeSprite.width, 0, app.activeSprite.height) 
                if xs then
                    draw_line(app.activeImage, Point{xs[1], xs[2]}, Point{xs[3], xs[4]}, vp3_line_color)
                end
            end
        end

        --drawing the horizon line
        draw_line(preview_image,
                  Point{0, horizon_height},
                  Point{app.activeSprite.width, horizon_height},
                  horizon_color)

        if perspective_type >= 2 then
            draw_line(preview_image,
                      Point{vhorizon_height, 0},
                      Point{vhorizon_height, app.activeSprite.height},
                      horizon_color)
        end
        
        --drawing vanishing points on the horizon line
        draw_vanishing_point(preview_image, vp1_pos, horizon_height, vp1_point_color)

        if perspective_type >= 2 then
            draw_vanishing_point(preview_image, vp2_pos, horizon_height, vp2_point_color)
        end

        if perspective_type >= 3 then
            draw_vanishing_point(preview_image, vhorizon_height, vp3_pos, vp3_point_color)
        end
    end

    app.refresh()
end

--Redraws the perspective preview based on the provided dialog data.
function update_preview_layer(dialog, should_update)
    if should_update == nil then
        should_update = true
    end

    if should_update then
        local preview_layer = find_layer(PREVIEW_LAYER_NAME)
        if dialog.data["show_preview"] == true then
            if not preview_layer then
                local layer = app.activeSprite:newLayer()
                layer.name = PREVIEW_LAYER_NAME
            end
            dialog_validate_values(dialog)
            draw_preview(dialog)
            save_settings_to_layer(GUIDE_LAYER_NAME, dialog.data)
        else
            if preview_layer then
                app.activeSprite:deleteLayer(PREVIEW_LAYER_NAME)
            end
        end
        app.refresh()
    end
end

--Writes the current perspective preview onto a guide layer.
--Stores a copy of the image inside the 'oven' variable, so it
--can be retrieved later if the transaction gets undone.
function bake_preview()
    local guide_layer = find_layer(GUIDE_LAYER_NAME)
    if guide_layer then
        local preview_layer = find_layer(PREVIEW_LAYER_NAME)

        if preview_layer then
            app.activeLayer = preview_layer
            local preview_image = app.activeImage:clone()
            app.activeLayer = guide_layer
            
            --Making a brush stroke to make sure there is an active cel.
            app.useTool{
                tool="pencil",
                brush=horizon_brush,
                points={Point{0, 0}},
                color=app.pixelColor.rgba(0,0,0)
            }

            guide_layer.cels[1].image = preview_image
            app.activeLayer = guide_layer
            oven = app.activeImage:clone()
            app.refresh()
        end
    end
end

function reset_preview(dialog)
    local dialog_data = dialog.data
    dialog_data["perspective_type"] = "2 Vanishing Points"
    dialog_data["horizon_height"] = app.activeSprite.height/2
    dialog_data["vertical_horizon_height"] = app.activeSprite.width/2
    dialog_data["vp1_pos"] = app.activeSprite.width/8
    dialog_data["vp2_pos"] = app.activeSprite.width - app.activeSprite.width/8
    dialog_data["vp3_pos"] = app.activeSprite.height/8
    dialog_data["line_count"] = 10
    dialog_data["line_spread"] = 0
    dialog.data = dialog_data
    draw_preview(dialog)
    app.refresh()
end

function show_preview_layer(dialog)
    local dialog_data = dialog.data
    dialog_data["show_preview"] = true
    dialog.data = dialog_data
    update_preview_layer(dialog)
end

function hide_preview_layer(dialog)
    local data = dialog.data
    dialog_data["show_preview"] = false
    dialog.data = data
    update_preview_layer(dialog)
end
