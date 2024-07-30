-- vim.api - something like stdlib, contains nvim_*
-- vim.opt / vim.o - different way (lua way) of changing internal vim settings (?) :help vim.opt
--   for example: vim.opt.runtimepath:append("./") - used this to add this plugin to runtimepath
--
-- once a module has been required, it is being executed from top to bottom and the returned value (by default it's `true`) is saved to global package.loaded table.
-- :lua print(vim.inspect(package.loaded["mongo-grip-nvim"]))
-- it is done to prevent execution of the same module multiple times
--
-- :source % - to run the provided file, % simply means the current file

function MongoConnect()
    print("connecting...")
end

vim.api.nvim_create_user_command("MongoGripConnect", MongoConnect, {})

print("hello from mongo")
