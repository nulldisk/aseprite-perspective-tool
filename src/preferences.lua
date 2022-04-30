-----------------------------------------------------------------
-- Functions for manipulating preferences of the plugin object --
-----------------------------------------------------------------

function plugin_initialize_prefs(plugin)
    if not plugin.preferences["storage_type"] then
        plugin.preferences["storage_type"] = "layer"
    end
    
    if not plugin.preferences["storage_path"] then
        plugin.preferences["storage_path"] = ""
    end
end

function plugin_save_pref(plugin, pref, value)
    if pref == "storage_type" then
        allowed_values = {"file", "layer"}
        if table.contains(allowed_values, value) then
            plugin.preferences[pref] = value
        else
            local message = "Illegal value '%s' provided for pref '%s'"
            show_popup(string.format(message, value, pref))
        end
    elseif pref == "storage_path" then
        if app.fs.isDirectory(value) then
            temp_dir = value .. app.fs.pathSeparator .. "perspective-settings"
            if app.fs.makeDirectory(temp_dir) then
                app.fs.removeDirectory(temp_dir)
                plugin.preferences[pref] = value
            else
                local message = "Illegal value '%s' provided for pref '%s' (directory is not writable)"
                show_popup(string.format(message, value, pref))
            end
        else
            if value == "" then
                plugin.preferences[pref] = value
            else
                local message = "Illegal value '%s' provided for pref '%s' (path doesn't exist)"
                show_popup(string.format(message, value, pref))
            end
        end
    elseif pref == "preview_auto_update" then
        plugin.preferences[pref] = value
    else
        show_popup("Attempted to set an unknown pref '" .. pref .. "'")
    end
end

function plugin_update_prefs(plugin, prefs)
    for pref, value in pairs(prefs) do
        if plugin.preferences[pref] ~= value then
            plugin_save_pref(plugin, pref, value)
        end
    end
end

