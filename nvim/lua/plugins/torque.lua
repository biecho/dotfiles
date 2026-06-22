-- V8 Torque (.tq) syntax + filetype detection.
-- Ships inside the V8 checkout; loaded as a local plugin.
local torque_dir = vim.fn.expand("~/v8/tools/torque/vim-torque")

if vim.fn.isdirectory(torque_dir) == 0 then
  return {}
end

return {
  {
    dir = torque_dir,
    name = "vim-torque",
    ft = "torque",
    init = function()
      vim.filetype.add({ extension = { tq = "torque" } })
    end,
  },
}
