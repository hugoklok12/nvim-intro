# minintro.nvim
Replacer for default Intro of neovim

## Motivation
Neovim intro screen can be extremely buggy and forced to close automatically by plugins installed such as
[nvim-tree](https://github.com/nvim-tree/nvim-tree.lua),
[bufferline](https://github.com/akinsho/bufferline.nvim),
[lualine](https://github.com/nvim-lualine/lualine.nvim) and many more.
`minintro.nvim` hijects `no-name` and `directory` buffer and draws a simple intro logo.
I tried to emulate the function of the original Intro as much as I could. If
you have any improvements feel free to make a pull request.
Thanks to the [original author](https://github.com/eoh-bse/minintro.nvim)
for making most of the plugin.

## Screenshot
![minintro-screenshot](screenshots/Minintro.png)

## Installation
```lua
-- Lazy
{
    "Yoolayn/minintro.nvim",
    config = true,
    lazy = false
}
```

```lua
-- Packer
use {
    "Yoolayn/minintro.nvim",
    config = function() require("minintro").setup() end
}
```

## Configuration
You can customize the intro logo(adding your own will overwrite the default one).
It is possible to change it's color, make a scratch buffer appear at the start
instead of a regular one and you can set custom highlights using matched to
highlight parts of the logo.
Please keep all the lines in the intro option the same length, as it may cause unexpected results.

minintro comes with these defaults:
```lua
-- Lazy
{
    "Yoolayn/minintro.nvim",
    opts = {
        intro = {
            " ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
            " ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
            " ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
            " ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
            " ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
            " ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
        },
        color = "#98c379",
        scratch = false,
        highlights = function()
            return false
        end,
    }
    lazy = false
}
```

```lua
-- Packer
use {
    "Yoolayn/minintro.nvim",
    config = function() require("minintro").setup({
        intro = {
            " ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
            " ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
            " ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
            " ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
            " ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
            " ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
        },
        color = "#98c379",
        scratch = false,
        highlights = function()
            return false
        end,
    }) end
}
```

## Example
this is my configuration from the screenshot, using lazy.nvim
```lua
    return {
        "Yoolayn/minintro.nvim",
        config = {
            intro = {
                "███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
                "████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
                "██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
                "██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
                "██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
                "╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
                "                      [ @Yoolayn ]                    ",
                "                                                      ",
                "  type :checkhealth<Enter> ->   to optimize Nvim      ",
                "  type :Lazy<Enter>        ->   to update plugins     ",
                "  type :help<Enter>        ->   for help              ",
                "                                                      ",
                "  type :help news<Enter>   ->   for help              ",
                "                                                      ",
                "  press <Space>ff          ->   to find files         ",
                "  press <Space>fr          ->   to find recent files  ",
                "  press <Space>gg          ->   to start Neogit       ",
                "                                                      ",
                "                   Have a nice day :)                 ",
            },
            color = "#f7f3f2",
            scratch = true,
            highlights = function()
                local ns = vim.api.nvim_create_namespace("EnterMatch")
                vim.api.nvim_set_hl(ns, "EnterMatch", { fg = "#187df0" })
                vim.api.nvim_set_hl_ns(ns)
                vim.fn.matchadd("EnterMatch", "<Enter>")
            end,
        },
    },
```

## Things to be aware of
If you have some sort of `tabline` plugin such as [bufferline](https://github.com/akinsho/bufferline.nvim),
`vim.opt.showtabline` will be overridden to `1`. This forces display of a buffer tab even when there is only
one. If you do not wanna see the tab, you can modify `bufferline`'s configuration like the following:
```lua
require("bufferline").setup({
    options = {
        always_show_bufferline = false
    }
```
The above configuration will effectively set `vim.opt.showtabline` to 2, meaning the tabs will only start to
display when there is more than one buffer open

## Notice
Minintro will throw an error when lazy.nvim starts and updates something, but after a restart should be working as normal

