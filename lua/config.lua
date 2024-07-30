local config = {
    connString = "conn"
}

function config.set(opts)
    config.connString = opts.connString
end

return config
