{...}: {
  extraConfigLua =
    #Lua
    ''
      -- Sentence-ending patterns (your original patterns)
      local new_line_patterns = {
      	"%f[%w](%S%S%S%S%S%S+%.)[ \t]+%f[%u]", -- words with at least 6 non-whitespace characters ending with period, followed by whitespace then uppercase
      	"%f[%w](%d%d+%.)[ \t]+%f[%u]",        -- words with at least 2 digits ending with period, whitespace, uppercase
      	"%f[%w](%S+[%!%?])[ \t]+%f[%u]"       -- words ending with '!' or '?' followed by whitespace and uppercase
      }

      -- Function to collect all end positions where a newline should be added.
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
      	local wrapped = {}
      	while #line > width do
      		-- Try to break at the last whitespace in the first 'width' characters.
      		local breakpoint = line:sub(1, width):match(".*()%s")
      		if not breakpoint or breakpoint < width * 0.5 then
      			-- If no suitable breakpoint, force a break at 'width'
      			breakpoint = width
      		end
      		table.insert(wrapped, line:sub(1, breakpoint))
      		-- Remove the wrapped part and trim leading whitespace.
      		line = line:sub(breakpoint + 1):gsub("^%s+", "")
      	end
      	table.insert(wrapped, line)
      	return table.concat(wrapped, "\n")
      end

      -- Main function to format a block of text:
      --   1. Insert newlines after sentence endings.
      --   2. Wrap each resulting line to a maximum width (default 80 characters).
      function format_text(text, max_width)
      	max_width = max_width or 80

      	-- Insert newline at sentence boundaries.
      	local positions = getAllEndPositions(text, new_line_patterns)
      	table.sort(positions)
      	local segments = {}
      	local last_index = 1
      	for _, pos in ipairs(positions) do
      		table.insert(segments, text:sub(last_index, pos))
      		last_index = pos + 1
      	end
      	if last_index <= #text then
      		table.insert(segments, text:sub(last_index))
      	end
      	local with_newlines = table.concat(segments, "\n")

      	-- Wrap each line so that no line is longer than max_width.
      	local wrapped_lines = {}
      	for line in with_newlines:gmatch("[^\n]+") do
      		table.insert(wrapped_lines, wrap_line(line, max_width))
      	end

      	return table.concat(wrapped_lines, "\n")
      end

      --------------------------------------------------------------------------------
      -- Treesitter Integration (Neovim-specific)
      -- This function finds plaintext nodes (here, for example, paragraphs in Markdown)
      -- and replaces their text with the formatted version.
      --
      -- Note: Adjust the Treesitter query based on the language/grammar you are targeting.
      function format_plaintext_nodes(bufnr)
      	bufnr = bufnr or vim.api.nvim_get_current_buf()
      	local parser = vim.treesitter.get_parser(bufnr)
      	local tree = parser:parse()[1]
      	local root = tree:root()
      	-- Here, we assume a Markdown document where paragraphs are captured as (paragraph) nodes.
      	local query = vim.treesitter.query.parse("markdown", [[
          (paragraph) @para
        ]])
      	for _, node in query:iter_captures(root, bufnr, 0, -1) do
      		local range = { node:range() } -- { start_row, start_col, end_row, end_col }
      		local text = vim.treesitter.get_node_text(node, bufnr)
      		local formatted = format_text(text, 80)
      		local lines = {}
      		for line in formatted:gmatch("[^\n]+") do
      			table.insert(lines, line)
      		end
      		vim.api.nvim_buf_set_text(bufnr, range[1], range[2], range[3], range[4], lines)
      	end
      end

      function format_selection()
      	-- Get the visual selection using vim functions.
      	local start_pos = vim.fn.getpos("'<")
      	local end_pos = vim.fn.getpos("'>")
      	local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)
      	local text = table.concat(lines, "\n")

      	-- Format the text (using your format_text function).
      	local formatted = require('my_formatter').format_text(text, 80)

      	-- Replace the selection with the formatted text.
      	local new_lines = {}
      	for line in formatted:gmatch("[^\n]+") do
      		table.insert(new_lines, line)
      	end
      	vim.api.nvim_buf_set_lines(0, start_pos[2] - 1, end_pos[2], false, new_lines)
      end

      vim.api.nvim_create_user_command("FormatPlaintext", function()
      	format_plaintext_nodes()
      end, {})

      vim.api.nvim_create_user_command("FormatPlaintextHighlighted", function()
      	format_selection()
      end, {})
    '';
}
