local config = {
    connString = "conn"
}

function config.set(opts)
    for k, v in pairs(opts) do
        config[k] = v
    end
end

return config
