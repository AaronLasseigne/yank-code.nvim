local M = {}

local function indent_size(lines)
  local space_count = 0;
  for _, line in pairs(lines) do
    if #line > 0 then
      local leading_space_count = #line:match('^%s*')
      if space_count == 0 or leading_space_count < space_count then
        space_count = leading_space_count
      end
    end
  end
  return space_count
end

local function comment(start_line, end_line)
  local file_name = vim.fn.getreg('%')
  if not file_name or #file_name == 0 then
    return ''
  end

  local commentstring = vim.api.nvim_buf_get_option(0, 'commentstring')
  if not commentstring or #commentstring == 0 then
    commentstring = '%s'
  end

  local note = commentstring:format(file_name)
  if start_line == end_line then
    note = note .. (' (line %d)'):format(start_line)
  else
    note = note .. (' (lines %d-%d)'):format(start_line, end_line)
  end

  return note .. '\n'
end

local function yank_code(args)
  local start_line = args['line1']
  local end_line = args['line2']
  local output = ''

  output = output .. comment(start_line, end_line)

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, true)
  local indent = indent_size(lines)
  for _, line in pairs(lines) do
    local corrected_line = line:sub(indent + 1)
    output = output .. corrected_line .. '\n'
  end

  vim.fn.setreg('+', output)
  print(('%i lines of code yanked'):format(#lines))
end

function M.setup()
  vim.api.nvim_create_user_command('YankCode', yank_code, {
    desc = 'Yank code with a file reference and no indentation.',
    range = true
  })
end

return M
