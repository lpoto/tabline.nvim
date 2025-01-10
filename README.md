# Tabline

![image](https://github.com/lpoto/tabline.nvim/assets/67372390/c01465d0-b72d-47da-8292-14f74f846536)
> _NOTE_: The tabline is completely configurable

### Requirements

- [Neovim](https://neovim.io) v0.9.0+

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

See [config](./lua/tabline/config/default.lua) for the default configuration.
