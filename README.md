# Tabline

This plugin provides a simplistic interface for configuring the tabline.

With this plugin, the tabline is intended to act both as a tabline and as a
statusline. It can be configured to show all the required information, while
the statusline may be completely disabled.

![Screenshot_20230902_091118](https://github.com/lpoto/tabline.nvim/assets/67372390/f00c347a-28e3-4c1b-a1ad-cdc5348018bf)

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
