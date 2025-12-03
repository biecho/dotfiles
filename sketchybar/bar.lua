local settings = require("config.settings")

sbar.bar({
  topmost = "window",
  height = settings.dimens.graphics.bar.height,
  color = settings.colors.bar.bg,
  padding_right = settings.dimens.padding.right,
  padding_left = settings.dimens.padding.left,
  margin = settings.dimens.padding.bar,
  corner_radius = settings.dimens.graphics.background.corner_radius,
  y_offset = settings.dimens.graphics.bar.offset,
  border_width = 0,
})
