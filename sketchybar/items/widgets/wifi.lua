local constants = require("constants")
local settings = require("config.settings")

-- Start network monitor
sbar.exec(
  "killall network_load >/dev/null; $CONFIG_DIR/bridge/network_load/bin/network_load en0 network_update 2.0"
)

-- Upload speed (stacked with download)
local wifiUp = sbar.add("item", "wifi.up", {
  position = "right",
  width = 0,
  icon = {
    padding_left = 0,
    padding_right = 0,
    font = {
      style = settings.fonts.styles.bold,
      size = 10.0,
    },
    string = settings.icons.text.wifi.upload,
  },
  label = {
    font = {
      family = settings.fonts.numbers,
      style = settings.fonts.styles.bold,
      size = 10.0,
    },
    color = settings.colors.orange,
    string = "??? Bps",
  },
  y_offset = 4,
})

-- Download speed
local wifiDown = sbar.add("item", "wifi.down", {
  position = "right",
  icon = {
    padding_left = 0,
    padding_right = 0,
    font = {
      style = settings.fonts.styles.bold,
      size = 10.0,
    },
    string = settings.icons.text.wifi.download,
  },
  label = {
    font = {
      family = settings.fonts.numbers,
      style = settings.fonts.styles.bold,
      size = 10.0,
    },
    color = settings.colors.blue,
    string = "??? Bps",
  },
  y_offset = -4,
})

-- Wifi icon with padding
local wifi = sbar.add("item", "wifi.icon", {
  position = "right",
  label = { drawing = false },
  padding_right = 0,
})

sbar.add("item", { position = "right", width = settings.dimens.padding.item })

wifiUp:subscribe("network_update", function(env)
  local upColor = (env.upload == "000 Bps") and settings.colors.grey or settings.colors.orange
  local downColor = (env.download == "000 Bps") and settings.colors.grey or settings.colors.blue

  wifiUp:set({
    icon = { color = upColor },
    label = {
      string = env.upload,
      color = upColor
    }
  })
  wifiDown:set({
    icon = { color = downColor },
    label = {
      string = env.download,
      color = downColor
    }
  })
end)

wifi:subscribe({ "wifi_change", "system_woke", "forced" }, function(env)
  sbar.exec([[ipconfig getifaddr en0]], function(ip)
    local connected = not (ip == "")
    wifi:set({
      icon = {
        string = connected and settings.icons.text.wifi.connected or settings.icons.text.wifi.disconnected,
        color = connected and settings.colors.white or settings.colors.red,
      }
    })
  end)
end)
