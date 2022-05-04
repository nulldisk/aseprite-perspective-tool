-----------------------------------------------------------------
-- Functions for manipulating preferences of the plugin object --
-----------------------------------------------------------------

function plugin_initialize_prefs(plugin)
    local required_prefs = {"storage_type", "storage_path"}

    for _, pref in ipairs(required_prefs) do
        if plugin.preferences[pref] == nil then
            plugin.preferences["storage_type"] = DEFAULT_STORAGE_TYPE
            plugin.preferences["storage_path"] = DEFAULT_STORAGE_PATH
            plugin.preferences["preview_auto_update"] = DEFAULT_PREVIEW_AUTO_UPDATE
            print("[Perspective Tool] Preferences initialized")
            break
        end
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
    plugin_update_global_prefs(plugin)
end

function plugin_update_global_prefs(plugin)
    for pref, value in pairs(plugin.preferences) do
        g_preferences[pref] = value
    end
end
