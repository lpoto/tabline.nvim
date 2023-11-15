# Tabline

This plugin provides a simplistic interface for configuring the tabline.

With this plugin, the tabline is intended to act both as a tabline and as a
statusline. It can be configured to show all the required information, while
the statusline may be completely disabled.

![image](https://github.com/lpoto/tabline.nvim/assets/67372390/c01465d0-b72d-47da-8292-14f74f846536)

### Setup

An example using [Lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
require("tabline").setup({
  "lpoto/tabline.nvim",
  event = { 'BufRead', 'BufNewFile', 'BufNew' },
  opts = {}
})
```

###

See [config](./lua/tabline/config.lua) for the default configuration.
