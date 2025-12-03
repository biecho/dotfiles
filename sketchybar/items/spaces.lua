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
  ["1"] = { icon = "1", name = "One" },
  ["2"] = { icon = "2", name = "Two" },
  ["3"] = { icon = "3", name = "Three" },
  ["4"] = { icon = "4", name = "Four" },
  ["5"] = { icon = "5", name = "Five" },
  ["6"] = { icon = "6", name = "Six" },
  ["7"] = { icon = "7", name = "Seven" },
  ["8"] = { icon = "8", name = "Eight" },
  ["9"] = { icon = "9", name = "Nine" },
}

local function selectCurrentWorkspace(focusedWorkspaceName)
  for sid, item in pairs(spaces) do
    if item ~= nil then
      local isSelected = sid == constants.items.SPACES .. "." .. focusedWorkspaceName
      item:set({
        icon = { color = isSelected and settings.colors.black or settings.colors.grey },
        label = { color = isSelected and settings.colors.black or settings.colors.grey },
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
