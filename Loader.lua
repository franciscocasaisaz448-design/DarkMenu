-- [[ DARKMENU SUPREME LOADER ]]
-- [[ Premium Secure Loader ]]

print("[DarkMenu] Fetching latest version...")

local raw_url = "https://raw.githubusercontent.com/franciscocasaisaz448-design/DarkMenu/main/DarkMenuOficial.lua"
local success, script_content = pcall(function()
    return game:HttpGet(raw_url .. "?t=" .. os.time()) -- Bypass GitHub cache
end)

if success and script_content then
    local func, err = loadstring(script_content)
    if func then
        local runSuccess, runError = pcall(func)
        if not runSuccess then
            warn("[DarkMenu] Runtime Error: " .. tostring(runError))
        end
    else
        warn("[DarkMenu] Syntax Error: " .. tostring(err))
    end
else
    warn("[DarkMenu] Connection Error: Could not reach GitHub.")
end
