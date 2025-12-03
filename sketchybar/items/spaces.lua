local constants = require("constants")
local settings = require("config.settings")

local spaces = {}

local currentWorkspaceWatcher = sbar.add("item", {
  drawing = false,
  updates = true,
})

-- Workspace icons - customize these for your workflow
-- Icons from Nerd Fonts: https://www.nerdfonts.com/cheat-sheet
local spaceConfigs <const> = {
  ["1"] = { icon = "", name = "Terminal" },     -- Kitty
  ["2"] = { icon = "", name = "Code" },         -- Editor/IDE
  ["3"] = { icon = "󰖟", name = "Browser" },      -- Web
  ["4"] = { icon = "󰊻", name = "Chat" },         -- Communication
  ["5"] = { icon = "󱞁", name = "Notes" },        -- Obsidian/Notes
  ["6"] = { icon = "", name = "Database" },     -- DB tools
  ["7"] = { icon = "", name = "Music" },        -- Spotify
  ["8"] = { icon = "", name = "Mail" },         -- Outlook
  ["9"] = { icon = "", name = "Misc" },         -- Miscellaneous
}

local function selectCurrentWorkspace(focusedWorkspaceName)
  for sid, item in pairs(spaces) do
    if item ~= nil then
      local isSelected = sid == constants.items.SPACES .. "." .. focusedWorkspaceName
      item:set({
        icon = { color = isSelected and settings.colors.bg1 or settings.colors.white },
        label = { color = isSelected and settings.colors.bg1 or settings.colors.white },
        background = { color = isSelected and settings.colors.cyan or settings.colors.bg1 },
      })
    end
  end

  sbar.trigger(constants.events.UPDATE_WINDOWS)
end

local function findAndSelectCurrentWorkspace()
  sbar.exec(constants.aerospace.GET_CURRENT_WORKSPACE, function(focusedWorkspaceOutput)
    local focusedWorkspaceName = focusedWorkspaceOutput:match("[^\r\n]+")
    selectCurrentWorkspace(focusedWorkspaceName)
  end)
end

local function addWorkspaceItem(workspaceName)
  local spaceName = constants.items.SPACES .. "." .. workspaceName
  local spaceConfig = spaceConfigs[workspaceName]

  if not spaceConfig then
    spaceConfig = { icon = workspaceName, name = "Workspace " .. workspaceName }
  end

  spaces[spaceName] = sbar.add("item", spaceName, {
    label = {
      width = 0,
      padding_left = 0,
      string = spaceConfig.name,
    },
    icon = {
      string = spaceConfig.icon,
      color = settings.colors.white,
    },
    background = {
      color = settings.colors.bg1,
    },
    click_script = "aerospace workspace " .. workspaceName,
  })

  spaces[spaceName]:subscribe("mouse.entered", function(env)
    sbar.animate("tanh", 30, function()
      spaces[spaceName]:set({ label = { width = "dynamic" } })
    end)
  end)

  spaces[spaceName]:subscribe("mouse.exited", function(env)
    sbar.animate("tanh", 30, function()
      spaces[spaceName]:set({ label = { width = 0 } })
    end)
  end)

  sbar.add("item", spaceName .. ".padding", {
    width = settings.dimens.padding.label
  })
end

local function createWorkspaces()
  sbar.exec(constants.aerospace.LIST_ALL_WORKSPACES, function(workspacesOutput)
    for workspaceName in workspacesOutput:gmatch("[^\r\n]+") do
      addWorkspaceItem(workspaceName)
    end

    findAndSelectCurrentWorkspace()
  end)
end

currentWorkspaceWatcher:subscribe(constants.events.AEROSPACE_WORKSPACE_CHANGED, function(env)
  selectCurrentWorkspace(env.FOCUSED_WORKSPACE)
  sbar.trigger(constants.events.UPDATE_WINDOWS)
end)

createWorkspaces()
