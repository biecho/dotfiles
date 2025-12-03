local settings = require("config.settings")

local apple = sbar.add("item", "apple", {
  icon = { string = settings.icons.text.apple },
  label = { drawing = false },
})

apple:subscribe("mouse.clicked", function(env)
  sbar.exec("open -a 'System Settings'")
end)
