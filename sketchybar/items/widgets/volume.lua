local constants = require("constants")
local settings = require("config.settings")

local volume = sbar.add("item", "widgets.volume", {
  position = "right",
  icon = {
    string = settings.icons.text.volume._66,
  },
  label = {
    string = "??%",
    padding_left = 0,
  },
  update_freq = 5,
})

local function updateVolume(vol)
  local icon = settings.icons.text.volume._0
  local color = settings.colors.grey

  if vol > 60 then
    icon = settings.icons.text.volume._100
    color = settings.colors.white
  elseif vol > 30 then
    icon = settings.icons.text.volume._66
    color = settings.colors.white
  elseif vol > 10 then
    icon = settings.icons.text.volume._33
    color = settings.colors.yellow
  elseif vol > 0 then
    icon = settings.icons.text.volume._10
    color = settings.colors.orange
  end

  local lead = ""
  if vol < 10 then
    lead = "0"
  end

  volume:set({
    icon = { string = icon },
    label = {
      string = lead .. vol .. "%",
    },
  })
end

volume:subscribe("volume_change", function(env)
  updateVolume(tonumber(env.INFO) or 0)
end)

volume:subscribe({ "routine", "forced" }, function(env)
  sbar.exec("osascript -e 'output volume of (get volume settings)'", function(vol)
    updateVolume(tonumber(vol) or 0)
  end)
end)

volume:subscribe("mouse.clicked", function(env)
  sbar.exec("open /System/Library/PreferencePanes/Sound.prefPane")
end)
