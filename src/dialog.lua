function dialog_validate_values(dialog_data)
    local min_lines = 1
    local max_lines = 100
    local min_spread = 0
    local max_spread = 1000
    local opacity_max = 255
    local opacity_min = 0

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

function dialog_show_info_dialog(dialog, message)
    local dialog_data = dialog.data
    dialog_data["message"] = message
    dialog.data = data
    dialog:show()
end
