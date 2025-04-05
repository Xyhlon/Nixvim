-- Sentence-ending patterns (your original patterns)
local new_line_patterns = {
	"%f[%w](%S%S%S%S%S%S+%.)[%. \t]+%f[%u]", -- words with at least 6 non-whitespace characters ending with period, followed by whitespace then uppercase
	"%f[%w](%d%d+%.)[ \t]+%f[%u]",          -- words with at least 2 digits ending with period, whitespace, uppercase
	"%f[%w](%S+[%!%?])[ \t]+%f[%u]"         -- words ending with '!' or '?' followed by whitespace and uppercase
}

-- Function to collect end positions (within a single line)
local function getAllEndPositions(text, patterns)
	local endPositions = {}
	for _, pattern in ipairs(patterns) do
		local startPos = 1
		while true do
			local s, e = string.find(text, pattern, startPos)
			if s then
				table.insert(endPositions, e)
				startPos = e + 1
			else
				break
			end
		end
	end
	return endPositions
end

-- Helper function to wrap a single line so that its length does not exceed 'width' characters.
local function wrap_line(line, width)
	width = width or 80
	local words = {}
	for word in line:gmatch("%S+") do
		table.insert(words, word)
	end

	local wrapped_lines = {}
	local current_line = ""

	for _, word in ipairs(words) do
		if current_line == "" then
			-- Start a new line with the current word.
			current_line = word
		else
			-- Check if adding the next word (with a space) exceeds the width.
			if #current_line + 1 + #word <= width then
				current_line = current_line .. " " .. word
			else
				-- If the current word itself is longer than width and the current line is empty,
				-- we still add it unbroken.
				table.insert(wrapped_lines, current_line)
				current_line = word
			end
		end
	end

	if current_line ~= "" then
		table.insert(wrapped_lines, current_line)
	end

	return table.concat(wrapped_lines, "\n")
end

-- Helper function to split text into lines (preserving empty lines)
local function split_lines(text)
	local lines = {}
	local pos = 1
	while true do
		local next_newline = text:find("\n", pos, true)
		if next_newline then
			table.insert(lines, text:sub(pos, next_newline - 1))
			pos = next_newline + 1
		else
			table.insert(lines, text:sub(pos))
			break
		end
	end
	return lines
end

-- Updated format_text() that respects existing newlines.
local function format_text(text, max_width)
	max_width = max_width or 80
	local output_lines = {}
	local lines = split_lines(text) -- preserve existing line breaks

	for _, line in ipairs(lines) do
		-- Preserve empty lines exactly.
		if line == "" then
			table.insert(output_lines, line)
		else
			-- Find sentence boundaries within this line.
			local positions = getAllEndPositions(line, new_line_patterns)
			table.sort(positions)
			local segments = {}
			local last_index = 1
			for _, pos in ipairs(positions) do
				table.insert(segments, line:sub(last_index, pos))
				last_index = pos + 1
			end
			if last_index <= #line then
				table.insert(segments, line:sub(last_index))
			end

			-- Process each segment separately.
			for _, seg in ipairs(segments) do
				local wrapped = wrap_line(seg, max_width)
				-- If wrapping produces multiple lines, add each one.
				for s in wrapped:gmatch("[^\n]+") do
					table.insert(output_lines, s)
				end
			end
		end
	end

	return table.concat(output_lines, "\n")
end

-- -- Example usage: format a sample text block.
-- local example_text = [[
-- Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat!
-- ]]
-- print("Formatted text:\n" .. M.format_text(example_text, 80))

