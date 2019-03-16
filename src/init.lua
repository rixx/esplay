load_files = {"init_hardware", "mpu6050"}

-- Once a second, try to load all relevant files.
tmr.alarm(6, 1000, tmr.ALARM_AUTO, function()
    if( (tmr.now() / 1000) > 5000) then
        -- We're getting six seconds for startup modifications.
        tmr.stop(6)

        for _, filename in ipairs(load_files) do
            filename = filename .. ".lua"
            if (file.open(filename)) then
                print("Loading file " .. filename)
                dofile(filename)
            else
                print(filename .. " not found.")
            end
        end
    end
end)
