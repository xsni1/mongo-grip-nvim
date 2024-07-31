local config = {
    connString = "mongodb://localhost:27017"
}

function config.set(opts)
    for k, v in pairs(opts) do
        config[k] = v
    end
end

return config
