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
-- if performance starts to be an issue, start a child process with mongosh and send queries to it via stdin
local function mongoConnect()
    local config = require("mongo-grip-nvim.config")

    print("connecting...")
    print(config.connString)

    os.execute("mkdir hello")
end

local function query()
    local config = require("mongo-grip-nvim.config")
    local result = vim.system({
        "mongosh",
        config.connString,
        "--eval",
        "db.getCollectionNames()"
    }, { text = true }):wait()

    print(result.stdout)
end

vim.api.nvim_create_user_command("MongoGripConnect", mongoConnect, {})
vim.api.nvim_create_user_command("MongoGripQuery", query, {})

return M
