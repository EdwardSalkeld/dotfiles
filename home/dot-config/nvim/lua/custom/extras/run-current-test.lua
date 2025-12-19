local function run_current_test()
  -- Get current buffer info
  local bufnr = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]

  -- Convert absolute path to relative path from project root
  local cwd = vim.fn.getcwd()
  local relative_path = filepath:gsub('^' .. cwd .. '/', '')

  -- Convert file path to Python module format (replace / with . and remove .py)
  local python_module = relative_path:gsub('/', '.'):gsub('%.py$', '')

  -- Get all lines in the buffer
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- Find the current test class and method
  local current_class = nil
  local current_method = nil

  -- Check if we're on a class definition line
  local current_line = lines[cursor_line]
  local class_on_cursor = current_line:match '^class%s+([%w_]+)'

  if class_on_cursor then
    -- If cursor is on class definition, just run the whole class
    current_class = class_on_cursor
    current_method = nil
  else
    -- Search backwards from cursor to find class
    for i = cursor_line, 1, -1 do
      local line = lines[i]
      local class_match = line:match '^class%s+([%w_]+)'
      if class_match then
        current_class = class_match
        break
      end
    end

    -- Search backwards from cursor to find method
    for i = cursor_line, 1, -1 do
      local line = lines[i]
      local method_match = line:match '^%s+def%s+(test_[%w_]+)'
      if method_match then
        current_method = method_match
        break
      end
    end
  end

  -- Construct the test path
  local test_path = python_module
  if current_class then
    test_path = test_path .. '.' .. current_class
  end
  if current_method then
    test_path = test_path .. '.' .. current_method
  end

  -- Construct the Django test command
  local django_command = 'docker exec django python manage.py test --keepdb ' .. test_path

  -- Print what we're running
  print('Running test: ' .. test_path)
  print('Command: ' .. django_command)

  -- Create floating window for output
  local buf = vim.api.nvim_create_buf(false, true)

  -- Get editor dimensions
  local width = vim.o.columns
  local height = vim.o.lines

  -- Calculate floating window size (80% of editor)
  local win_width = math.ceil(width * 0.8)
  local win_height = math.ceil(height * 0.8)

  -- Calculate starting position to center the window
  local row = math.ceil((height - win_height) / 2 - 1)
  local col = math.ceil((width - win_width) / 2)

  -- Window options
  local opts = {
    style = 'minimal',
    relative = 'editor',
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    border = 'rounded',
    title = ' Test Output ',
    title_pos = 'center',
  }

  -- Create the floating window
  vim.api.nvim_open_win(buf, true, opts)

  -- Set buffer options
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = 'terminal'

  -- Add keymaps to close the window
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>close<cr>', { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '<cmd>close<cr>', { noremap = true, silent = true })

  -- Start terminal in the floating window
  vim.fn.termopen("echo 'Running: " .. django_command .. "' && " .. django_command, {
    on_exit = function(_, exit_code)
      -- Add exit status to buffer
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].modifiable then
          local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
          table.insert(lines, '')
          table.insert(lines, 'Process exited with code: ' .. exit_code)
          table.insert(lines, "Press 'q' or <Esc> to close")
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        end
      end)
    end,
  })

  return django_command
end

-- Make the function available globally
_G.run_current_test = run_current_test

-- You can call this function with :lua run_current_test()
-- Or map it to a key binding like:
vim.keymap.set('n', '<leader>rt', run_current_test, { desc = 'Run current test' })
