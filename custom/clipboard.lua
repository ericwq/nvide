local M = {}

local function should_add(event)
	local length = #event.regcontents - 1
	for _, line in ipairs(event.regcontents) do
		length = length + #line
		if length > 10000 then
			return false
		end
	end
	return true
end

M.handle_yank_post = function()
	local event = vim.v.event
	if should_add(event) then
		-- vim.fn.chansend(vim.v.stderr, vim.fn.printf("\x1b]52;;%s\x1b\\", vim.fn.system("base64 | tr -d '\n'", join(, "\n"))))
		local joined = vim.fn.join(event.regcontents, '\n')
		local based = vim.fn.system("base64 | tr -d '\n'", joined)
		vim.fn.chansend(vim.v.stderr, vim.fn.printf("\x1b]52;;%s\x1b\\", based))
	end
end

return M
