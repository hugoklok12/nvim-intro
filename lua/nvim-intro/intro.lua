local PLUGIN_NAME = "minintro"
local autocmd_group = vim.api.nvim_create_augroup(PLUGIN_NAME, {})
local highlight_ns_id = vim.api.nvim_create_namespace(PLUGIN_NAME)

local defaults = {
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
    height = 6,
    width = 55,
}

local M = {}

M.matcher = function()
    local function clean(inputString)
        local pattern = "[^%a]+"
        local resultString = inputString:gsub(pattern, "")

        return resultString .. "_minintro_custom_match_"
    end

    local ns = vim.api.nvim_create_namespace("CustomMatches")
    local i = 1
    for pattern, color in pairs(M.options.highlights) do
        local name = clean(pattern) .. i
        i = i + 1
        vim.api.nvim_set_hl(ns, name, { fg = color })
        vim.fn.matchadd(name, pattern)
    end
    vim.api.nvim_set_hl_ns(ns)
end

M.max_window = function()
    local wins = vim.api.nvim_list_wins()
    local max = -1
    local max_win = -1
    for _, win in ipairs(wins) do
        local size = vim.api.nvim_win_get_width(win) * vim.api.nvim_win_get_height(win)
        if size > max then
            max = size
            max_win = win
        end
    end

    return max_win
end

M.close_other_wins = function(curr_win)
    local wins = vim.api.nvim_list_wins()
    vim.notify(vim.inspect(wins), 1, {})
    for _, win in ipairs(wins) do
        if win ~= curr_win then
            vim.api.nvim_win_close(win, false)
        end
    end
end

M.setup = function(options)
    options = options or {}
    M.options = vim.tbl_deep_extend("force", defaults, options)
    M.options.height = #M.options.intro
    M.options.widht = vim.fn.strdisplaywidth(M.options.intro[1])
    vim.api.nvim_set_hl(highlight_ns_id, "Minintro", { fg = M.options.color })
    vim.api.nvim_set_hl_ns(highlight_ns_id)

    vim.api.nvim_create_autocmd("VimEnter", {
        group = autocmd_group,
        callback = M.display_minintro,
        once = true,
    })
end

M.draw_minintro = function(bufnr)
    local window = vim.fn.bufwinid(bufnr)
    local screen_width = vim.api.nvim_win_get_width(window)
    local screen_height = vim.api.nvim_win_get_height(window) - vim.opt.cmdheight:get()

    local start_col = math.floor((screen_width - M.options.width) / 2)
    local start_row = math.floor((screen_height - M.options.height) / 2)
    if start_col < 0 or start_row < 0 then
        return
    end

    local top_space = {}
    for _ = 1, start_row do
        table.insert(top_space, "")
    end

    local col_offset_spaces = {}
    for _ = 1, start_col do
        table.insert(col_offset_spaces, " ")
    end
    local col_offset = table.concat(col_offset_spaces, "")

    local adjusted_logo = {}
    for _, line in ipairs(M.options.intro) do
        table.insert(adjusted_logo, col_offset .. line)
    end

    vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
    vim.api.nvim_buf_set_lines(bufnr, 1, 1, true, top_space)
    vim.api.nvim_buf_set_lines(bufnr, start_row, start_row, true, adjusted_logo)

    vim.api.nvim_buf_set_extmark(bufnr, highlight_ns_id, start_row, start_col, {
        end_row = start_row + M.options.height,
        hl_group = "Minintro",
    })
end

M.create_and_set_minintro_buf = function()
    local intro_buff = vim.api.nvim_create_buf(true, true)
    local target_win = M.max_window()
    vim.api.nvim_buf_set_name(intro_buff, PLUGIN_NAME)
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = intro_buff })
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = intro_buff })
    vim.api.nvim_set_option_value("filetype", "minintro", { buf = intro_buff })
    vim.api.nvim_set_option_value("swapfile", false, { buf = intro_buff })
    vim.api.nvim_win_set_buf(target_win, intro_buff)

    return intro_buff, target_win
end

M.display_minintro = function(payload)
    local is_dir = vim.fn.isdirectory(payload.file) == 1

    local default_buff = 0
    local default_buff_name = vim.api.nvim_buf_get_name(default_buff)
    local default_buff_filetype = vim.api.nvim_get_option_value("filetype", { buf = default_buff })
    if not is_dir and default_buff_name ~= "" and default_buff_filetype ~= PLUGIN_NAME then
        return
    end

    local minintro_buff, intro_win = M.create_and_set_minintro_buf()

    vim.opt_local.list = false
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    if M.options.callback ~= nil then
        M.options.callback()
    end

    M.matcher()

    if M.options.scratch == true then
        local bufs = vim.api.nvim_list_bufs()
        for _, buf in ipairs(bufs) do
            if vim.api.nvim_buf_get_name(buf) == "" then
                vim.api.nvim_buf_delete(buf, { force = true })
            end
        end
    end

    local intro_autocmd = vim.api.nvim_create_augroup("intro_autocmd", {})

    vim.api.nvim_clear_autocmds({ group = intro_autocmd })

    vim.api.nvim_create_autocmd("BufHidden", {
        buffer = minintro_buff,
        once = true,
        callback = function()
            vim.api.nvim_clear_autocmds({ group = intro_autocmd })
        end,
    })

    vim.api.nvim_create_autocmd("CursorMoved", {
        group = vim.api.nvim_create_augroup("cursor_lock", {}),
        callback = function()
            vim.api.nvim_win_set_cursor(intro_win, { 1, 1 })
        end,
    })

    vim.api.nvim_create_autocmd({ "BufEnter" }, {
        group = intro_autocmd,
        buffer = minintro_buff,
        callback = function()
            M.matcher()
            vim.api.nvim_create_autocmd("CursorMoved", {
                group = vim.api.nvim_create_augroup("cursor_lock", {}),
                callback = function()
                    vim.api.nvim_win_set_cursor(intro_win, { 1, 1 })
                end,
            })
        end,
    })

    vim.api.nvim_create_autocmd({ "BufLeave" }, {
        group = intro_autocmd,
        buffer = minintro_buff,
        callback = function()
            vim.fn.clearmatches()
            vim.api.nvim_clear_autocmds({ group = "cursor_lock" })
        end,
    })

    vim.api.nvim_create_autocmd({ "TextChangedI", "ModeChanged" }, {
        group = intro_autocmd,
        buffer = minintro_buff,
        once = true,
        callback = function()
            vim.api.nvim_win_set_buf(intro_win, vim.api.nvim_create_buf(false, M.options.scratch))
            vim.api.nvim_clear_autocmds({ group = "cursor_lock" })
            vim.api.nvim_clear_autocmds({ group = intro_autocmd })
        end,
    })

    M.draw_minintro(minintro_buff)
end

return M
