return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                -- basedpyright defaults to "recommended" (all rules on),
                -- which is too noisy; "standard" matches pyright's defaults.
                typeCheckingMode = "standard",
              },
            },
          },
        },
      },
    },
  },
}
