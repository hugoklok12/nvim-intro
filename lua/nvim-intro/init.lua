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

M.create_and_set_minintro_buf = function(default_buff)
	local intro_buff = vim.api.nvim_create_buf(true, true)
	vim.api.nvim_buf_set_name(intro_buff, PLUGIN_NAME)
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = intro_buff })
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = intro_buff })
	vim.api.nvim_set_option_value("filetype", "minintro", { buf = intro_buff })
	vim.api.nvim_set_option_value("swapfile", false, { buf = intro_buff })
	vim.api.nvim_set_current_buf(intro_buff)

	local curr_win

	if vim.api.nvim_buf_is_valid(default_buff) then
		vim.api.nvim_buf_delete(default_buff, { force = true })
	else
		curr_win = vim.api.nvim_get_current_win()
	end

	return intro_buff, curr_win or nil
end

M.display_minintro = function(payload)
	local is_dir = vim.fn.isdirectory(payload.file) == 1

	local default_buff = vim.api.nvim_get_current_buf()
	local default_buff_name = vim.api.nvim_buf_get_name(default_buff)
	local default_buff_filetype = vim.api.nvim_get_option_value("filetype", { buf = default_buff })
	if not is_dir and default_buff_name ~= "" and default_buff_filetype ~= PLUGIN_NAME then
		return
	end

	local minintro_buff, curr_win = M.create_and_set_minintro_buf(default_buff)

	vim.opt_local.number = false
	vim.opt_local.relativenumber = false
	if M.options.callback ~= nil then
		M.options.callback()
	end

	M.matcher()

	vim.api.nvim_create_autocmd({
		"CursorMoved",
		"ModeChanged",
		"BufLeave",
	}, {
		group = autocmd_group,
		callback = function()
			if curr_win ~= nil and vim.bo.filetype == "minintro" then
				-- HACK: this won't work if more than 2 windows appear
				-- in short: works on my machine :)
				-- INFO: if this bothers you / your vim starts with more than 2 windows
				-- please make a pr @ github.com/Yoolayn/nvim-intro
				-- because I give up, too stupid for it for now
				local wins = vim.api.nvim_list_wins()
				local start_win

				for _, win in ipairs(wins) do
					if win ~= curr_win then
						start_win = win
					end
				end

				vim.fn.clearmatches()
				vim.api.nvim_win_close(curr_win, false)
				vim.api.nvim_win_set_buf(start_win, vim.api.nvim_create_buf(false, M.options.scratch))
			elseif vim.bo.filetype == "minintro" then
				vim.fn.clearmatches()
				vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(false, M.options.scratch))
			end
		end,
		once = true,
	})

	M.draw_minintro(minintro_buff)
end

return M
