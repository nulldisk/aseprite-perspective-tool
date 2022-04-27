-------------------------------------------------------------------------
-- Functions related to storing and loading perspective settings data  --
-------------------------------------------------------------------------

function save_settings_to_layer(layer_name, data)
    local layer = find_layer(layer_name)

    if not layer then
        return false
    end

    layer.data = table_to_string(data)
end

function load_settings_from_layer(layer)
    local layer = find_layer(layer)

    if not layer then
        return false
    end

    return string_to_table(layer.data)
end

function save_settings_to_file(path, data)
    local file = io.open(path, "w+")
    if not file then
        local message = "Can't write '%s'. " ..
                        "Make sure the specified directory exists " ..
                        "and you have write permissions."
        throw_error(string.format(message, path))
        return false
    end
    file:write(table_to_string(data))
    file:close()
end

function load_settings_from_file(path)
    if app.fs.isFile(path) then
        local file = io.open(path, "r")
        local data = string_to_table(file:read())
        file:close()
        return data
    else
        return nil
    end
end

function save_settings(data, storage_type, storage_path)
    if storage_type == "layer" then
        save_settings_to_layer(GUIDE_LAYER_NAME, data)
    else
        local name = app.fs.fileTitle(app.activeSprite.filename)
        local path = ""

        if storage_path == "" then
            path = app.fs.filePath(app.activeSprite.filename) .. app.fs.pathSeparator .. name .. ".perspective"
        else
            path = storage_path .. app.fs.pathSeparator .. name .. ".perspective"
        end

        save_settings_to_file(path, data)
    end
end

function load_settings(storage_type, storage_path)
    if storage_type == "layer" then
        return load_settings_from_layer(GUIDE_LAYER_NAME)
    else
        if not app.fs.isDirectory(storage_path) then
            return "DIR_NOT_FOUND"
        end
        local name = app.fs.fileTitle(app.activeSprite.filename)
        local path = ""

        if storage_path == "" then
            path = app.fs.filePath(app.activeSprite.filename) .. app.fs.pathSeparator .. name .. ".perspective"
        else
            path = storage_path .. app.fs.pathSeparator .. name .. ".perspective"
        end

        if not app.fs.isFile(path) then
            return "FILE_NOT_FOUND"
        else
            return load_settings_from_file(path)
        end
    end
end
