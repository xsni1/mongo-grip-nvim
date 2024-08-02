-- vim.api - something like stdlib, contains nvim_*
-- vim.opt / vim.o - different way (lua way) of changing internal vim settings (?) :help vim.opt
--   for example: vim.opt.runtimepath:append("./") - used this to add this plugin to runtimepath
--
-- once a module has been required, it is being executed from top to bottom and the returned value (by default it's `true`) is saved to global package.loaded table.
-- :lua print(vim.inspect(package.loaded["mongo-grip-nvim"]))
-- it is done to prevent execution of the same module multiple times
--
-- :source % - to run the provided file, % simply means the current file

local M = {}

function M.setup(opts)
    local config = require("mongo-grip-nvim.config")

    print(config.connString)
    config.set(opts)
    print(config.connString)
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

    return selected
end
local function mongoConnect()
    local config = require("mongo-grip-nvim.config")

    print("connecting...")
    print(config.connString)

    os.execute("mkdir hello")
end

local function query()
    local config = require("mongo-grip-nvim.config")
    local selected = get_selected_text()

    -- "v" and "." are used to determine "live" cursor position, :help line()

    print("selected: ", table.concat(selected), #selected)
    -- local result = vim.system({
    --     "mongosh",
    --     config.connString,
    --     "--eval",
    --     "db.getCollectionNames()"
    -- }, { text = true }):wait()

    -- print(result.stdout)
end


vim.api.nvim_create_user_command("MongoGripConnect", mongoConnect, {})
vim.api.nvim_create_user_command("MongoGripQuery", query, {})

vim.keymap.set({"v"}, "<leader>mq", query)

return M
