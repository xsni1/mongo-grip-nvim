local M = {}

function M.setup(opts)
    local config = require("mongo-grip-nvim.config")

    config.set(opts)
end

-- lua mongodb driver cannot be used as it lacks some important features.
-- for example it doesn't allow us to `explain` the query
--
-- if performance starts to be an issue, spawn a child process with mongosh and send queries to it via stdin
local function get_selected_text()
    local _, sel_start_line, sel_start_col = unpack(vim.fn.getpos("v"))
    local _, sel_end_line, sel_end_col = unpack(vim.fn.getpos("."))
    local mode = vim.api.nvim_get_mode().mode
    local selected = {}

    -- "v" and "." are used to determine "live" cursor position, :help line()
    if mode == "v" then
        if sel_start_line < sel_end_line then
            selected = vim.api.nvim_buf_get_text(0, sel_start_line-1, sel_start_col-1, sel_end_line-1, sel_end_col, {})
        else
            selected = vim.api.nvim_buf_get_text(0, sel_end_line-1, sel_end_col-1, sel_start_line-1, sel_start_col, {})
        end
    end

    if mode == "V" then
        if sel_end_line > sel_start_line then
            selected = vim.api.nvim_buf_get_lines(0, sel_start_line-1, sel_end_line, true)
        else
            selected = vim.api.nvim_buf_get_lines(0, sel_end_line-1, sel_start_line, true)
        end
    end

    -- 22 / 0x16 - is string representation of Ctrl+v
    if mode == "\x16" then
        if sel_start_line > sel_end_line then
            sel_start_line, sel_end_line = sel_end_line, sel_start_line
        end

        if sel_start_col > sel_end_col then
            sel_start_col, sel_end_col = sel_end_col, sel_start_col
        end

        for i=sel_start_line, sel_end_line, 1 do
            table.insert(selected, unpack(vim.api.nvim_buf_get_text(0, i-1, sel_start_col-1, i-1, sel_end_col, {})))
        end
    end

    return table.concat(selected, "")
end

function M.make_query()
    local config = require("mongo-grip-nvim.config")
    local selected = get_selected_text()

    local result = vim.system({
        "mongosh",
        config.connString,
        "--eval",
        selected
    }, { text = true }):wait()

    local splited = {}
    for line in string.gmatch(result.stdout, "[^\n]+") do
        table.insert(splited, line)
    end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_command("belowright split")
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, splited)
    vim.api.nvim_win_set_buf(0, buf)
end


vim.api.nvim_create_user_command("MongoGripQuery", M.make_query, {})

vim.keymap.set({"v"}, "<leader>mq", M.make_query)

return M
