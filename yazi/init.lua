-- =============================================================================
-- Yazi Init - Plugin Configuration
-- =============================================================================
-- This file initializes yazi plugins and custom behavior

-- Git plugin: show git status in file listing
require("git"):setup()

-- Full border: adds nice borders around panes
require("full-border"):setup()

-- Starship prompt integration (if you have starship installed)
-- Uncomment if you want starship prompt in yazi header
-- require("starship"):setup()
