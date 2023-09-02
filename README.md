# Tabline

This plugin provides a simplistic interface for configuring the tabline.

With this plugin, the tabline is intended to act both as a tabline and as a
statusline. It can be configured to show all the required information, while
the statusline may be completely disabled.


### Setup

An example using [Lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
require("tabline").setup({
  "lpoto/tabline.nvim",
  event = "VeryLazy",
  config = true,
})
```

###

See [config](./lua/tabline/config.lua) for the default configuration.
