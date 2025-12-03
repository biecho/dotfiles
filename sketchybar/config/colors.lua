-- Cyberdream color scheme for SketchyBar
-- https://github.com/scottmckendry/cyberdream.nvim
local colors <const> = {
  -- Base colors
  black = 0xff16181a,
  white = 0xffffffff,
  grey = 0xff3c4048,

  -- Accent colors
  cyan = 0xff5ef1ff,
  green = 0xff5eff6c,
  yellow = 0xfff1ff5e,
  blue = 0xff5ea1ff,
  magenta = 0xffbd5eff,
  red = 0xffff6e5e,
  orange = 0xffffbd5e,
  pink = 0xffff5ef1,

  -- UI colors
  bg1 = 0xff16181a,      -- Main background
  bg2 = 0xff1e2124,      -- Slightly lighter
  bg3 = 0xff3c4048,      -- Grey for inactive

  transparent = 0x00000000,

  bar = {
    bg = 0xe016181a,     -- Semi-transparent dark (Cyberdream bg with ~88% opacity)
    border = 0xff3c4048,
  },
  popup = {
    bg = 0xf016181a,
    border = 0xff3c4048,
  },

  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then return color end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}

return colors
