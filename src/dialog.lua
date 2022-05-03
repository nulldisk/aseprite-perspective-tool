--------------------------------------------
-- Functions for manipulating dialog data --
--------------------------------------------

function dialog_validate_values(dialog_data)
    local min_lines = MIN_PREVIEW_LINE_AMOUNT
    local max_lines = MAX_PREVIEW_LINE_AMOUNT
    local min_spread = MIN_PREVIEW_LINE_SPREAD
    local max_spread = MAX_PREVIEW_LINE_SPREAD
    local opacity_min = MIN_PREVIEW_OPACITY
    local opacity_max = MAX_PREVIEW_OPACITY

    local data = dialog_data.data

    data["line_count"] = clamp(data["line_count"], min_lines, max_lines)
    data["line_spread"] = clamp(data["line_spread"], min_spread, max_spread)
    data["line_opacity"] = clamp(data["line_opacity"], opacity_min, opacity_max)

    if data["vp1_pos"] > data["vertical_horizon_height"] then
        if data["perspective_type"] ~= "1 Vanishing Point" then
            data["vp1_pos"] = data["vertical_horizon_height"]
        end
    end

    if data["vp2_pos"] < data["vertical_horizon_height"] then
        data["vp2_pos"] = data["vertical_horizon_height"]
    end

    dialog_data.data = data
end

function dialog_increment_value(dialog_data, parameter, value)
    local data = dialog_data.data
    local current_value = data[parameter]
    local new_value = current_value + value

    data[parameter] = new_value
    dialog_data.data = data
    dialog_validate_values(dialog_data)
    draw_preview(dialog_data)
    save_settings_to_layer(GUIDE_LAYER_NAME, dialog_data.data)
end

function dialog_update_data(dialog, data)
    local new_data = dialog.data
    for k, v in pairs(data) do
        new_data[k] = v
    end
    dialog.data = new_data
end
