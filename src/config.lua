------------------------
-- Configuration file --
------------------------

-- Version number displayed in logs and plugin settings dialog
PLUGIN_VERSION = "v.0.2-dev"

-- Temporary layer for drawing perspective preview when the dialog is open.
PREVIEW_LAYER_NAME = "perspective-preview"

-- Permanent layer for drawing the guides and storing perspective settings in the project.
GUIDE_LAYER_NAME   = "perspective-guide"

-- Allowed value ranges for the perspective settings dialog.
MIN_PREVIEW_LINE_AMOUNT = 1
MAX_PREVIEW_LINE_AMOUNT = 100
MIN_PREVIEW_LINE_SPREAD = 0
MAX_PREVIEW_LINE_SPREAD = 1000
MIN_PREVIEW_OPACITY = 0
MAX_PREVIEW_OPACITY = 255

-- Default plugin preferences
DEFAULT_STORAGE_TYPE = "layer"
DEFAULT_STORAGE_PATH = ""
DEFAULT_PREVIEW_AUTO_UPDATE = false
