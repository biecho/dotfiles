-- Image display in nvim using Kitty graphics protocol
return {
  "3rd/image.nvim",
  ft = { "markdown", "norg", "oil" },
  opts = {
    backend = "kitty",
    integrations = {
      markdown = {
        enabled = true,
        clear_in_insert_mode = true,
        only_render_image_at_cursor = true,
      },
    },
    max_width = 100,
    max_height = 20,
    max_height_window_percentage = 40,
  },
}
