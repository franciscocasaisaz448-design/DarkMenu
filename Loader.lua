-- [[ DARKMENU SUPREME LOADER ]]
-- [[ This script is protected and optimized ]]

if not getgenv().DarkMenuExecuted then
    print("[DarkMenu] Initializing Secure Loader...")
    
    local function execute()
        local raw_url = "https://raw.githubusercontent.com/franciscocasaisaz448-design/DarkMenu/main/DarkMenuOficial.lua"
        local success, script_content = pcall(function()
            return game:HttpGet(raw_url)
        end)
        
        if success and script_content then
            local func, err = loadstring(script_content)
            if func then
                func()
            else
                warn("[DarkMenu] Syntax Error in Source: " .. tostring(err))
            end
        else
            warn("[DarkMenu] Failed to fetch source code. Check your Internet connection.")
        end
    end
    
    task.spawn(execute)
else
    warn("[DarkMenu] Already executed!")
end
