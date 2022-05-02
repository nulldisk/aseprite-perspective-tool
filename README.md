![logo](https://user-images.githubusercontent.com/22166897/166294587-f13ca78f-3a3b-4dc2-bba6-abeb71b8f03d.png)

![preview_1](https://user-images.githubusercontent.com/22166897/166328834-e3d8456d-61b4-45b4-9de5-97b601ebba62.gif)


Simple plugin for Aseprite providing an interactive perspective ruler. It can store different perspective configs for every project and draw perspective lines on a dedicated layer, precisely where you need them.

Because of Aseprite's API limitations, there are caveats to be aware of. Make sure to follow this readme if you want to use it.

## How does it work?
Before you can start drawing perspective lines you need to initialize perspective settings for your project. You can do this by opening the perspective settings dialog in `Edit > Perspective settings...`. This will initialize the settings to default values and create the `perspective-guide` layer. This layer is going to be used to draw all the perspective lines, so you probably want to put it on top of your layer stack and drop the opacity a bit. 

You may also notice the `perspective-preview` layer. This layer is created only when the perspective settings dialog is active. It is used to draw preview of your perspective when you are tweaking the settings and will be removed as soon as you close the dialog.

### Perspective settings dialog
The perspective settings dialog can be accessed in `Edit > Perspective settings...`. This is where you configure perspective values for your current project. It allows you to define the positions of horizon lines and positions of vanishing points on the horizon lines. You can tweak the values using the provided buttons or type them in manualy. There is also an option to bake the preview onto the `perspective-guide` layer if you want to use it to draw your lines manually.

Once you are done tweaking the values, you can close the dialog. Your settings should now be saved and you are ready to go. By default the `perspective-guide` layer is used to store the settings inside the `userdata` field – more on that later.

### Plugin settings dialog
The plugin settings dialog can be accessed in `Edit > Perspective helper settings...`. In this dialog you can tweak global settings for the plugin. These settings apply for every project. 

### Drawing perspective lines
![preview_2](https://user-images.githubusercontent.com/22166897/166330820-50d50407-293a-429a-b0c2-3ebab44a4d37.gif)

If your perspective is configured you can now start drawing perspective lines using the `Draw line from VPx` commands provided by the plugin. It may be a good idea to map them to some keyboard shortcuts for quick access.

Unfortunatelly, with current state of Aseprite's API, there is no way to access the mouse position, so we need to provide a reference for the position of where we want the line to end in a different way. To do so we are going to use a red (#FF0000) pilot pixel. The plugin is going to look for that pixel to figure out the needed coordinates and undo it automatically, so you can safely place it on top of whatever layer you are working on right now. The perspective line is going to be drawn on the `perspective-guide` layer.

### The perspective guide layer
The `perspective-guide` layer is just an ordinary layer the plugin uses to draw all the perspective lines on. If this layer doesn't exist the perspective line drawing commands will be inactive. You can move this layer wherever you want and configure its opacity and blending modes as you like. You can also erase or draw anything you want on it. If you accidentally remove the layer, you can create a new one with the exact same name or just open the perspective settings dialog and it will create new one automatically.

## Storage modes
The plugin offers two storage modes for perspective settings and neither of them is ideal. By default, layer mode is being used, but you can configure it in the plugin settings dialog.

### Layer mode
In layer mode settings are stored in the `userdata` field of the `perspective-guide` layer. It is a nice way to keep everything inside the project file, however modifying the `userdata` field counts as an undo action. This means, that every time you open the perspective settings dialog and change some settings it will update the `userdata` field and Aseprite will generate a new undo action.

This creates two problems: first, you can accidentally undo it and lose your new settings and second, you essentially lock yourself away from all your existing undo history, because undoing past this point will erase your new settings.

### File mode
In file mode settings are stored in external `.perspective` files. By default the files are created in the same directory as your project file, but this path can be configured in the plugin settings dialog. Saving data this way does not generate any undo actions, therefore your undo history stays untouched and available.

The downside to this method is that you now have to manage additional files on your disk, remember to update their names if you want to change the project name and remember to copy them over if you are moving your data.
