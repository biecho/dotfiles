-- Image display in nvim using Kitty graphics protocol
-- Enhanced for Jupyter notebook outputs via molten-nvim
return {
  "3rd/image.nvim",
  lazy = false, -- Load early for molten-nvim integration
  build = false, -- Disable luarocks build (use system magick)
  opts = {
    backend = "kitty",
    processor = "magick_cli", -- Use ImageMagick CLI (more stable than luarocks)
    integrations = {
      markdown = {
        enabled = true,
        clear_in_insert_mode = true,
        download_remote_images = true,
        only_render_image_at_cursor = false, -- Show all images (better for notebooks)
        filetypes = { "markdown", "quarto", "vimwiki" },
      },
      neorg = {
        enabled = true,
        filetypes = { "norg" },
      },
    },
    -- Larger dimensions for notebook outputs (plots, charts)
    max_width = 100,
    max_height = 40,
    max_height_window_percentage = 50,
    max_width_window_percentage = 80,
    -- Behavior
    window_overlap_clear_enabled = true, -- Clear images when windows overlap
    window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    editor_only_render_when_focused = true, -- Only render when editor has focus
    hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.svg" },
  },
}
