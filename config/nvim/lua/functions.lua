vim.api.nvim_create_user_command('Scratch', function(opts)
	local ft = opts.args ~= "" and opts.args or "txt"

	if opts.range <= 0 then
		vim.notify("No selection found. Select an empty line at least.")
		return
	end

	local start_line = opts.line1
	local end_line = opts.line2

	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
	local orig_buf = vim.api.nvim_get_current_buf()

	vim.cmd('new')

	local scratch_buf = vim.api.nvim_get_current_buf()

	vim.api.nvim_buf_set_name(scratch_buf, 'scratch.' .. ft)
	vim.api.nvim_buf_set_lines(scratch_buf, 0, -1, false, lines)

	vim.bo.filetype = ft

	vim.cmd('setlocal buftype=acwrite bufhidden=wipe noswapfile')

	-- make :w replace the original text
	vim.api.nvim_create_autocmd("BufWriteCmd", {
		buffer = scratch_buf,
		callback = function()
			local new_lines = vim.api.nvim_buf_get_lines(scratch_buf, 0, -1, false)
			vim.api.nvim_buf_set_lines(
				orig_buf,
				start_line - 1,
				end_line,
				false,
				new_lines
			)
			vim.bo.modified = false
		end
	})
end, { nargs = '?', range = true })
