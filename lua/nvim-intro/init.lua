local M = {}

M.setup = function(options)
    if vim.g.neovide then
        return
    else
        require("nvim-intro.intro").setup(options)
    end
end

return M
