dofile("config.lua")
dofile("utils.lua")
dofile("dialog.lua")
dofile("preview.lua")
dofile("drawing.lua")
dofile("storage.lua")
dofile("preferences.lua")

function init(plugin)
    print("Initializing Perspective Helper v0.1")

    local config_dialog = Dialog{title="Perspective Helper"}
    local plugin_config_dialog = Dialog{title="Perspective Helper Settings"}
    local info_dialog = Dialog{title="Perspective Helper"}
    
    -- BEGIN Plugin Config Dialog ------------------------------------------------------------
    plugin_config_dialog:combobox
    {
        id="storage_type",
        label="Storage type",
        option="layer",
        options={"layer", "file"}
    }

    plugin_config_dialog:entry
    {
        id="storage_path",
        label="Storage path",
        text="",
        focus=false
    }

    plugin_config_dialog:check
    {
        id="preview_auto_update",
        label="Preview",
        text="Update preview automatically when fields are edited",
        selected=true
    }

    plugin_config_dialog:label
    {
        text="                                                    "
    }
    
    plugin_config_dialog:button
    {
        text="Ok",
        onclick=function() 
            plugin_update_prefs(plugin, plugin_config_dialog.data)
            plugin_config_dialog:close()
        end
    }
   
    plugin_config_dialog:button
    {
        text="Cancel"
    }
    -- END Plugin Config Dialog --------------------------------------------------------------

    -- BEGIN Info Dialog ---------------------------------------------------------------------
    info_dialog:label{text="                   "}
    info_dialog:newrow()
    info_dialog:label{id="message", text="info_message"}
    info_dialog:newrow()
    info_dialog:label{text="                   "}
    info_dialog:button{text="Ok"}
    -- END Info Dialog ------------------------------------------------------------------------

    -- BEGIN Perspective Settings Dialog ------------------------------------------------------
    config_dialog:separator{text="Perspective type"}

    config_dialog:combobox
    {
        id="perspective_type",
        option="1 Vanishing Point",
        options={"1 Vanishing Point", "2 Vanishing Points", "3 Vanishing Points"},
        onchange=function()
            update_preview_layer(config_dialog)
        end
    }

    config_dialog:separator{text="Horizon lines"}

    config_dialog:label{text="Horizontal"}
    config_dialog:label{text="Vertical"}

    config_dialog:number
    {
        id="horizon_height",
        text="0",
        decimals=integer,
        onchange=function() update_preview_layer(config_dialog, plugin.preferences["preview_auto_update"]) end
    }

    config_dialog:number
    {
        id="vertical_horizon_height",
        text="0",
        decimals=integer,
        onchange=function() update_preview_layer(config_dialog, plugin.preferences["preview_auto_update"]) end
    }

    -- Horizon controls --
    config_dialog:button
    {
        text="--",
        onclick=function() dialog_increment_value(config_dialog, "horizon_height",-10) end
    }

    config_dialog:button
    {
        text="-", 
        onclick=function() dialog_increment_value(config_dialog, "horizon_height", -1) end
    }

    config_dialog:button
    {
        text="+", 
        onclick=function() dialog_increment_value(config_dialog, "horizon_height", 1) end
    }

    config_dialog:button
    {
        text="++",
        onclick=function() dialog_increment_value(config_dialog, "horizon_height", 10) end
    }

    -- Vertical horizon controls --
    config_dialog:button
    {
        text="--",
        onclick=function() dialog_increment_value(config_dialog, "vertical_horizon_height",-10) end
    }

    config_dialog:button
    {
        text="-", 
        onclick=function() dialog_increment_value(config_dialog, "vertical_horizon_height", -1) end
    }

    config_dialog:button
    {
        text="+", 
        onclick=function() dialog_increment_value(config_dialog, "vertical_horizon_height", 1) end
    }

    config_dialog:button
    {
        text="++",
        onclick=function() dialog_increment_value(config_dialog, "vertical_horizon_height", 10) end
    }

    config_dialog:separator{text="Vanishing points"} ------------

    config_dialog:label{text="VP1"}
    config_dialog:label{text="VP2"}
    config_dialog:label{text="VP3"}
    
    config_dialog:number
    {
        id="vp1_pos", 
        text="0", 
        decimals=integer,
        onchange=function() update_preview_layer(config_dialog, plugin.preferences["preview_auto_update"]) end
    }

    config_dialog:number
    {
        id="vp2_pos", 
        text="0", 
        decimals=integer,
        onchange=function() update_preview_layer(config_dialog, plugin.preferences["preview_auto_update"]) end
    }
   
    config_dialog:number
    {
        id="vp3_pos", 
        text="0", 
        decimals=integer,
        onchange=function() update_preview_layer(config_dialog, plugin.preferences["preview_auto_update"]) end
    }

    -- VP1 Controls--
    config_dialog:button
    {
        text="--", 
        onclick=function() dialog_increment_value(config_dialog, "vp1_pos", -10) end
    }

    config_dialog:button
    {
        text="-", 
        onclick=function() dialog_increment_value(config_dialog, "vp1_pos", -1) end
    }

    config_dialog:button
    {
        text="+", 
        onclick=function() dialog_increment_value(config_dialog, "vp1_pos", 1) end
    }

    config_dialog:button
    {
        text="++", 
        onclick=function() dialog_increment_value(config_dialog, "vp1_pos", 10) end
    }

    -- VP2 Controls --
    config_dialog:button
    {
        text="--", 
        onclick=function() dialog_increment_value(config_dialog, "vp2_pos", -10) end
    }

    config_dialog:button
    {
        text="-", 
        onclick=function() dialog_increment_value(config_dialog, "vp2_pos", -1) end
    }
    
    config_dialog:button
    {
        text="+", 
        onclick=function() dialog_increment_value(config_dialog, "vp2_pos", 1) end
    }
    
    config_dialog:button
    {
        text="++", 
        onclick=function() dialog_increment_value(config_dialog, "vp2_pos", 10) end
    }

    -- VP3 Controls --
    config_dialog:button
    {
        text="--", 
        onclick=function() dialog_increment_value(config_dialog, "vp3_pos", -10) end
    }

    config_dialog:button
    {
        text="-", 
        onclick=function() dialog_increment_value(config_dialog, "vp3_pos", -1) end
    }
    
    config_dialog:button
    {
        text="+", 
        onclick=function() dialog_increment_value(config_dialog, "vp3_pos", 1) end
    }
    
    config_dialog:button
    {
        text="++", 
        onclick=function() dialog_increment_value(config_dialog, "vp3_pos", 10) end
    }

    config_dialog:separator{text="Perspective lines"} ----------

    config_dialog:label{text="Amount"}
    config_dialog:label{text="Spread"}

    config_dialog:number
    {
        id="line_count", 
        text="10", 
        decimals=integer,
        onchange=function() update_preview_layer(config_dialog, plugin.preferences["preview_auto_update"]) end
    }

    config_dialog:number
    {
        id="line_spread", 
        text="0", 
        decimals=integer,
        onchange=function() update_preview_layer(config_dialog, plugin.preferences["preview_auto_update"]) end
    }

    -- Line Count Controls --
    config_dialog:button
    {
        text="--", 
        onclick=function() dialog_increment_value(config_dialog, "line_count", -10) end
    }

    config_dialog:button
    {
        text="-", 
        onclick=function() dialog_increment_value(config_dialog, "line_count", -1) end
    }

    config_dialog:button
    {
        text="+", 
        onclick=function() dialog_increment_value(config_dialog, "line_count", 1) end
    }

    config_dialog:button
    {
        text="++", 
        onclick=function() dialog_increment_value(config_dialog, "line_count", 10) end
    }

    -- Line Spread Controls --
    config_dialog:button
    {
        text="--", 
        onclick=function() dialog_increment_value(config_dialog, "line_spread", -10) end
    }

    config_dialog:button
    {
        text="-", 
        onclick=function() dialog_increment_value(config_dialog, "line_spread", -1) end
    }

    config_dialog:button
    {
        text="+", 
        onclick=function() dialog_increment_value(config_dialog, "line_spread", 1) end
    }

    config_dialog:button
    {
        text="++", 
        onclick=function() dialog_increment_value(config_dialog, "line_spread", 10) end
    }

    config_dialog:separator{text="Preview"} --------------------

    config_dialog:label
    {
        text="Opacity"
    }

    config_dialog:number
    {
        id="line_opacity", 
        text="255", 
        decimals=integer,
        onchange=function() update_preview_layer(config_dialog, plugin.preferences["preview_auto_update"]) end
    }

    config_dialog:check
    {
        id="color", 
        text="Color", 
        selected=false, 
        onclick=function()
            update_preview_layer(config_dialog)
        end
    }

    config_dialog:check
    {
        id="show_preview", 
        text="Show preview", 
        selected=false, 
        onclick=function()
            update_preview_layer(config_dialog)
        end
    }

    config_dialog:button
    {
        text="Update Preview", 
        onclick=function()
            update_preview_layer(config_dialog)
        end
    }

    config_dialog:button
    {
        text="Reset", 
        onclick=function()
            reset_preview(config_dialog)
        end
    }

    config_dialog:newrow()

    config_dialog:button
    {
        text="Bake Preview", 
        onclick=bake_preview
    }

    -- END Perspective Settings Dialog -------------------------------------------------------

    plugin:newCommand{
        id="DrawLineV1",
        title="Draw line from V1",
        group="edit_new",
        onclick=function()
            local storage_type = plugin.preferences["storage_type"]
            local storage_path = plugin.preferences["storage_path"]
            local settings = load_settings(storage_type, storage_path)
            draw_perspective_line(settings["vp1_pos"], settings["horizon_height"])
        end,
        onenabled=function()
            return can_draw_perspective_line()
        end
    }

    plugin:newCommand{
        id="DrawLineV2",
        title="Draw line from V2",
        group="edit_new",
        onclick=function()
            local storage_type = plugin.preferences["storage_type"]
            local storage_path = plugin.preferences["storage_path"]
            local settings = load_settings(storage_type, storage_path)
            draw_perspective_line(settings["vp2_pos"], settings["horizon_height"])
        end,
        onenabled=function()
            return can_draw_perspective_line()
        end
    }

    plugin:newCommand{
        id="DrawLineV3",
        title="Draw line from V3",
        group="edit_new",
        onclick=function()
            local storage_type = plugin.preferences["storage_type"]
            local storage_path = plugin.preferences["storage_path"]
            local settings = load_settings(storage_type, storage_path)
            draw_perspective_line(settings["vertical_horizon_height"], settings["vp3_pos"])
        end,
        onenabled=function()
            return can_draw_perspective_line()
        end
    }

    plugin:newCommand{
        id="DrawLineAll",
        title="Draw lines from vanishing points",
        group="edit_new",
        onclick=function()
            local storage_type = plugin.preferences["storage_type"]
            local storage_path = plugin.preferences["storage_path"]
            local settings = load_settings(storage_type, storage_path)

            local points = {
                {settings["vp1_pos"], settings["horizon_height"]},
                {settings["vp2_pos"], settings["horizon_height"]}
            }

            draw_perspective_lines(points)
        end,
        onenabled=function()
            return can_draw_perspective_line()
        end
    }

    plugin:newCommand{
        id="PerspectiveConfig",
        title="Configure Perspective...",
        group="edit_new",
        onclick=function()
            local storage_type = plugin.preferences["storage_type"]
            local storage_path = plugin.preferences["storage_path"]

            if storage_type == "file" then
                if not app.fs.isFile(app.activeSprite.filename) then
                    local message = "Your perspective data storage is set to 'file' mode " ..
                                    "but the project doesn't have a file.\nPlease save " ..
                                    "the project and give it a name before editing " ..
                                    "perspective settings."
                    show_popup(message)
                    return false
                end

                local perspective_settings = load_settings(storage_type, storage_path)

                if perspective_settings == "FILE_NOT_FOUND" then
                    reset_preview(config_dialog)
                    save_settings(config_dialog.data, storage_type, storage_path)
                end

                if perspective_settings == "DIR_NOT_FOUND" then
                    local message = "'%s' directory doesn't exist."
                    show_popup(string.format(message, storage_path))
                    return false
                end
            end

            local guide_layer = find_layer(GUIDE_LAYER_NAME)
            if not guide_layer then
                app.transaction(
                    function ()
                        -- For safety measures, we run any transaction code inside a pcall.
                        -- If Lua throws an error inside of a transaction, Aseprite has no
                        -- idea what to do, causing undefined behavior and permanently
                        -- breaking itself, eventually resulting in a SEGFAULT.
                        local status, err = pcall(function()
                            local layer = app.activeSprite:newLayer()
                            layer.name = GUIDE_LAYER_NAME
                            reset_preview(config_dialog)
                            save_settings_to_layer(GUIDE_LAYER_NAME, config_dialog.data)
                        end)

                        if status == false then
                            print(err)
                        end
                    end
                )
            end

            local removed_selection = clear_active_selection()

            -- Load perspective settings and show the perspective config dialog
            -- inside a transaction.
            app.transaction(
                function ()
                    local status, err = pcall(function()
                        local storage_type = plugin.preferences["storage_type"]
                        local storage_path = plugin.preferences["storage_path"]

                        oven = nil

                        local perspective_settings = load_settings(storage_type, storage_path)

                        if not perspective_settings then
                            show_popup("Couldn't load perspective settings")
                            return
                        end

                        local dialog_data = config_dialog.data

                        for k, v in pairs(perspective_settings) do
                            dialog_data[k] = v
                        end

                        config_dialog.data = dialog_data

                        show_preview_layer(config_dialog)
                        config_dialog:show()
                    end)
                    if status == false then
                        print(err)
                    end
                end
            )

            app.undo() -- Undo the transaction to get rid of the preview layer.
            save_settings(config_dialog.data, storage_type, storage_path)
            app.refresh()

            -- If something has been put into the oven, take it out and put it
            -- onto the guide layer.
            if oven then
                app.transaction(
                    function()
                        local status, err = pcall(function()
                            local guide_layer = find_layer(GUIDE_LAYER_NAME)
                            app.activeLayer = guide_layer
                            app.useTool{
                                tool="pencil",
                                points={Point{0,0}} }
                            guide_layer:cel(1).image = oven
                        end)

                        if status == false then
                            print(err)
                        end
                    end)
            end

            if removed_selection then
                app.activeSprite.selection = removed_selection
            end
        end,
        onenabled=function()
            if not app.activeSprite then
                return false
            else
                return true
            end
        end
    }

    plugin:newCommand{
        id="PluginSettings",
        title="Perspective plugin settings...",
        group="edit_new",
        onclick=function()
            plugin_initialize_prefs(plugin)
            dialog_update_data(plugin_config_dialog, plugin.preferences)
            plugin_config_dialog:show()
        end,
        onenabled=function()
            return true
        end
    }

end
