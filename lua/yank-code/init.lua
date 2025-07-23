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

local function get_git_path()
  local git_root_path = vim.fn.system({'git', 'rev-parse', '--show-toplevel'})
  if #git_root_path > 0 and git_root_path:sub(1, 6) ~= 'fatal:' then
    return vim.trim(git_root_path)
  end

  return ''
end

local function get_file_path()
  local path = vim.fn.expand('%')

  local git_root_path = get_git_path()
  if #git_root_path > 0 then
    path = vim.fn.expand('%:p'):sub(#git_root_path + 2) -- absolute path and +1 to start after, +1 to remove slash
  end

  return path
end

local function get_repo_name()
  local git_root_path = get_git_path()

  if #git_root_path > 0 then
    local directories = vim.split(git_root_path, '/', { plain = true })
    return directories[#directories]
  end

  return ''
end

local function comment(start_line, end_line)
  local note = get_repo_name()

  local file_path = get_file_path()
  if #file_path > 0 then
    if #note == 0 then
      note = file_path
    else
      note = note .. ': ' .. file_path
    end
  else
    return ''
  end

  local commentstring = vim.api.nvim_buf_get_option(0, 'commentstring')
  if not commentstring or #commentstring == 0 then
    commentstring = '%s'
  end

  if start_line == end_line then
    note = note .. (' (line %d)'):format(start_line)
  else
    note = note .. (' (lines %d-%d)'):format(start_line, end_line)
  end

  return commentstring:format(note) .. '\n'
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
  vim.notify(('%i lines of code yanked'):format(#lines), vim.log.levels.INFO)
end

function M.setup()
  vim.api.nvim_create_user_command('YankCode', yank_code, {
    desc = 'Yank code with a file reference and no indentation.',
    range = true
  })
end

return M