--------------------------------------------------------------------------------
-- Treesitter Integration (Neovim-specific)
-- This function finds plaintext nodes (here, for example, paragraphs in Markdown)
-- and replaces their text with the formatted version.
--
-- Note: Adjust the Treesitter query based on the language/grammar you are targeting.
-- function format_plaintext_nodes(bufnr)
-- 	bufnr = bufnr or vim.api.nvim_get_current_buf()
-- 	local parser = vim.treesitter.get_parser(bufnr)
-- 	local tree = parser:parse()[1]
-- 	local root = tree:root()
-- 	-- Here, we assume a Markdown document where paragraphs are captured as (paragraph) nodes.
-- 	local query = vim.treesitter.query.parse("markdown", [[
--     (paragraph) @para
--   ]])
-- 	for _, node in query:iter_captures(root, bufnr, 0, -1) do
-- 		local range = { node:range() } -- { start_row, start_col, end_row, end_col }
-- 		local text = vim.treesitter.get_node_text(node, bufnr)
-- 		local formatted = format_text(text, 80)
-- 		local lines = {}
-- 		for line in formatted:gmatch("[^\n]+") do
-- 			table.insert(lines, line)
-- 		end
-- 		vim.api.nvim_buf_set_text(bufnr, range[1], range[2], range[3], range[4], lines)
-- 	end
-- end
--
function format_selection()
	-- Get the visual selection using vim functions.
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)
	local text = table.concat(lines, "\n")

	-- Format the text (using your format_text function).
	local formatted = format_text(text, 80)

	-- Replace the selection with the formatted text.
	local new_lines = {}
	for line in formatted:gmatch("[^\n]+") do
		table.insert(new_lines, line)
	end
	vim.api.nvim_buf_set_lines(0, start_pos[2] - 1, end_pos[2], false, new_lines)
end

--------------------------------------------------------------------------------
-- Extended Treesitter Integration for Markdown, LaTeX, Typst, and plaintext.
local function format_plaintext_nodes(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local filetype = vim.bo.filetype

	-- For plaintext files, which typically lack a Treesitter parser,
	-- format the entire buffer content.
	if filetype == "plaintext" then
		local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
		local text = table.concat(lines, "\n")
		local formatted = format_text(text, 80)
		local formatted_lines = {}
		for line in formatted:gmatch("[^\n]+") do
			table.insert(formatted_lines, line)
		end
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted_lines)
		return
	end

	-- Define a mapping of filetypes to Treesitter query strings.
	-- Adjust these queries according to the Treesitter grammar for your filetype.
	local queries = {
		markdown = [[
      (paragraph) @para
    ]],
		latex = [[
      ; For LaTeX, adjust this query to capture text nodes (e.g. inside environments or text_mode)
      (text_mode) @para
    ]],
		typst = [[
      ; For Typst, adjust according to its grammar; here we assume a node type "document_content"
      (content (text) @para)
    ]]
	}

	local query_str = queries[filetype]
	if not query_str then
		print("Filetype " .. filetype .. " is not supported for formatting")
		return
	end

	-- Get the Treesitter parser for the filetype.
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr, filetype)
	if not ok or not parser then
		print("Treesitter parser not available for filetype: " .. filetype)
		return
	end

	local tree = parser:parse()[1]
	local root = tree:root()

	-- Parse the query for the current filetype.
	local query = vim.treesitter.query.parse(filetype, query_str)

	-- Iterate over captures (each representing a text node)
	for _, node, _ in query:iter_captures(root, bufnr, 0, -1) do
		local range = { node:range() } -- { start_row, start_col, end_row, end_col }
		local text = vim.treesitter.get_node_text(node, bufnr)
		local formatted = format_text(text, 80)

		local lines = {}
		for line in formatted:gmatch("[^\n]+") do
			table.insert(lines, line)
		end
		-- table.insert(lines, "")
		vim.api.nvim_buf_set_text(bufnr, range[1], range[2], range[3], range[4], lines)
	end
end

vim.api.nvim_create_user_command("FormatPlaintext", function()
	format_plaintext_nodes()
end, {})

vim.api.nvim_create_user_command("FormatPlaintextHighlighted", function()
	format_selection()
end, {})

format_plaintext_nodes()

-- To run the Treesitter formatting on the current buffer in Neovim, you could use:
-- :lua format_plaintext_nodes()
