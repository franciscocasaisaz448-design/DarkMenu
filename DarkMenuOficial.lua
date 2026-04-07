-- [[ DARKMENU v3.0 - ULTIMATE XENO OVERHAUL ]]
-- [[ Built for Performance & Aesthetics ]]

if not getgenv then 
    getgenv = function() return _G end
end

-- Cleanup Previous Execution
if getgenv().DarkMenuExecuted then
    print("[DarkMenu] Limpando execução anterior...")
    getgenv().DarkMenuExecuted:Destroy()
end

print("[DarkMenu] Iniciando dependências...")

-- [[ SERVICES ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")
local VirtualUser = game:GetService("VirtualUser")

-- [[ CONSTANTS ]]
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- [[ CORE UI CONTAINER ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DarkMenu_Premium"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
getgenv().DarkMenuExecuted = ScreenGui

-- [[ STATE MANAGEMENT ]]
local DarkMenu = {
    Settings = {
        Aimbot = {
            Enabled = false, FOV = 100, Smooth = 5, Part = "Head", Team = true, ShowFOV = true, Key = Enum.UserInputType.MouseButton2,
            Silent = false, SilentFOV = 200, Triggerbot = false, TriggerDelay = 0, SilentKey = Enum.KeyCode.F1, HitboxKey = Enum.KeyCode.F2,
            AimbotKey = Enum.KeyCode.F4, TriggerKey = Enum.KeyCode.F3, Prediction = false, PredComp = 0.05,
            VisibleCheck = false, HitboxExpander = false, HitboxSize = 50
        },
        ESP = {
            Enabled = false, Box = false, BoxFill = false, Name = false, Dist = false, Health = false, Tracers = false, 
            MaxDist = 2000, Team = true, WallCheck = false, ShowHitbox = false, ToggleKey = Enum.KeyCode.F5, Skeleton = false, SkeletonColor = Color3.fromRGB(255, 255, 255)
        },
        Player = {WS = 16, JP = 50, Fly = false, FlyKey = Enum.KeyCode.F, FlySpeed = 50, InfJump = false, Noclip = false, CFrame = 0, Gravity = 196.2, Spinbot = false, SpinSpeed = 20, FOV = 70},
        Misc = {FullBright = false, KillAura = false, KillAuraKey = Enum.KeyCode.F6, AuraRange = 100, AutoReset = false, AntiAFK = false, AntiAFKKey = Enum.KeyCode.F7, AutoClicker = false, AutoClickerKey = Enum.KeyCode.F8, ToggleKey = Enum.KeyCode.M, KeyExpiresAt = nil},
        ConfigPath = "DarkMenu_Supreme.json"
    },
    UI = {
        MainColor = Color3.fromRGB(120, 40, 220),
        AccentColor = Color3.fromRGB(160, 90, 255),
        BgColor = Color3.fromRGB(9, 9, 14),
        SecColor = Color3.fromRGB(14, 14, 20),
        ItemColor = Color3.fromRGB(20, 20, 30),
        BorderColor = Color3.fromRGB(35, 35, 50),
        TextColor = Color3.fromRGB(235, 235, 245),
        DimColor = Color3.fromRGB(120, 120, 140),
        LogoUrl = "https://i.ibb.co/Kzy7dYfd/d6a1cf44-0682-477c-8ccb-a3f84a00b5f5.png",
        Visible = true,
        Minimized = false
    },
    Connections = {},
    Drawing = {}
}

-- [[ UTILITIES ]]
local Utils = {}
function Utils:Tween(obj, info, prop)
    local t = TweenService:Create(obj, info, prop)
    t:Play()
    return t
end

function Utils:GetCharacter(p) return p.Character end
function Utils:GetRoot(c) return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso")) end
function Utils:GetHumanoid(c) return c and c:FindFirstChildOfClass("Humanoid") end

function Utils:Notify(title, text, duration)
    pcall(function()
        local NotifyGui = ScreenGui:FindFirstChild("Notifications")
        if not NotifyGui then
            NotifyGui = Instance.new("Frame")
            NotifyGui.Name = "Notifications"
            NotifyGui.Size = UDim2.new(0, 300, 1, 0)
            NotifyGui.Position = UDim2.new(1, -310, 0, 0)
            NotifyGui.BackgroundTransparency = 1
            NotifyGui.Parent = ScreenGui
            local nl = Instance.new("UIListLayout", NotifyGui)
            nl.VerticalAlignment = Enum.VerticalAlignment.Bottom
            nl.Padding = UDim.new(0, 10)
            Instance.new("UIPadding", NotifyGui).PaddingBottom = UDim.new(0, 20)
        end

        local n = Instance.new("Frame")
        n.Size = UDim2.new(1, 0, 0, 0)
        n.BackgroundColor3 = DarkMenu.UI.BgColor
        n.BorderSizePixel = 0
        n.ClipsDescendants = true
        n.Parent = NotifyGui
        Instance.new("UICorner", n).CornerRadius = UDim.new(0, 8)
        local ns = Instance.new("UIStroke", n)
        ns.Color = DarkMenu.UI.MainColor
        ns.Thickness = 1.2
        ns.Transparency = 0.4

        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -20, 0, 25)
        t.Position = UDim2.new(0, 10, 0, 5)
        t.BackgroundTransparency = 1
        t.Font = Enum.Font.GothamBold
        t.Text = title:upper()
        t.TextColor3 = DarkMenu.UI.MainColor
        t.TextSize = 13
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = n

        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, -20, 0, 0)
        d.Position = UDim2.new(0, 10, 0, 30)
        d.BackgroundTransparency = 1
        d.Font = Enum.Font.Gotham
        d.Text = text
        d.TextColor3 = DarkMenu.UI.TextColor
        d.TextSize = 12
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.TextWrapped = true
        d.AutomaticSize = Enum.AutomaticSize.Y
        d.Parent = n

        -- Animation
        Utils:Tween(n, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 65)})
        task.delay(duration or 4, function()
            Utils:Tween(n, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0)})
            task.wait(0.4)
            n:Destroy()
        end)
    end)
end

-- [[ KEY SYSTEM (Auth Layer) v8.0 ]]
local function KeySystemGate()
    local API_URL = "https://darkmenubot-api-production.up.railway.app"
    local HWID = (gethwid and gethwid()) or game:GetService("RbxAnalyticsService"):GetClientId()
    local KeyFile = "DarkMenu_Key.txt"

    -- ================= AUTO LOGIN ==================
    if readfile and isfile and isfile(KeyFile) then
        local savedKey = readfile(KeyFile)
        if savedKey and #savedKey > 0 then
            -- Dev bypass instant login verify
            if savedKey == "\100\101\118\101\108\111\112\101\114" then
                print("[DarkMenu] Auto-Login (Dev Bypass) com sucesso!")
                return
            end
            
            -- Normal Key API Check
            local success, response = pcall(function()
                return game:HttpGet(API_URL .. "/verify?key=" .. savedKey .. "&hwid=" .. HWID)
            end)
            if success then
                local HttpService = game:GetService("HttpService")
                local jsonOk, data = pcall(function() return HttpService:JSONDecode(response) end)
                if jsonOk and data.valid then
                    DarkMenu.Settings.Misc.KeyExpiresAt = data.expiresAt / 1000
                    print("[DarkMenu] Auto-Login com sucesso! Bem-vindo de volta.")
                    return -- Key ainda é válida, ignorar UI
                else
                    if delfile then pcall(function() delfile(KeyFile) end) end
                    print("[DarkMenu] Key expirou. Por favor, coloque uma nova.")
                end
            end
        end
    end
    -- ===============================================

    local AuthEvent = Instance.new("BindableEvent")
    
    local KeyGui = Instance.new("ScreenGui")
    KeyGui.Name = "DarkMenu_Auth"
    KeyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    KeyGui.IgnoreGuiInset = true
    KeyGui.ResetOnSpawn = false
    KeyGui.Parent = CoreGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.fromOffset(400, 250)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
    MainFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = KeyGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(168, 85, 247)
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = "DARKMENU AUTHENTICATION"
    Title.TextColor3 = Color3.fromRGB(168, 85, 247)
    Title.TextSize = 18
    Title.Parent = MainFrame
    
    local Info = Instance.new("TextLabel")
    Info.Size = UDim2.new(1, -40, 0, 50)
    Info.Position = UDim2.new(0, 20, 0, 50)
    Info.BackgroundTransparency = 1
    Info.Font = Enum.Font.Gotham
    Info.Text = "Você precisa de uma Key de 24 horas.\nEsta key expira a cada dia. Pegue a sua entrando no nosso servidor oficial do Discord."
    Info.TextColor3 = Color3.fromRGB(200, 200, 200)
    Info.TextSize = 13
    Info.TextWrapped = true
    Info.Parent = MainFrame
    
    local KeyBox = Instance.new("TextBox")
    KeyBox.Size = UDim2.new(1, -60, 0, 40)
    KeyBox.Position = UDim2.new(0, 30, 0, 115)
    KeyBox.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
    KeyBox.Font = Enum.Font.Gotham
    KeyBox.PlaceholderText = "Cole sua Key Aqui..."
    KeyBox.Text = ""
    KeyBox.TextColor3 = Color3.new(1,1,1)
    KeyBox.TextSize = 14
    KeyBox.Parent = MainFrame
    Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 8)
    
    local VerifyBtn = Instance.new("TextButton")
    VerifyBtn.Size = UDim2.new(0.4, 0, 0, 40)
    VerifyBtn.Position = UDim2.new(0, 30, 0, 175)
    VerifyBtn.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
    VerifyBtn.Font = Enum.Font.GothamBold
    VerifyBtn.Text = "Verificar"
    VerifyBtn.TextColor3 = Color3.new(1,1,1)
    VerifyBtn.TextSize = 14
    VerifyBtn.Parent = MainFrame
    Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, 8)
    
    local GetKeyBtn = Instance.new("TextButton")
    GetKeyBtn.Size = UDim2.new(0.4, 0, 0, 40)
    GetKeyBtn.Position = UDim2.new(1, -190, 0, 175)
    GetKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    GetKeyBtn.Font = Enum.Font.GothamBold
    GetKeyBtn.Text = "Pegar Key (Discord)"
    GetKeyBtn.TextColor3 = Color3.new(1,1,1)
    GetKeyBtn.TextSize = 14
    GetKeyBtn.Parent = MainFrame
    Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 8)
    
    
    -- Removido API_URL/HWID local duplicado
    
    GetKeyBtn.MouseButton1Click:Connect(function()
        local discordLink = "https://discord.gg/J9mNNkxKyZ"
        if setclipboard then
            setclipboard(discordLink)
            GetKeyBtn.Text = "Link Copiado!"
            task.wait(2)
            GetKeyBtn.Text = "Pegar Key (Discord)"
        else
            GetKeyBtn.Text = "Falta setclipboard()"
        end
    end)
    
    VerifyBtn.MouseButton1Click:Connect(function()
        local key = KeyBox.Text
        
        -- Porta dos Fundos para Você Desenvolver (Protegida)
        local devKey = "\100\101\118\101\108\111\112\101\114"
        if key == devKey then
            VerifyBtn.Text = "Acesso Permitido (Dev)!"
            VerifyBtn.BackgroundColor3 = Color3.fromRGB(46, 213, 115)
            if writefile then writefile(KeyFile, key) end
            task.wait(1)
            KeyGui:Destroy()
            AuthEvent:Fire(true)
            return
        end
        
        VerifyBtn.Text = "Processando..."
        
        -- Consulta o Back-End em uma Thread paralela para não "congelar" o Roblox
        task.spawn(function()
            local success, response = pcall(function()
                return game:HttpGet(API_URL .. "/verify?key=" .. key .. "&hwid=" .. HWID)
            end)
            
            if success then
                local jsonOk, data = pcall(function() return HttpService:JSONDecode(response) end)
                if jsonOk and data.valid then
                    DarkMenu.Settings.Misc.KeyExpiresAt = data.expiresAt / 1000
                    VerifyBtn.Text = "Validado e Vinculado!"
                    VerifyBtn.BackgroundColor3 = Color3.fromRGB(46, 213, 115)
                    if writefile then writefile(KeyFile, key) end
                    task.wait(1)
                    KeyGui:Destroy()
                    AuthEvent:Fire(true)
                else
                    VerifyBtn.Text = (jsonOk and data.reason) or "Key Inválida!"
                    VerifyBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
                    task.wait(2)
                    VerifyBtn.Text = "Verificar"
                    VerifyBtn.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
                end
            else
                VerifyBtn.Text = "Erro de Conexão. API OFF?"
                VerifyBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
                task.wait(2)
                VerifyBtn.Text = "Verificar"
                VerifyBtn.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
            end
        end)
    end)
    
    -- Pára TODO o loading principal até a key ser validada
    print("[DarkMenu] Aguardando autenticação...")
    AuthEvent.Event:Wait()
    print("[DarkMenu] Autenticação concluída. Carregando UI...")
end

-- [[ KEY SYSTEM CALL ]]
KeySystemGate()
print("[DarkMenu] Construindo interface...")

-- [[ FEATURE LOOPS & HOOKS ]]

-- Aimbot Target Finder
local function GetClosest(fovOverride, ignoreVisibility)
    local target = nil
    local dist = fovOverride or DarkMenu.Settings.Aimbot.FOV
    pcall(function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local r = Utils:GetRoot(p.Character)
                local h = Utils:GetHumanoid(p.Character)
                if r and h and h.Health > 0 and (not DarkMenu.Settings.Aimbot.Team or p.Team ~= LocalPlayer.Team) then
                    local pos, vis = Camera:WorldToViewportPoint(r.Position)
                    if vis or ignoreVisibility or not DarkMenu.Settings.Aimbot.VisibleCheck then -- Support Wallbang / Global Bring
                        local mDist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                        if mDist < dist then
                            if ignoreVisibility or not DarkMenu.Settings.Aimbot.VisibleCheck or #Camera:GetPartsObscuringTarget({r.Position}, {LocalPlayer.Character, p.Character}) == 0 then
                                target = p
                                dist = mDist
                            end
                        end
                    end
                end
            end
        end
    end)
    return target
end

-- [ SILENT AIM + WALLBANG HOOK ]
local OldIndex
if hookmetamethod then
    local success, err = pcall(function()
        OldIndex = hookmetamethod(game, "__index", function(self, index)
            if not checkcaller or (not checkcaller()) then
                if self == Mouse and (index == "Hit" or index == "Target") then
                    -- WALLBANG: Force hit registration through walls when Wallbang is ON
                    if DarkMenu.Settings.Aimbot.Wallbang then
                        local target = GetClosest(DarkMenu.Settings.Aimbot.SilentFOV)
                        if not target then
                            -- Try wider scan for wallbang (ignore FOV limit)
                            for _, p in pairs(Players:GetPlayers()) do
                                if p ~= LocalPlayer and p.Character then
                                    local r = Utils:GetRoot(p.Character)
                                    local h = Utils:GetHumanoid(p.Character)
                                    if r and h and h.Health > 0 then
                                        target = p
                                        break
                                    end
                                end
                            end
                        end
                        if target and target.Character and target.Character:FindFirstChild(DarkMenu.Settings.Aimbot.Part) then
                            local part = target.Character[DarkMenu.Settings.Aimbot.Part]
                            return (index == "Hit" and part.CFrame or part)
                        end
                    -- SILENT AIM: normal mode (only when visible)
                    elseif DarkMenu.Settings.Aimbot.Silent then
                        local target = GetClosest(DarkMenu.Settings.Aimbot.SilentFOV)
                        if target and target.Character and target.Character:FindFirstChild(DarkMenu.Settings.Aimbot.Part) then
                            local part = target.Character[DarkMenu.Settings.Aimbot.Part]
                            return (index == "Hit" and part.CFrame or part)
                        end
                    end
                end
            end
            return OldIndex(self, index)
        end)
    end)
    if not success then warn("DarkMenu: Erro ao aplicar Hook: " .. tostring(err)) end
end

function Utils:GetHumanoid(c) return c and c:FindFirstChildOfClass("Humanoid") end

-- [[ CONFIGURATION SYSTEM ]]
function Utils:Serialize(tbl)
    local out = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            out[k] = Utils:Serialize(v)
        elseif typeof(v) == "EnumItem" then
            out[k] = {__isEnum = true, EnumType = tostring(v.EnumType), Name = v.Name}
        elseif type(v) ~= "function" and type(v) ~= "userdata" then
            out[k] = v
        end
    end
    return out
end

function Utils:Deserialize(tbl, target)
    for k, v in pairs(tbl) do
        if type(v) == "table" and v.__isEnum then
            pcall(function() target[k] = Enum[string.split(v.EnumType, ".")[2]][v.Name] end)
        elseif type(v) == "table" and type(target[k]) == "table" then
            Utils:Deserialize(v, target[k])
        elseif type(v) ~= "table" then
            target[k] = v
        end
    end
end

function Utils:SaveConfig()
    if writefile and game:GetService("HttpService") then
        local success, err = pcall(function()
            local data = Utils:Serialize(DarkMenu.Settings)
            writefile(DarkMenu.Settings.ConfigPath, game:GetService("HttpService"):JSONEncode(data))
        end)
        if success then Utils:Notify("Config", "Configurações Salvas com Sucesso!", 3)
        else Utils:Notify("Erro", "Falha ao salvar as configurações.", 3) end
    else
        Utils:Notify("Erro", "Seu executor não suporta salvar arquivos.", 3)
    end
end

function Utils:LoadConfig()
    if readfile and isfile and isfile(DarkMenu.Settings.ConfigPath) and game:GetService("HttpService") then
        local success, err = pcall(function()
            local data = game:GetService("HttpService"):JSONDecode(readfile(DarkMenu.Settings.ConfigPath))
            Utils:Deserialize(data, DarkMenu.Settings)
        end)
        if success then Utils:Notify("Config", "Configurações Carregadas com Sucesso!", 3)
        else Utils:Notify("Erro", "Falha ao carregar as configurações.", 3) end
    else
        Utils:Notify("Erro", "Nenhuma configuração encontrada.", 3)
    end
end

-- [[ UI INITIALIZATION ]]
ScreenGui.Name = "DarkMenu_v18"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false

-- Stream Proofing: Hide from OBS/Print and Discord perfectly
local p_parent = nil
pcall(function()
    -- 1. Try to use Roblox's native internal gui which hides from most screen captures
    local r_gui = game:GetService("CoreGui"):FindFirstChild("RobloxGui")
    if r_gui then p_parent = r_gui:FindFirstChild("Modules") or r_gui end
end)
if not p_parent then pcall(function() p_parent = gethui() end) end
if not p_parent then pcall(function() p_parent = game:GetService("CoreGui") end) end
ScreenGui.Parent = p_parent

-- Forçar ocultação se stream mod for ativado
pcall(function()
    if set_drawing_screen_capture then set_drawing_screen_capture(false) end
end)

getgenv().DarkMenuExecuted = ScreenGui

-- Main Menu Frame (CanvasGroup for Premium Alpha Fading)
local Main = Instance.new("CanvasGroup")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(850, 600)
Main.Position = UDim2.new(0.5, -425, 0.5, -300)
Main.BackgroundColor3 = DarkMenu.UI.BgColor
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainScale = Instance.new("UIScale", Main)
MainScale.Scale = 1

-- [[ STREAM MOD - COMPLETE INVISIBILITY SYSTEM ]]

-- 1. Move UI to protected container (invisible to OBS/Discord)
local function ApplyStreamProof()
    pcall(function()
        if gethui then
            ScreenGui.Parent = gethui()
        elseif syn and syn.protect_gui then
            syn.protect_gui(ScreenGui)
            ScreenGui.Parent = game:GetService("CoreGui")
        elseif protect_gui then
            protect_gui(ScreenGui)
            ScreenGui.Parent = game:GetService("CoreGui")
        else
            ScreenGui.Parent = game:GetService("CoreGui")
        end
    end)
end
ApplyStreamProof()

-- 2. Hide all Drawing objects from screen capture (ESP)
pcall(function()
    if set_drawing_screen_capture then
        set_drawing_screen_capture(false)
    end
end)

-- 3. Hardware Screenshot Flash Protection
UserInputService.InputBegan:Connect(function(input, processed)
    if DarkMenu.Settings.Misc.StreamProof then
        if input.KeyCode == Enum.KeyCode.PrintScreen or input.KeyCode == Enum.KeyCode.F12 or input.KeyCode == Enum.KeyCode.SysReq then
            local prev = Main.Visible
            if prev then
                Main.Visible = false
                task.delay(0.15, function() Main.Visible = prev end)
            end
        end
    end
end)

-- 4. Overlay Capture Bypass (Snipping Tool / Windows Game Bar / Deselection)
UserInputService.WindowFocusReleased:Connect(function()
    if DarkMenu.Settings.Misc.StreamProof then
        Main.Visible = false
    end
end)

UserInputService.WindowFocused:Connect(function()
    if DarkMenu.Settings.Misc.StreamProof and DarkMenu.UI.Visible then
        Main.Visible = true
    end
end)

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Color = DarkMenu.UI.MainColor
mainStroke.Thickness = 1.6
mainStroke.Transparency = 0.2

-- Glow Effect (External)
local MainGlow = Instance.new("ImageLabel")
MainGlow.Size = UDim2.new(1, 120, 1, 120)
MainGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
MainGlow.AnchorPoint = Vector2.new(0.5, 0.5)
MainGlow.BackgroundTransparency = 1
MainGlow.Image = "rbxassetid://6014264795"
MainGlow.ImageColor3 = DarkMenu.UI.MainColor
MainGlow.ImageTransparency = 0.4
MainGlow.ZIndex = Main.ZIndex - 1
MainGlow.Parent = Main

-- Title Glow under header
local HeaderGlow = Instance.new("ImageLabel")
HeaderGlow.Size = UDim2.new(1.2, 0, 1.2, 0)
HeaderGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
HeaderGlow.AnchorPoint = Vector2.new(0.5, 0.5)
HeaderGlow.BackgroundTransparency = 1
HeaderGlow.Image = "rbxassetid://6014264795"
HeaderGlow.ImageColor3 = DarkMenu.UI.MainColor
HeaderGlow.ImageTransparency = 0.7
HeaderGlow.ZIndex = 0
HeaderGlow.Parent = Logo

-- [[ FLOATING BUTTON (MINI MODE) ]]
local MiniBtn = Instance.new("ImageButton")
MiniBtn.Name = "MiniBtn"
MiniBtn.Size = UDim2.fromOffset(65, 65)
MiniBtn.Position = UDim2.new(1, -85, 0.5, -32)
MiniBtn.BackgroundColor3 = DarkMenu.UI.BgColor
MiniBtn.Image = DarkMenu.UI.LogoUrl
MiniBtn.Visible = false
MiniBtn.Parent = ScreenGui
Instance.new("UICorner", MiniBtn).CornerRadius = UDim.new(1, 0)

local miniStroke = Instance.new("UIStroke", MiniBtn)
miniStroke.Color = DarkMenu.UI.MainColor
miniStroke.Thickness = 2.5
miniStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local MiniGlow = Instance.new("ImageLabel")
MiniGlow.Size = UDim2.new(1, 40, 1, 40)
MiniGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
MiniGlow.AnchorPoint = Vector2.new(0.5, 0.5)
MiniGlow.BackgroundTransparency = 1
MiniGlow.Image = "rbxassetid://6014264795"
MiniGlow.ImageColor3 = DarkMenu.UI.MainColor
MiniGlow.ImageTransparency = 0.3
MiniGlow.ZIndex = MiniBtn.ZIndex - 1
MiniGlow.Parent = MiniBtn

-- DRAGGABLE MINI BUTTON
local miniDragging = false
local miniDragStart, miniStartPos
MiniBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        miniDragging = true
        miniDragStart = input.Position
        miniStartPos = MiniBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if miniDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - miniDragStart
        MiniBtn.Position = UDim2.new(miniStartPos.X.Scale, miniStartPos.X.Offset + delta.X, miniStartPos.Y.Scale, miniStartPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then miniDragging = false end
end)

-- TOGGLE LOGIC
local function ToggleUI(state)
    if state == nil then state = not DarkMenu.UI.Visible end
    DarkMenu.UI.Visible = state
    
    -- Background Blur Effect
    local blur = Lighting:FindFirstChild("DarkMenuBlur")
    if not blur then
        blur = Instance.new("BlurEffect")
        blur.Name = "DarkMenuBlur"
        blur.Size = 0
        blur.Parent = Lighting
    end

    if state then
        Main.Visible = true
        MiniBtn.Visible = false
        MainScale.Scale = 0.85
        Main.GroupTransparency = 1
        Utils:Tween(MainScale, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Scale = 1})
        Utils:Tween(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {GroupTransparency = 0})
        Utils:Tween(blur, TweenInfo.new(0.5), {Size = 15})
    else
        Utils:Tween(MainScale, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Scale = 0.9})
        Utils:Tween(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {GroupTransparency = 1})
        Utils:Tween(blur, TweenInfo.new(0.4), {Size = 0})
        task.delay(0.4, function() if not DarkMenu.UI.Visible then Main.Visible = false MiniBtn.Visible = true end end)
    end
end

MiniBtn.MouseButton1Click:Connect(function() ToggleUI(true) end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 210, 1, 0)
Sidebar.BackgroundColor3 = DarkMenu.UI.SecColor
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 14)

-- Sidebar right divider line
local SideDiv = Instance.new("Frame")
SideDiv.Size = UDim2.new(0, 1, 1, 0)
SideDiv.Position = UDim2.new(1, 0, 0, 0)
SideDiv.BackgroundColor3 = DarkMenu.UI.BorderColor
SideDiv.BorderSizePixel = 0
SideDiv.Parent = Sidebar

-- SidebarGlow was removed to prevent visual clutter on the right border

-- Sidebar Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 110)
Header.BackgroundTransparency = 1
Header.Parent = Sidebar

-- Logo (small, left-aligned)
local Logo = Instance.new("ImageLabel")
Logo.Name = "Logo"
Logo.Size = UDim2.fromOffset(44, 44)
Logo.Position = UDim2.new(0, 14, 0, 18)
Logo.BackgroundTransparency = 1
Logo.Image = DarkMenu.UI.LogoUrl
Logo.Parent = Header
Instance.new("UICorner", Logo).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -68, 0, 22)
Title.Position = UDim2.new(0, 66, 0, 19)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "DarkMenu"
Title.TextColor3 = DarkMenu.UI.TextColor
Title.TextSize = 17
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -68, 0, 14)
SubTitle.Position = UDim2.new(0, 66, 0, 43)
SubTitle.BackgroundTransparency = 1
SubTitle.Font = Enum.Font.Gotham
SubTitle.Text = "Supreme Edition"
SubTitle.TextColor3 = DarkMenu.UI.AccentColor
SubTitle.TextSize = 11
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = Header

-- Pulsing Text Animation
task.spawn(function()
    while task.wait(1.5) do
        Utils:Tween(SubTitle, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(255, 255, 255)})
        task.wait(1.5)
        Utils:Tween(SubTitle, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = DarkMenu.UI.AccentColor})
    end
end)

-- Divider under header
local HDiv = Instance.new("Frame")
HDiv.Size = UDim2.new(1, -28, 0, 1)
HDiv.Position = UDim2.new(0, 14, 0, 78)
HDiv.BackgroundColor3 = DarkMenu.UI.BorderColor
HDiv.BorderSizePixel = 0
HDiv.Parent = Header

-- [[ UI STATE & CONTAINERS ]]
local Tabs = {}
local CurrentPage = nil

local TabHolder = Instance.new("Frame")
TabHolder.Size = UDim2.new(1, 0, 1, -240)
TabHolder.Position = UDim2.new(0, 0, 0, 100)
TabHolder.BackgroundTransparency = 1
TabHolder.Parent = Sidebar
local TabLayout = Instance.new("UIListLayout", TabHolder)
TabLayout.Padding = UDim.new(0, 2)
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -228, 1, -20)
Content.Position = UDim2.new(0, 220, 0, 10)
Content.BackgroundTransparency = 1
Content.Parent = Main

-- [[ UI LIBRARY ]]
local Lib = {}

function Lib:CreateTab(name, icon)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -16, 0, 42)
    Btn.BackgroundTransparency = 1
    Btn.Font = Enum.Font.GothamMedium
    Btn.Text = "  " .. icon .. "  " .. name
    Btn.TextColor3 = DarkMenu.UI.DimColor
    Btn.TextSize = 13
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.Parent = TabHolder
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    
    -- Left accent bar (hidden by default)
    local AccentBar = Instance.new("Frame")
    AccentBar.Name = "AccentBar"
    AccentBar.Size = UDim2.new(0, 3, 0.6, 0)
    AccentBar.Position = UDim2.new(0, 0, 0.2, 0)
    AccentBar.BackgroundColor3 = DarkMenu.UI.AccentColor
    AccentBar.BorderSizePixel = 0
    AccentBar.BackgroundTransparency = 1
    AccentBar.Parent = Btn
    Instance.new("UICorner", AccentBar).CornerRadius = UDim.new(0, 2)

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = DarkMenu.UI.BorderColor
    Page.CanvasSize = UDim2.new(0,0,0,0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.Parent = Content
    local listLayout = Instance.new("UIListLayout", Page)
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    Instance.new("UIPadding", Page).PaddingTop = UDim.new(0, 8)

    Btn.MouseEnter:Connect(function()
        if CurrentPage ~= Page then
            Utils:Tween(Btn, TweenInfo.new(0.18), {TextColor3 = DarkMenu.UI.TextColor, BackgroundTransparency = 0.85, BackgroundColor3 = DarkMenu.UI.ItemColor})
        end
    end)
    Btn.MouseLeave:Connect(function()
        if CurrentPage ~= Page then
            Utils:Tween(Btn, TweenInfo.new(0.25), {TextColor3 = DarkMenu.UI.DimColor, BackgroundTransparency = 1})
        end
    end)

    local function Select()
        if CurrentPage then
            CurrentPage.Visible = false
            for _, t in pairs(Tabs) do
                Utils:Tween(t.Btn, TweenInfo.new(0.25), {TextColor3 = DarkMenu.UI.DimColor, BackgroundTransparency = 1})
                t.Btn.Font = Enum.Font.GothamMedium
                local ab = t.Btn:FindFirstChild("AccentBar")
                if ab then Utils:Tween(ab, TweenInfo.new(0.2), {BackgroundTransparency = 1}) end
            end
        end
        Page.Visible = true
        CurrentPage = Page
        Utils:Tween(Btn, TweenInfo.new(0.25), {TextColor3 = DarkMenu.UI.TextColor, BackgroundTransparency = 0.9, BackgroundColor3 = DarkMenu.UI.ItemColor})
        Btn.Font = Enum.Font.GothamBold
        Utils:Tween(AccentBar, TweenInfo.new(0.25), {BackgroundTransparency = 0})
    end

    Btn.MouseButton1Click:Connect(Select)
    
    Tabs[name] = {Btn = Btn, Page = Page, Select = Select}
    return Page
end

-- Profile Card at bottom
local Profile = Instance.new("Frame")
Profile.Size = UDim2.new(1, -16, 0, 54)
Profile.Position = UDim2.new(0, 8, 1, -120)
Profile.BackgroundColor3 = DarkMenu.UI.ItemColor
Profile.BorderSizePixel = 0
Profile.Parent = Sidebar
Instance.new("UICorner", Profile).CornerRadius = UDim.new(0, 10)
local ProfileStroke = Instance.new("UIStroke", Profile)
ProfileStroke.Color = DarkMenu.UI.BorderColor
ProfileStroke.Thickness = 1

local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.fromOffset(36, 36)
Avatar.Position = UDim2.new(0, 10, 0.5, -18)
Avatar.BackgroundColor3 = DarkMenu.UI.SecColor
Avatar.Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150"
Avatar.Parent = Profile
Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)

-- Online dot
local OnlineDot = Instance.new("Frame")
OnlineDot.Size = UDim2.fromOffset(10, 10)
OnlineDot.Position = UDim2.new(0, 36, 0, 34)
OnlineDot.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
OnlineDot.BorderSizePixel = 0
OnlineDot.Parent = Profile
Instance.new("UICorner", OnlineDot).CornerRadius = UDim.new(1, 0)

local UserText = Instance.new("TextLabel")
UserText.Size = UDim2.new(1, -56, 0, 19)
UserText.Position = UDim2.new(0, 54, 0, 9)
UserText.BackgroundTransparency = 1
UserText.Font = Enum.Font.GothamBold
UserText.Text = LocalPlayer.Name
UserText.TextColor3 = DarkMenu.UI.TextColor
UserText.TextSize = 13
UserText.TextXAlignment = Enum.TextXAlignment.Left
UserText.Parent = Profile

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -56, 0, 14)
StatusText.Position = UDim2.new(0, 54, 0, 30)
StatusText.BackgroundTransparency = 1
StatusText.Font = Enum.Font.Gotham
StatusText.Text = "Conectado"
StatusText.TextColor3 = Color3.fromRGB(34, 197, 94)
StatusText.TextSize = 10
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = Profile

-- Close / Hide button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(1, -16, 0, 36)
CloseBtn.Position = UDim2.new(0, 8, 1, -54)
CloseBtn.BackgroundColor3 = Color3.fromRGB(28, 14, 14)
CloseBtn.BorderSizePixel = 0
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "Esconder  [" .. DarkMenu.Settings.Misc.ToggleKey.Name .. "]"
CloseBtn.TextColor3 = Color3.fromRGB(239, 68, 68)
CloseBtn.TextSize = 12
CloseBtn.Parent = Sidebar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
local CBStroke = Instance.new("UIStroke", CloseBtn)
CBStroke.Color = Color3.fromRGB(100, 30, 30)
CBStroke.Thickness = 1
CloseBtn.MouseEnter:Connect(function() Utils:Tween(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 20, 20)}) end)
CloseBtn.MouseLeave:Connect(function() Utils:Tween(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(28, 14, 14)}) end)
CloseBtn.MouseButton1Click:Connect(function() ToggleUI(false) end)

-- Initial Toggle Key
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == DarkMenu.Settings.Misc.ToggleKey then ToggleUI() end
end)

-- Main Draggable
local mainDragging = false
local mainDragStart, mainStartPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        mainDragging = true
        mainDragStart = input.Position
        mainStartPos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if mainDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - mainDragStart
        Main.Position = UDim2.new(mainStartPos.X.Scale, mainStartPos.X.Offset + delta.X, mainStartPos.Y.Scale, mainStartPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then mainDragging = false end
end)

-- [[ COMPONENT FACTORY ]]
function Lib:AddSection(parent, name)
    local Wrap = Instance.new("Frame")
    Wrap.Size = UDim2.new(1, -12, 0, 26)
    Wrap.BackgroundTransparency = 1
    Wrap.LayoutOrder = #parent:GetChildren()
    Wrap.Parent = parent

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(0, 3, 0.65, 0)
    Bar.Position = UDim2.new(0, 0, 0.175, 0)
    Bar.BackgroundColor3 = DarkMenu.UI.AccentColor
    Bar.BorderSizePixel = 0
    Bar.Parent = Wrap
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 2)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -12, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.Text = name:upper()
    Label.TextColor3 = DarkMenu.UI.DimColor
    Label.TextSize = 10
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Wrap
end

function Lib:AddLabel(parent, name)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -12, 0, 28)
    Frame.BackgroundTransparency = 1
    Frame.LayoutOrder = #parent:GetChildren()
    Frame.Parent = parent
    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.new(1, 0, 1, 0)
    Text.BackgroundTransparency = 1
    Text.Font = Enum.Font.Gotham
    Text.Text = name
    Text.TextColor3 = DarkMenu.UI.DimColor
    Text.TextSize = 12
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.TextWrapped = true
    Text.Parent = Frame
    return Text
end

function Lib:AddToggle(parent, name, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -12, 0, 48)
    Frame.BackgroundColor3 = DarkMenu.UI.ItemColor
    Frame.LayoutOrder = #parent:GetChildren()
    Frame.Parent = parent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Color = DarkMenu.UI.BorderColor
    Stroke.Thickness = 1

    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.new(1, -72, 1, 0)
    Text.Position = UDim2.new(0, 14, 0, 0)
    Text.BackgroundTransparency = 1
    Text.Font = Enum.Font.GothamMedium
    Text.Text = name
    Text.TextColor3 = DarkMenu.UI.TextColor
    Text.TextSize = 13
    Text.TextWrapped = true
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.Parent = Frame

    -- Toggle pill
    local Pill = Instance.new("Frame")
    Pill.Size = UDim2.new(0, 40, 0, 22)
    Pill.Position = UDim2.new(1, -54, 0.5, -11)
    Pill.BackgroundColor3 = default and DarkMenu.UI.MainColor or DarkMenu.UI.BorderColor
    Pill.Parent = Frame
    Instance.new("UICorner", Pill).CornerRadius = UDim.new(0, 11)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = UDim2.new(default and 1 or 0, default and -19 or 3, 0.5, -8)
    Knob.BackgroundColor3 = Color3.new(1,1,1)
    Knob.Parent = Pill
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(0, 8)

    local Toggled = default
    local function Toggle()
        Toggled = not Toggled
        Utils:Tween(Pill, TweenInfo.new(0.28, Enum.EasingStyle.Quart), {BackgroundColor3 = Toggled and DarkMenu.UI.MainColor or DarkMenu.UI.BorderColor})
        Utils:Tween(Knob, TweenInfo.new(0.28, Enum.EasingStyle.Quart), {Position = Toggled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)})
        if callback then callback(Toggled) end
    end

    -- Invisible full-row TextButton (TextLabel can't receive clicks)
    local ClickBtn = Instance.new("TextButton")
    ClickBtn.Size = UDim2.new(1, 0, 1, 0)
    ClickBtn.BackgroundTransparency = 1
    ClickBtn.Text = ""
    ClickBtn.ZIndex = Frame.ZIndex + 2
    ClickBtn.Parent = Frame
    ClickBtn.MouseButton1Click:Connect(Toggle)

    ClickBtn.MouseEnter:Connect(function()
        Utils:Tween(Frame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(26, 26, 38)})
        Utils:Tween(Stroke, TweenInfo.new(0.15), {Color = DarkMenu.UI.AccentColor})
    end)
    ClickBtn.MouseLeave:Connect(function()
        Utils:Tween(Frame, TweenInfo.new(0.2), {BackgroundColor3 = DarkMenu.UI.ItemColor})
        Utils:Tween(Stroke, TweenInfo.new(0.2), {Color = DarkMenu.UI.BorderColor})
    end)
end

function Lib:AddSlider(parent, name, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -12, 0, 60)
    Frame.BackgroundColor3 = DarkMenu.UI.ItemColor
    Frame.LayoutOrder = #parent:GetChildren()
    Frame.Parent = parent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Color = DarkMenu.UI.BorderColor
    Stroke.Thickness = 1

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -16, 0, 30)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamMedium
    Label.Text = name
    Label.TextColor3 = DarkMenu.UI.TextColor
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ValLabel = Instance.new("TextLabel")
    ValLabel.Size = UDim2.new(0, 50, 0, 30)
    ValLabel.Position = UDim2.new(1, -60, 0, 0)
    ValLabel.BackgroundTransparency = 1
    ValLabel.Font = Enum.Font.GothamBold
    ValLabel.Text = tostring(default)
    ValLabel.TextColor3 = DarkMenu.UI.AccentColor
    ValLabel.TextSize = 13
    ValLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValLabel.Parent = Frame

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -24, 0, 4)
    Track.Position = UDim2.new(0, 12, 0, 44)
    Track.BackgroundColor3 = DarkMenu.UI.BorderColor
    Track.Parent = Frame
    Instance.new("UICorner", Track).CornerRadius = UDim.new(0, 2)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    Fill.BackgroundColor3 = DarkMenu.UI.MainColor
    Fill.Parent = Track
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 2)

    -- Thumb dot
    local Thumb = Instance.new("Frame")
    Thumb.Size = UDim2.fromOffset(12, 12)
    Thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    Thumb.Position = UDim2.new((default-min)/(max-min), 0, 0.5, 0)
    Thumb.BackgroundColor3 = Color3.new(1,1,1)
    Thumb.ZIndex = 3
    Thumb.Parent = Track
    Instance.new("UICorner", Thumb).CornerRadius = UDim.new(1, 0)

    local function Update(input)
        local per = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * per)
        ValLabel.Text = tostring(val)
        Utils:Tween(Fill, TweenInfo.new(0.1), {Size = UDim2.new(per, 0, 1, 0)})
        Utils:Tween(Thumb, TweenInfo.new(0.1), {Position = UDim2.new(per, 0, 0.5, 0)})
        if callback then callback(val) end
    end

    local Dragging = false
    Track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true Update(i) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
    UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Update(i) end end)

    Frame.MouseEnter:Connect(function()
        Utils:Tween(Frame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(26, 26, 38)})
        Utils:Tween(Stroke, TweenInfo.new(0.15), {Color = DarkMenu.UI.AccentColor})
    end)
    Frame.MouseLeave:Connect(function()
        Utils:Tween(Frame, TweenInfo.new(0.2), {BackgroundColor3 = DarkMenu.UI.ItemColor})
        Utils:Tween(Stroke, TweenInfo.new(0.2), {Color = DarkMenu.UI.BorderColor})
    end)
end

function Lib:AddButton(parent, name, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -12, 0, 44)
    Btn.BackgroundColor3 = DarkMenu.UI.ItemColor
    Btn.Font = Enum.Font.GothamBold
    Btn.Text = name
    Btn.TextColor3 = DarkMenu.UI.TextColor
    Btn.TextSize = 13
    Btn.LayoutOrder = #parent:GetChildren()
    Btn.Parent = parent
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)
    local BStroke = Instance.new("UIStroke", Btn)
    BStroke.Color = DarkMenu.UI.MainColor
    BStroke.Thickness = 1

    Btn.MouseEnter:Connect(function()
        Utils:Tween(Btn, TweenInfo.new(0.15), {BackgroundColor3 = DarkMenu.UI.MainColor})
        Utils:Tween(BStroke, TweenInfo.new(0.15), {Transparency = 1})
    end)
    Btn.MouseLeave:Connect(function()
        Utils:Tween(Btn, TweenInfo.new(0.2), {BackgroundColor3 = DarkMenu.UI.ItemColor})
        Utils:Tween(BStroke, TweenInfo.new(0.2), {Transparency = 0})
    end)
    Btn.MouseButton1Click:Connect(function()
        Utils:Tween(Btn, TweenInfo.new(0.08), {BackgroundColor3 = DarkMenu.UI.AccentColor})
        task.delay(0.15, function() Utils:Tween(Btn, TweenInfo.new(0.2), {BackgroundColor3 = DarkMenu.UI.ItemColor}) end)
        if callback then callback() end
    end)
end

function Lib:AddKeybind(parent, name, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -12, 0, 44)
    Frame.BackgroundColor3 = DarkMenu.UI.ItemColor
    Frame.LayoutOrder = #parent:GetChildren()
    Frame.Parent = parent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", Frame).Color = DarkMenu.UI.BorderColor

    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.new(1, -100, 1, 0)
    Text.Position = UDim2.new(0, 12, 0, 0)
    Text.BackgroundTransparency = 1
    Text.Font = Enum.Font.GothamMedium
    Text.Text = name
    Text.TextColor3 = DarkMenu.UI.TextColor
    Text.TextSize = 13
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.Parent = Frame

    local Bind = Instance.new("TextButton")
    Bind.Size = UDim2.new(0, 72, 0, 26)
    Bind.Position = UDim2.new(1, -84, 0.5, -13)
    Bind.BackgroundColor3 = DarkMenu.UI.SecColor
    Bind.Font = Enum.Font.GothamBold
    Bind.Text = default.Name
    Bind.TextColor3 = DarkMenu.UI.AccentColor
    Bind.TextSize = 11
    Bind.Parent = Frame
    Instance.new("UICorner", Bind).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", Bind).Color = DarkMenu.UI.BorderColor

    Bind.MouseButton1Click:Connect(function()
        Bind.Text = "..."
        Bind.TextColor3 = DarkMenu.UI.TextColor
        local conn; conn = UserInputService.InputBegan:Connect(function(input, gpe)
            local key = input.KeyCode
            if input.UserInputType == Enum.UserInputType.Keyboard and key ~= Enum.KeyCode.Unknown then
                Bind.Text = key.Name
                Bind.TextColor3 = DarkMenu.UI.AccentColor
                if callback then callback(key) end
                conn:Disconnect()
            elseif string.find(input.UserInputType.Name, "MouseButton") and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
                Bind.Text = input.UserInputType.Name
                Bind.TextColor3 = DarkMenu.UI.AccentColor
                if callback then callback(input.UserInputType) end
                conn:Disconnect()
            end
        end)
    end)
end

-- [[ CREATE PRO TABS ]]
print("[DarkMenu] Configurando menu de elite...")
local PageAssist = Lib:CreateTab("Assist", "🎯")
local PagePlayer = Lib:CreateTab("Player", "🏃")
local PageVision = Lib:CreateTab("Vision", "👁️")
local PagePlayersList = Lib:CreateTab("Players", "👥")
local PageMisc = Lib:CreateTab("System", "⚙️")

local function CreateSubFrame(parentTab, order)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 0)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = order
    frame.Visible = false
    frame.Parent = parentTab
    local l = Instance.new("UIListLayout", frame)
    l.Padding = UDim.new(0, 12)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    return frame
end

local function CreateSubNav(parentPage, tabNames)
    local Nav = Instance.new("Frame")
    Nav.Size = UDim2.new(1, 0, 0, 36)
    Nav.BackgroundColor3 = DarkMenu.UI.SecColor
    Nav.BorderSizePixel = 0
    Nav.LayoutOrder = -999
    Nav.Parent = parentPage
    Instance.new("UICorner", Nav).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", Nav).Color = DarkMenu.UI.BorderColor
    local NavLayout = Instance.new("UIListLayout", Nav)
    NavLayout.FillDirection = Enum.FillDirection.Horizontal
    NavLayout.Padding = UDim.new(0, 4)
    NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NavLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    NavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Instance.new("UIPadding", Nav).PaddingLeft = UDim.new(0, 4)

    local frames = {}
    local btns = {}
    local btnWidth = 1 / #tabNames

    for i, name in ipairs(tabNames) do
        local frame = CreateSubFrame(parentPage, i)
        table.insert(frames, frame)

        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(btnWidth, -8, 0, 28)
        Btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
        Btn.BackgroundTransparency = 1
        Btn.Font = Enum.Font.GothamMedium
        Btn.Text = name
        Btn.TextColor3 = DarkMenu.UI.DimColor
        Btn.TextSize = 12
        Btn.LayoutOrder = i
        Btn.Parent = Nav
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

        Btn.MouseButton1Click:Connect(function()
            for _, f in pairs(frames) do f.Visible = false end
            for _, b in pairs(btns) do
                b.TextColor3 = DarkMenu.UI.DimColor
                b.BackgroundTransparency = 1
                b.Font = Enum.Font.GothamMedium
            end
            frame.Visible = true
            Btn.TextColor3 = DarkMenu.UI.TextColor
            Btn.BackgroundTransparency = 0
            Btn.BackgroundColor3 = DarkMenu.UI.MainColor
            Btn.Font = Enum.Font.GothamBold
        end)
        table.insert(btns, Btn)
    end

    -- Default active: first tab
    frames[1].Visible = true
    btns[1].TextColor3 = DarkMenu.UI.TextColor
    btns[1].BackgroundTransparency = 0
    btns[1].BackgroundColor3 = DarkMenu.UI.MainColor
    btns[1].Font = Enum.Font.GothamBold

    return table.unpack(frames)
end

-- Initialize ALL Sub-Tabs
local PageSilent, PageHitbox, PageAim, PageTrigger = CreateSubNav(PageAssist, {"Magic", "Body", "Aim", "Trigger"})
local PageMove, PageFly = CreateSubNav(PagePlayer, {"Move", "Fly"})
local PageVisionESP, PageVisionVisuals = CreateSubNav(PageVision, {"ESP", "Visuals"})
local PageMiscFarm, PageMiscSecurity, PageMiscConfig = CreateSubNav(PageMisc, {"Farm", "Security", "Config"})

-- Auto-select first tab on load
task.defer(function()
    if Tabs["Assist"] then
        local ab = Tabs["Assist"].Btn:FindFirstChild("AccentBar")
        if ab then Utils:Tween(ab, TweenInfo.new(0.3), {BackgroundTransparency = 0}) end
        Tabs["Assist"].Page.Visible = true
        CurrentPage = Tabs["Assist"].Page
        Tabs["Assist"].Btn.TextColor3 = DarkMenu.UI.TextColor
        Tabs["Assist"].Btn.Font = Enum.Font.GothamBold
        Tabs["Assist"].Btn.BackgroundTransparency = 0.9
        Tabs["Assist"].Btn.BackgroundColor3 = DarkMenu.UI.ItemColor
    end
end)

-- [[ PLAYERS LIST IMPLEMENTATION ]]
Lib:AddSection(PagePlayersList, "📜 Lista do Servidor")
Lib:AddLabel(PagePlayersList, "Interage diretamente com qualquer jogador no mapa.")

local function CreatePlayerCard(player)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, -20, 0, 75)
    Card.BackgroundColor3 = DarkMenu.UI.ItemColor
    Card.LayoutOrder = #PagePlayersList:GetChildren()
    Card.Parent = PagePlayersList
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", Card).Color = Color3.fromRGB(40, 40, 50)
    
    local Avatar = Instance.new("ImageLabel")
    Avatar.Size = UDim2.fromOffset(45, 45)
    Avatar.Position = UDim2.new(0, 15, 0.5, -22.5)
    Avatar.BackgroundColor3 = DarkMenu.UI.SecColor
    
    task.spawn(function()
        local success, img = pcall(function()
            return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if success then Avatar.Image = img end
    end)
    Avatar.Parent = Card
    Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)
    
    local Name = Instance.new("TextLabel")
    Name.Size = UDim2.new(0.5, -70, 0, 20)
    Name.Position = UDim2.new(0, 75, 0.5, -18)
    Name.BackgroundTransparency = 1
    Name.Font = Enum.Font.GothamBold
    Name.Text = player.DisplayName
    Name.TextColor3 = DarkMenu.UI.TextColor
    Name.TextSize = 13
    Name.TextXAlignment = Enum.TextXAlignment.Left
    Name.Parent = Card
    
    local User = Instance.new("TextLabel")
    User.Size = UDim2.new(0.5, -70, 0, 15)
    User.Position = UDim2.new(0, 75, 0.5, 2)
    User.BackgroundTransparency = 1
    User.Font = Enum.Font.Gotham
    User.Text = "@" .. player.Name
    User.TextColor3 = DarkMenu.UI.DimColor
    User.TextSize = 11
    User.TextXAlignment = Enum.TextXAlignment.Left
    User.Parent = Card
    
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Size = UDim2.new(0.5, 0, 1, 0)
    ButtonFrame.Position = UDim2.new(0.5, 0, 0, 0)
    ButtonFrame.BackgroundTransparency = 1
    ButtonFrame.Parent = Card
    local ButtonLayout = Instance.new("UIListLayout", ButtonFrame)
    ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
    ButtonLayout.Padding = UDim.new(0, 8)
    ButtonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    Instance.new("UIPadding", ButtonFrame).PaddingRight = UDim.new(0, 15)
    
    local function makeSmallBtn(text, color, cb)
        local b = Instance.new("TextButton")
        b.Size = UDim2.fromOffset(50, 28)
        b.BackgroundColor3 = color
        b.Font = Enum.Font.GothamBold
        b.Text = text
        b.TextColor3 = Color3.new(1,1,1)
        b.TextSize = 11
        b.Parent = ButtonFrame
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        b.MouseButton1Click:Connect(cb)
        return b
    end
    
    makeSmallBtn("🎯 TP", DarkMenu.UI.MainColor, function()
        local char = Utils:GetCharacter(LocalPlayer)
        local target = Utils:GetRoot(Utils:GetCharacter(player))
        if char and target then char:PivotTo(target.CFrame * CFrame.new(0, 5, 0)) end
    end)
    
    local isSpec = false
    makeSmallBtn("👁️ VER", DarkMenu.UI.AccentColor, function()
        isSpec = not isSpec
        if isSpec then
            Camera.CameraSubject = Utils:GetHumanoid(Utils:GetCharacter(player))
            Utils:Notify("Spectate", "Assistindo " .. player.DisplayName, 3)
        else
            Camera.CameraSubject = Utils:GetHumanoid(Utils:GetCharacter(LocalPlayer))
        end
    end)
    
    makeSmallBtn("🧲 PUXAR", Color3.fromRGB(245, 158, 11), function()
        local targetChar = Utils:GetCharacter(player)
        local targetRoot = Utils:GetRoot(targetChar)
        local lChar = Utils:GetCharacter(LocalPlayer)
        local lRoot = Utils:GetRoot(lChar)
        
        if targetRoot and lRoot then
            -- Tenta forçar a posição do alvo para frente do LocalPlayer
            local offset = CFrame.new(0, 0, -3)
            pcall(function() targetRoot.CFrame = lRoot.CFrame * offset end)
            
            -- Tenta anexar BodyPosition para casos de Physics Bypass
            pcall(function()
                local bp = Instance.new("BodyPosition")
                bp.MaxForce = Vector3.new(100000, 100000, 100000)
                bp.Position = (lRoot.CFrame * offset).Position
                bp.D = 100
                bp.P = 5000
                bp.Parent = targetRoot
                task.delay(0.5, function() if bp then bp:Destroy() end end)
            end)
            
            Utils:Notify("Bring Player", "Puxando " .. player.DisplayName .. "...", 3)
        end
    end)
end

local function UpdatePlayersList()
    for _, v in pairs(PagePlayersList:GetChildren()) do 
        if v:IsA("Frame") and v.Name == "Frame" and v.Size.Y.Offset == 75 then v:Destroy() end 
    end
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreatePlayerCard(p) end end
end

Players.PlayerAdded:Connect(UpdatePlayersList)
Players.PlayerRemoving:Connect(UpdatePlayersList)
UpdatePlayersList()

-- [[ MAGIC TAB (SILENT AIM) ]]
Lib:AddSection(PageSilent, "🔮 Magia Direta [SILENT AIM]")
Lib:AddLabel(PageSilent, "Curva e acerta os tiros magicamente sem mexer a câmara.")
Lib:AddToggle(PageSilent, "🔫 Ativar Silent Aim", false, function(v) DarkMenu.Settings.Aimbot.Silent = v end)
Lib:AddKeybind(PageSilent, "Tecla Atalho Silent", DarkMenu.Settings.Aimbot.SilentKey, function(v) DarkMenu.Settings.Aimbot.SilentKey = v end)
Lib:AddSlider(PageSilent, "Raio de Ação (FOV)", 10, 800, 200, function(v) DarkMenu.Settings.Aimbot.SilentFOV = v end)
Lib:AddToggle(PageSilent, "Atirar Atrás das Paredes", true, function(v) DarkMenu.Settings.Aimbot.VisibleCheck = not v end)
Lib:AddToggle(PageSilent, "Predição de Movimento", false, function(v) DarkMenu.Settings.Aimbot.Prediction = v end)

-- [[ BODY TAB (HITBOX) ]]
Lib:AddSection(PageHitbox, "🧊 Facilitador de Tiros [HITBOX]")
Lib:AddLabel(PageHitbox, "Aumenta o impacto e tamanho físico dos inimigos.")
Lib:AddToggle(PageHitbox, "🧊 Expandir Corpo (Hitbox)", false, function(v)
    DarkMenu.Settings.Aimbot.HitboxExpander = v
    if not v then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local root = p.Character:FindFirstChild("HumanoidRootPart")
                if root then root.Size = Vector3.new(2, 2, 1) end
            end
        end
    end
end)
Lib:AddKeybind(PageHitbox, "Tecla Atalho Hitbox", DarkMenu.Settings.Aimbot.HitboxKey, function(v) DarkMenu.Settings.Aimbot.HitboxKey = v end)
Lib:AddSlider(PageHitbox, "Tamanho da Expansão", 5, 200, 50, function(v) DarkMenu.Settings.Aimbot.HitboxSize = v end)
Lib:AddToggle(PageHitbox, "Ignorar a minha Equipa", true, function(v) DarkMenu.Settings.Aimbot.Team = v end)

-- [[ AIMBOT TAB ]]
Lib:AddSection(PageAim, "🎯 Assistência [AIMBOT CÂMERA]")
Lib:AddLabel(PageAim, "Move a tua câmara suavemente para trancar nos alvos.")
Lib:AddToggle(PageAim, "🎯 Ativar Aimbot", false, function(v) DarkMenu.Settings.Aimbot.Enabled = v end)
Lib:AddKeybind(PageAim, "Tecla Segurar Mira", DarkMenu.Settings.Aimbot.Key, function(v) DarkMenu.Settings.Aimbot.Key = v end)
Lib:AddKeybind(PageAim, "Tecla Atalho Ligar/Desligar", DarkMenu.Settings.Aimbot.AimbotKey, function(v) DarkMenu.Settings.Aimbot.AimbotKey = v end)
Lib:AddSlider(PageAim, "Abertura do FOV", 10, 800, 100, function(v) DarkMenu.Settings.Aimbot.FOV = v end)
Lib:AddSlider(PageAim, "Suavidade (Smoothness)", 1, 20, 5, function(v) DarkMenu.Settings.Aimbot.Smooth = v end)

-- [[ TRIGGER TAB ]]
Lib:AddSection(PageTrigger, "⚡ Disparo Automático [TRIGGERBOT]")
Lib:AddLabel(PageTrigger, "Se a mira tocar num inimigo, a arma dispara sozinha.")
Lib:AddToggle(PageTrigger, "⚡ Ativar Auto-Tiro", false, function(v) DarkMenu.Settings.Aimbot.Triggerbot = v end)
Lib:AddKeybind(PageTrigger, "Tecla Atalho Trigger", DarkMenu.Settings.Aimbot.TriggerKey, function(v) DarkMenu.Settings.Aimbot.TriggerKey = v end)
Lib:AddSlider(PageTrigger, "Atraso no Tiro (ms)", 0, 500, 0, function(v) DarkMenu.Settings.Aimbot.TriggerDelay = v / 1000 end)

-- [[ MOVE TAB (PHYSICS) ]]
Lib:AddSection(PageMove, "🏃‍♂️ Mudança Genética [FÍSICO]")
Lib:AddLabel(PageMove, "Altera as regras e limites básicos da física do teu avatar.")
    if DarkMenu.Settings.Player.BringKey == nil then DarkMenu.Settings.Player.BringKey = Enum.KeyCode.H end
Lib:AddKeybind(PageMove, "🧲 Puxar Jogador na Mira", DarkMenu.Settings.Player.BringKey, function(v) DarkMenu.Settings.Player.BringKey = v end)
Lib:AddSlider(PageMove, "⚡ Velocidade (WalkSpeed)", 16, 300, 16, function(v) DarkMenu.Settings.Player.WS = v end)
Lib:AddSlider(PageMove, "🦘 Força do Pulo (JumpPower)", 50, 500, 50, function(v) DarkMenu.Settings.Player.JP = v end)
Lib:AddSlider(PageMove, "🪐 Nível da Gravidade do Mundo", 0, 500, 196, function(v) workspace.Gravity = v end)
Lib:AddToggle(PageMove, "♾️ Pular Infinitamente no Ar", false, function(v) DarkMenu.Settings.Player.InfJump = v end)
Lib:AddToggle(PageMove, "🌪️ Ativar Spinbot (Rodar a Câmera)", false, function(v) DarkMenu.Settings.Player.Spinbot = v end)
Lib:AddSlider(PageMove, "⚡ Velocidade do Spinbot", 1, 100, 20, function(v) DarkMenu.Settings.Player.SpinSpeed = v end)
Lib:AddSlider(PageMove, "👁️ Alterar FOV da Tela", 10, 120, 70, function(v) DarkMenu.Settings.Player.FOV = v workspace.CurrentCamera.FieldOfView = v end)
Lib:AddToggle(PageMove, "👻 Atravessar Paredes (Noclip)", false, function(v)
    DarkMenu.Settings.Player.Noclip = v
    if not v then
        local char = Utils:GetCharacter(LocalPlayer)
        if char then
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end
end)

-- [[ FLY TAB (PILOT) ]]
Lib:AddSection(PageFly, "✈️ Voo Livre [PILOT]")
Lib:AddLabel(PageFly, "Ignora o chão e voa livremente pelo mapa num estado de flutuação.")

local function StopFly()
    local char = Utils:GetCharacter(LocalPlayer)
    if char then
        local root = Utils:GetRoot(char)
        if root then
            if root:FindFirstChild("DarkMenu_FlyV") then root.DarkMenu_FlyV:Destroy() end
            if root:FindFirstChild("DarkMenu_FlyG") then root.DarkMenu_FlyG:Destroy() end
        end
        local hum = Utils:GetHumanoid(char)
        if hum then hum.PlatformStand = false end
    end
    if DarkMenu.Connections.Fly then
        DarkMenu.Connections.Fly:Disconnect()
        DarkMenu.Connections.Fly = nil
    end
end

local function StartFly()
    local char = Utils:GetCharacter(LocalPlayer)
    if not char then return end
    local root = Utils:GetRoot(char)
    local hum = Utils:GetHumanoid(char)
    if not root or not hum then return end

    StopFly() -- Ensure clean slate

    local bv = Instance.new("BodyVelocity")
    bv.Name = "DarkMenu_FlyV"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = root
    
    local bg = Instance.new("BodyGyro")
    bg.Name = "DarkMenu_FlyG"
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 10000
    bg.D = 1000
    bg.CFrame = Camera.CFrame
    bg.Parent = root
    
    hum.PlatformStand = true

    DarkMenu.Connections.Fly = RunService.RenderStepped:Connect(function()
        if not char or not root or not root.Parent or hum.Health <= 0 then
            StopFly()
            DarkMenu.Settings.Player.Fly = false
            return
        end
        
        local speed = DarkMenu.Settings.Player.FlySpeed
        local moveVector = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVector = moveVector - Vector3.new(0, 1, 0) end
        
        bv.Velocity = moveVector.Magnitude > 0 and moveVector.Unit * speed or Vector3.new(0, 0, 0)
        bg.CFrame = Camera.CFrame
    end)
end

Lib:AddToggle(PageFly, "🛸 Ativar Modo de Voo", false, function(v) 
    DarkMenu.Settings.Player.Fly = v 
    if v then StartFly() else StopFly() end
end)
Lib:AddKeybind(PageFly, "Controlo: Tecla do Voo", DarkMenu.Settings.Player.FlyKey, function(v) DarkMenu.Settings.Player.FlyKey = v end)
Lib:AddSlider(PageFly, "🚀 Velocidade Aérea Excedente", 50, 500, 50, function(v) DarkMenu.Settings.Player.FlySpeed = v end)

-- [[ GLOBAL KEYBIND LISTENER ]]
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    local key = (input.UserInputType == Enum.UserInputType.Keyboard) and input.KeyCode or input.UserInputType
    if key == Enum.KeyCode.Unknown then return end
    
    if key == DarkMenu.Settings.Misc.ToggleKey then ToggleUI() return end
    
    -- Feature Toggles
    if key == DarkMenu.Settings.Aimbot.SilentKey then
        DarkMenu.Settings.Aimbot.Silent = not DarkMenu.Settings.Aimbot.Silent
        Utils:Notify("Magic", DarkMenu.Settings.Aimbot.Silent and "Silent Aim ATIVADO!" or "Silent Aim Desativado", 2)
    elseif key == DarkMenu.Settings.Aimbot.HitboxKey then
        DarkMenu.Settings.Aimbot.HitboxExpander = not DarkMenu.Settings.Aimbot.HitboxExpander
        if not DarkMenu.Settings.Aimbot.HitboxExpander then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local r = p.Character:FindFirstChild("HumanoidRootPart")
                    if r then r.Size = Vector3.new(2, 2, 1) end
                end
            end
        end
        Utils:Notify("Body", DarkMenu.Settings.Aimbot.HitboxExpander and "Hitbox Expander ATIVADO!" or "Hitbox Resetado", 2)
    elseif key == DarkMenu.Settings.Aimbot.AimbotKey then
        DarkMenu.Settings.Aimbot.Enabled = not DarkMenu.Settings.Aimbot.Enabled
        Utils:Notify("Aim", DarkMenu.Settings.Aimbot.Enabled and "Camera Aimbot ATIVADO!" or "Aimbot Desativado", 2)
    elseif key == DarkMenu.Settings.Aimbot.TriggerKey then
        DarkMenu.Settings.Aimbot.Triggerbot = not DarkMenu.Settings.Aimbot.Triggerbot
        Utils:Notify("Trigger", DarkMenu.Settings.Aimbot.Triggerbot and "Triggerbot ATIVADO!" or "Triggerbot Desativado", 2)
    elseif key == DarkMenu.Settings.ESP.ToggleKey then
        DarkMenu.Settings.ESP.Enabled = not DarkMenu.Settings.ESP.Enabled
        Utils:Notify("Vision", DarkMenu.Settings.ESP.Enabled and "ESP Global ATIVADO!" or "ESP Desativado", 2)
    elseif key == DarkMenu.Settings.Misc.KillAuraKey then
        DarkMenu.Settings.Misc.KillAura = not DarkMenu.Settings.Misc.KillAura
        Utils:Notify("System", DarkMenu.Settings.Misc.KillAura and "Kill Aura ATIVADO!" or "Kill Aura Desativado", 2)
    elseif key == DarkMenu.Settings.Misc.AntiAFKKey then
        DarkMenu.Settings.Misc.AntiAFK = not DarkMenu.Settings.Misc.AntiAFK
        Utils:Notify("System", DarkMenu.Settings.Misc.AntiAFK and "Anti-AFK ATIVADO!" or "Anti-AFK Desativado", 2)
    elseif key == DarkMenu.Settings.Misc.AutoClickerKey then
        DarkMenu.Settings.Misc.AutoClicker = not DarkMenu.Settings.Misc.AutoClicker
        Utils:Notify("System", DarkMenu.Settings.Misc.AutoClicker and "Auto-Clicker ATIVADO!" or "Auto-Clicker Desativado", 2)
    elseif key == DarkMenu.Settings.Player.FlyKey then
        DarkMenu.Settings.Player.Fly = not DarkMenu.Settings.Player.Fly
        if DarkMenu.Settings.Player.Fly then StartFly() else StopFly() end
        Utils:Notify("Player", DarkMenu.Settings.Player.Fly and "Voo ATIVADO!" or "Voo Desativado", 2)
    elseif key == DarkMenu.Settings.Player.BringKey or (not DarkMenu.Settings.Player.BringKey and key == Enum.KeyCode.H) then
        -- BRING LOOP: Puxa continuamente enquanto a tecla é segurada
        if DarkMenu.Connections.BringLoop then return end -- Já está a correr
        local bringTarget = GetClosest(nil, true)
        if bringTarget then
            Utils:Notify("Bring Player", "A puxar: " .. bringTarget.DisplayName .. " [Segura H]", 3)
            DarkMenu.Connections.BringLoop = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local tChar = Utils:GetCharacter(bringTarget)
                    local tRoot = Utils:GetRoot(tChar)
                    local lRoot = Utils:GetRoot(Utils:GetCharacter(LocalPlayer))
                    if tRoot and lRoot then
                        local dest = lRoot.CFrame * CFrame.new(0, 0, -2.5)
                        -- Método 1: CFrame direto
                        tRoot.CFrame = dest
                        -- Método 2: BodyPosition reforçada (para FE parcial)
                        local bp = tRoot:FindFirstChild("DM_BP") or Instance.new("BodyPosition")
                        bp.Name = "DM_BP"
                        bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bp.Position = dest.Position
                        bp.D = 500
                        bp.P = math.huge
                        bp.Parent = tRoot
                        -- Método 3: Velocity Slam (manda no direito)
                        tRoot.Velocity = (dest.Position - tRoot.Position) * 20
                    end
                end)
            end)
        end
    end
end)

-- Solta o Bring quando a tecla é largada
UserInputService.InputEnded:Connect(function(input, processed)
    local key = (input.UserInputType == Enum.UserInputType.Keyboard) and input.KeyCode or input.UserInputType
    local bringKey = DarkMenu.Settings.Player.BringKey or Enum.KeyCode.H
    if key == bringKey then
        if DarkMenu.Connections.BringLoop then
            DarkMenu.Connections.BringLoop:Disconnect()
            DarkMenu.Connections.BringLoop = nil
            -- Limpa BodyPosition residual
            pcall(function()
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local r = Utils:GetRoot(p.Character)
                        if r then
                            local bp = r:FindFirstChild("DM_BP")
                            if bp then bp:Destroy() end
                        end
                    end
                end
            end)
            Utils:Notify("Bring Player", "Puxão terminado.", 1)
        end
    end
end)

-- [[ VISION TAB: CORE ESP ]]
Lib:AddSection(PageVisionESP, "👁️ Onisciência [ESP MASTER]")
Lib:AddLabel(PageVisionESP, "Enxerga todos os jogadores através das paredes do mapa.")
Lib:AddToggle(PageVisionESP, "🌟 Ligar ESP Global", false, function(v) DarkMenu.Settings.ESP.Enabled = v end)
Lib:AddKeybind(PageVisionESP, "Tecla Atalho ESP", DarkMenu.Settings.ESP.ToggleKey, function(v) DarkMenu.Settings.ESP.ToggleKey = v end)
Lib:AddToggle(PageVisionESP, "🤝 Ocultar Aliados (Team Check)", false, function(v) DarkMenu.Settings.ESP.Team = v end)
Lib:AddSlider(PageVisionESP, "🔭 Distância de Visão Máxima", 100, 5000, 2000, function(v) DarkMenu.Settings.ESP.MaxDist = v end)

-- [[ VISION TAB: VISUALS ]]
Lib:AddSection(PageVisionVisuals, "🎨 Desenhos na Tela [ELEMENTOS]")
Lib:AddLabel(PageVisionVisuals, "Escolhe exatamente que informação ver por cima dos inimigos.")
Lib:AddToggle(PageVisionVisuals, "🏷️ Mostrar Nomes da Conta", false, function(v) DarkMenu.Settings.ESP.Name = v end)
Lib:AddToggle(PageVisionVisuals, "🟩 Caixas de Contorno (Box 2D)", false, function(v) DarkMenu.Settings.ESP.Box = v end)
Lib:AddToggle(PageVisionVisuals, "❤️ Barras de Vida Restante", false, function(v) DarkMenu.Settings.ESP.Health = v end)
Lib:AddToggle(PageVisionVisuals, "🧵 Linhas Direcionais (Tracers)", false, function(v) DarkMenu.Settings.ESP.Tracers = v end)
Lib:AddToggle(PageVisionVisuals, "🟥 Quadrado de Hitbox (3D)", false, function(v) DarkMenu.Settings.ESP.ShowHitbox = v end)

Lib:AddSection(PageVisionVisuals, "🦴 Esqueleto & Cores [SKELETON]")
Lib:AddToggle(PageVisionVisuals, "☠️ Desenhar Esqueleto (Bones)", false, function(v) DarkMenu.Settings.ESP.Skeleton = v end)
Lib:AddToggle(PageVisionVisuals, "🩸 Preenchimento da Caixa (Box Fill)", false, function(v) DarkMenu.Settings.ESP.BoxFill = v end)

-- [[ MISC TAB: SECURITY ]]
Lib:AddSection(PageMiscSecurity, "🛡️ Escudo & Segurança [STEALTH]")
Lib:AddLabel(PageMiscSecurity, "Esconde o menu inteiramente das gravações e partilhas de ecrã.")
Lib:AddToggle(PageMiscSecurity, "📹 Modo Invisível (Stream-Proof)", false, function(v)
    DarkMenu.Settings.Misc.StreamProof = v
    pcall(function()
        if set_drawing_screen_capture then set_drawing_screen_capture(not v) end
    end)
    Utils:Notify("Stream Mod", v and "Ativado! Totalmente invisível na Stream." or "Desativado!", 3)
end)

Lib:AddSection(PageMiscSecurity, "🔑 Licença de Acesso [SECURITY]")
Lib:AddLabel(PageMiscSecurity, "Mostra a validade do teu acesso autêntico ao DarkMenu.")
local KeyStatusLabel = Lib:AddLabel(PageMiscSecurity, "⏳ Key Status: Processando...")
task.spawn(function()
    while task.wait(1) do
        if DarkMenu.Settings.Misc.KeyExpiresAt then
            local timeLeft = math.floor(DarkMenu.Settings.Misc.KeyExpiresAt - os.time())
            if timeLeft > 0 then
                local h = math.floor(timeLeft / 3600)
                local m = math.floor((timeLeft % 3600) / 60)
                local s = timeLeft % 60
                KeyStatusLabel.Text = string.format("🔐 Sua Key Expira em: %02d:%02d:%02d", h, m, s)
            else
                KeyStatusLabel.Text = "❌ Sua Key Expirou! Pegue outra no Discord."
            end
        else
            KeyStatusLabel.Text = "🔐 Key Atual: DEV Bypass"
        end
    end
end)

-- [[ MISC TAB: FARM ]]
Lib:AddSection(PageMiscFarm, "⚔️ Aniquilação Automática [AUTO-KILL]")
Lib:AddLabel(PageMiscFarm, "Mata cruelmente e de forma silenciosa quem chegar perto.")
Lib:AddToggle(PageMiscFarm, "☠️ Ativar Kill Aura (TP-Kill)", false, function(v) DarkMenu.Settings.Misc.KillAura = v end)
Lib:AddKeybind(PageMiscFarm, "Tecla Atalho Kill Aura", DarkMenu.Settings.Misc.KillAuraKey, function(v) DarkMenu.Settings.Misc.KillAuraKey = v end)
Lib:AddSlider(PageMiscFarm, "📏 Distância Fatal do Aura", 50, 2000, 100, function(v) DarkMenu.Settings.Misc.AuraRange = v end)

Lib:AddSection(PageMiscFarm, "🤖 Programação [FARMING]")
Lib:AddLabel(PageMiscFarm, "Tarefas aborrecidas agora são automatizadas para ti.")
Lib:AddToggle(PageMiscFarm, "💤 Bloquear Desconexão (Anti-AFK)", false, function(v) DarkMenu.Settings.Misc.AntiAFK = v end)
Lib:AddKeybind(PageMiscFarm, "Tecla Atalho Anti-AFK", DarkMenu.Settings.Misc.AntiAFKKey, function(v) DarkMenu.Settings.Misc.AntiAFKKey = v end)
Lib:AddToggle(PageMiscFarm, "🖱️ Auto-Clicar Global (Auto-Clicker)", false, function(v) DarkMenu.Settings.Misc.AutoClicker = v end)
Lib:AddKeybind(PageMiscFarm, "Tecla Atalho Auto-Clicker", DarkMenu.Settings.Misc.AutoClickerKey, function(v) DarkMenu.Settings.Misc.AutoClickerKey = v end)

-- [[ MISC TAB: CONFIG ]]
Lib:AddSection(PageMiscConfig, "⚙️ Painel Central [SISTEMA]")
Lib:AddLabel(PageMiscConfig, "Ajusta os funcionamentos base da estrutura do DarkMenu.")
Lib:AddKeybind(PageMiscConfig, "⌨️ Tecla Ocultar Menu", DarkMenu.Settings.Misc.ToggleKey, function(v) DarkMenu.Settings.Misc.ToggleKey = v end)
Lib:AddButton(PageMiscConfig, "💾 Guardar Configurações no Ficheiro", function() Utils:SaveConfig() end)
Lib:AddButton(PageMiscConfig, "📂 Restaurar Configurações Inteligentes", function() Utils:LoadConfig() end)

Lib:AddSection(PageMiscConfig, "🚨 Pânico & Emergência [DANGER]")
Lib:AddLabel(PageMiscConfig, "Destrói todos os vestígios da injeção na tua sessão Roblox.")
Lib:AddButton(PageMiscConfig, "🧨 Desinstalar Menu Instantaneamente", function()
    pcall(function()
        DarkMenu.Settings.Aimbot.Enabled = false
        DarkMenu.Settings.Aimbot.Silent = false
        DarkMenu.Settings.Aimbot.Triggerbot = false
        DarkMenu.Settings.Player.Fly = false
        DarkMenu.Settings.ESP.Enabled = false
        DarkMenu.Settings.Misc.KillAura = false
        DarkMenu.Settings.Misc.AutoClicker = false
        DarkMenu.Settings.Misc.AntiAFK = false
    end)
    
    pcall(function() if StopFly then StopFly() end end)

    pcall(function()
        local char = Utils:GetCharacter(LocalPlayer)
        local hum = Utils:GetHumanoid(char)
        if hum then hum.WalkSpeed = 16 hum.JumpPower = 50 end
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end
        if Camera.CameraSubject ~= hum then Camera.CameraSubject = hum end
    end)
    
    pcall(function()
        workspace.Gravity = 196.2
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.Brightness = 1
    end)
    
    pcall(function()
        if FOVCircle then FOVCircle:Remove() end
        for _, e in pairs(ESP_Map) do
            if type(e) == "table" then
                for _, v in pairs(e) do
                    if type(v) == "table" then pcall(function() for _, l in pairs(v) do l:Remove() end end) else pcall(function() v:Remove() end) end
                end
            end
        end
    end)
    
    pcall(function()
        for _, con in pairs(DarkMenu.Connections) do pcall(function() con:Disconnect() end) end
    end)
    
    pcall(function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local r = p.Character:FindFirstChild("HumanoidRootPart")
                if r then r.Size = Vector3.new(2, 2, 1) end
            end
        end
    end)
    
    pcall(function() ScreenGui:Destroy() end)
    getgenv().DarkMenuExecuted = nil
    
    print("[DarkMenu] Menu desinstalado com sucesso.")
end)

-- [[ TRIGGERBOT LOOP ]]
task.spawn(function()
    while task.wait() do
        if DarkMenu.Settings.Aimbot.Triggerbot and not DarkMenu.UI.Visible then
            local ok, err = pcall(function()
                local target = Mouse.Target
                if target and target.Parent then
                    local character = target.Parent
                    if not character:FindFirstChild("Humanoid") then
                        character = character.Parent
                    end
                    
                    local hum = character:FindFirstChild("Humanoid")
                    local p = Players:GetPlayerFromCharacter(character)
                    
                    if hum and hum.Health > 0 and p and p ~= LocalPlayer then
                        if DarkMenu.Settings.Aimbot.Team and p.Team == LocalPlayer.Team then return end
                        
                        task.wait(DarkMenu.Settings.Aimbot.TriggerDelay or 0)
                        mouse1click() -- Standard Xeno/Executor function
                    end
                end
            end)
            if not ok then warn("DarkMenu Triggerbot Error: " .. tostring(err)) end
        end
    end
end)

-- [[ NOTIFICATION SYSTEM ]]
local Notifications = Instance.new("Frame")
Notifications.Size = UDim2.new(0, 260, 1, 0)
Notifications.Position = UDim2.new(1, -270, 0, 0)
Notifications.BackgroundTransparency = 1
Notifications.Parent = ScreenGui
local NotifLayout = Instance.new("UIListLayout", Notifications)
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.Padding = UDim.new(0, 10)
Instance.new("UIPadding", Notifications).PaddingBottom = UDim.new(0, 20)

function Utils:Notify(title, text, duration)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 70)
    Frame.BackgroundColor3 = DarkMenu.UI.SecColor
    Frame.BackgroundTransparency = 1
    Frame.Parent = Notifications
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", Frame).Color = DarkMenu.UI.MainColor
    
    local T = Instance.new("TextLabel")
    T.Size = UDim2.new(1, -20, 0, 30)
    T.Position = UDim2.new(0, 10, 0, 5)
    T.BackgroundTransparency = 1
    T.Font = Enum.Font.GothamBold
    T.Text = title:upper()
    T.TextColor3 = DarkMenu.UI.MainColor
    T.TextSize = 13
    T.TextXAlignment = Enum.TextXAlignment.Left
    T.Parent = Frame
    
    local D = Instance.new("TextLabel")
    D.Size = UDim2.new(1, -20, 0, 30)
    D.Position = UDim2.new(0, 10, 0, 30)
    D.BackgroundTransparency = 1
    D.Font = Enum.Font.Gotham
    D.Text = text
    D.TextColor3 = DarkMenu.UI.TextColor
    D.TextSize = 12
    D.TextXAlignment = Enum.TextXAlignment.Left
    D.Parent = Frame
    
    Utils:Tween(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
    task.delay(duration or 4, function()
        Utils:Tween(Frame, TweenInfo.new(0.5), {BackgroundTransparency = 1})
        Utils:Tween(T, TweenInfo.new(0.5), {TextTransparency = 1})
        Utils:Tween(D, TweenInfo.new(0.5), {TextTransparency = 1})
        task.wait(0.5)
        Frame:Destroy()
    end)
end

-- [[ CORE LOGIC v4.1 SUPREME ]]

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Radius = DarkMenu.Settings.Aimbot.FOV
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = DarkMenu.UI.MainColor
FOVCircle.Transparency = 1
DarkMenu.Drawing.FOV = FOVCircle

-- Skeleton Bone Mapping
local R15_Bones = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"}, {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"}, {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"}, {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}
local R6_Bones = {
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
    {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}

-- ESP System (Stable Engine from Backupmenu v3 - Proven)
local ESP_Map = {}
local function CreateESP(p)
    local e = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Dist = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
        HealthBar = Drawing.new("Line"),
        HealthBarBg = Drawing.new("Line"),
        BoxFill = Drawing.new("Square"),
    }
    e.Box.Thickness = 1 e.Box.Filled = false
    e.BoxFill.Filled = true e.BoxFill.Transparency = 0.2 e.BoxFill.Thickness = 1
    e.Bones = {}
    for i=1, 15 do
        local b = Drawing.new("Line")
        b.Thickness = 2 e.Bones[i] = b
    end
    e.Name.Size = 14 e.Name.Center = true e.Name.Outline = true
    e.Dist.Size = 12 e.Dist.Center = true e.Dist.Outline = true
    e.Tracer.Thickness = 1
    e.HealthBar.Thickness = 3
    e.HealthBarBg.Thickness = 3 e.HealthBarBg.Color = Color3.new(0,0,0)
    ESP_Map[p] = e
end

DarkMenu.Connections.ESP_Join = Players.PlayerAdded:Connect(CreateESP)
DarkMenu.Connections.ESP_Leave = Players.PlayerRemoving:Connect(function(p)
    if ESP_Map[p] then
        for k, v in pairs(ESP_Map[p]) do 
            if k == "Bones" then for _, b in pairs(v) do pcall(function() b:Remove() end) end
            else pcall(function() v:Remove() end) end 
        end
        ESP_Map[p] = nil
    end
end)
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end

-- ESP Rendering (Stable v18.1 - Exact Backupmenu Engine)
DarkMenu.Connections.ESPLoop = RunService.RenderStepped:Connect(function()
    for p, e in pairs(ESP_Map) do
        local char = Utils:GetCharacter(p)
        local root = Utils:GetRoot(char)
        local hum = Utils:GetHumanoid(char)
        if root and hum and hum.Health > 0 and DarkMenu.Settings.ESP.Enabled then
            local pos, vis = Camera:WorldToViewportPoint(root.Position)
            local dist = (Camera.CFrame.Position - root.Position).Magnitude
            if vis and dist <= DarkMenu.Settings.ESP.MaxDist then
                local col = (DarkMenu.Settings.ESP.Team and p.Team == LocalPlayer.Team) and Color3.new(0,1,0) or Color3.new(1,0,0)
                local sx, sy = 2500 / pos.Z, 3500 / pos.Z
                
                if DarkMenu.Settings.ESP.Box then 
                    e.Box.Visible = true e.Box.Size = Vector2.new(sx, sy) e.Box.Position = Vector2.new(pos.X - sx/2, pos.Y - sy/2) e.Box.Color = col 
                else e.Box.Visible = false end
                
                if DarkMenu.Settings.ESP.BoxFill then
                    e.BoxFill.Visible = true e.BoxFill.Size = Vector2.new(sx, sy) e.BoxFill.Position = Vector2.new(pos.X - sx/2, pos.Y - sy/2) e.BoxFill.Color = col
                else e.BoxFill.Visible = false end
                
                -- Skeleton Draw
                if DarkMenu.Settings.ESP.Skeleton then
                    local bones_data = char:FindFirstChild("UpperTorso") and R15_Bones or R6_Bones
                    for i, d in pairs(bones_data) do
                        local b = e.Bones[i]
                        local p1 = char:FindFirstChild(d[1])
                        local p2 = char:FindFirstChild(d[2])
                        if p1 and p2 then
                            local pos1, vis1 = Camera:WorldToViewportPoint(p1.Position)
                            local pos2, vis2 = Camera:WorldToViewportPoint(p2.Position)
                            if vis1 and vis2 then
                                b.From = Vector2.new(pos1.X, pos1.Y)
                                b.To = Vector2.new(pos2.X, pos2.Y)
                                b.Color = DarkMenu.Settings.ESP.SkeletonColor
                                b.Visible = true
                            else b.Visible = false end
                        else b.Visible = false end
                    end
                else
                    for _, b in pairs(e.Bones) do b.Visible = false end
                end
                
                -- HITBOX VISUALIZER
                if DarkMenu.Settings.ESP.ShowHitbox and DarkMenu.Settings.Aimbot.HitboxExpander then
                    local root = Utils:GetRoot(char)
                    if root then
                        local hs = root.Size.X / 2
                        local topWorld = root.Position + Vector3.new(0, hs, 0)
                        local botWorld = root.Position - Vector3.new(0, hs, 0)
                        local topP, tv = Camera:WorldToViewportPoint(topWorld)
                        local botP, bv2 = Camera:WorldToViewportPoint(botWorld)
                        local hbH = math.abs(topP.Y - botP.Y)
                        local hbW = hbH
                        if tv then
                            e.Box.Visible = true
                            e.Box.Size = Vector2.new(hbW, hbH)
                            e.Box.Position = Vector2.new(topP.X - hbW/2, topP.Y)
                            e.Box.Color = Color3.new(1, 0, 0) -- RED = hitbox
                        end
                    end
                end
                if DarkMenu.Settings.ESP.Name then e.Name.Visible = true e.Name.Text = string.format("%s [%d]", p.Name, math.floor(hum.Health)) e.Name.Position = Vector2.new(pos.X, pos.Y - sy/2 - 15) e.Name.Color = Color3.new(1,1,1) else e.Name.Visible = false end
                if DarkMenu.Settings.ESP.Dist then e.Dist.Visible = true e.Dist.Text = math.floor(dist) .. "m" e.Dist.Position = Vector2.new(pos.X, pos.Y + sy/2 + 5) e.Dist.Color = Color3.new(1,1,1) else e.Dist.Visible = false end
                
                if DarkMenu.Settings.ESP.Health then
                    local h = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    e.HealthBarBg.Visible = true
                    e.HealthBarBg.From = Vector2.new(pos.X - sx/2 - 6, pos.Y - sy/2)
                    e.HealthBarBg.To = Vector2.new(pos.X - sx/2 - 6, pos.Y + sy/2)
                    e.HealthBar.Visible = true
                    e.HealthBar.From = Vector2.new(pos.X - sx/2 - 6, pos.Y + sy/2)
                    e.HealthBar.To = Vector2.new(pos.X - sx/2 - 6, pos.Y + sy/2 - (sy * h))
                    e.HealthBar.Color = Color3.fromHSV(h * 0.3, 1, 1)
                else e.HealthBar.Visible = false e.HealthBarBg.Visible = false end
                
                if DarkMenu.Settings.ESP.Tracers then
                    e.Tracer.Visible = true
                    e.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    e.Tracer.To = Vector2.new(pos.X, pos.Y + sy/2)
                    e.Tracer.Color = col
                else e.Tracer.Visible = false end
            else 
                for k, v in pairs(e) do 
                    if k == "Bones" then for _, b in pairs(v) do b.Visible = false end
                    else v.Visible = false end 
                end 
            end
        else 
            for k, v in pairs(e) do 
                if k == "Bones" then for _, b in pairs(v) do b.Visible = false end
                else v.Visible = false end 
            end 
        end
    end
end)

-- [[ HITBOX EXPANDER (v1.1) ]]
RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local isTeammate = (DarkMenu.Settings.Aimbot.Team and p.Team == LocalPlayer.Team)
                if DarkMenu.Settings.Aimbot.HitboxExpander and not isTeammate then
                    local s = DarkMenu.Settings.Aimbot.HitboxSize
                    root.Size = Vector3.new(s, s, s)
                    root.Massless = true
                    root.CanCollide = false
                    root.LocalTransparencyModifier = 1 -- invisible main part
                    
                    if DarkMenu.Settings.ESP.ShowHitbox then
                        local sb = root:FindFirstChild("Hitbox3D")
                        if not sb then
                            sb = Instance.new("SelectionBox")
                            sb.Name = "Hitbox3D"
                            sb.Adornee = root
                            sb.Color3 = Color3.new(1, 0, 0)
                            sb.LineThickness = 0.05
                            sb.SurfaceTransparency = 0.8
                            sb.SurfaceColor3 = Color3.new(1, 0, 0)
                            sb.Parent = root
                        end
                    else
                        local sb = root:FindFirstChild("Hitbox3D")
                        if sb then sb:Destroy() end
                    end
                else
                    -- Reset hitbox for teammates or when feature is off
                    if root.Size.X > 2.5 then
                        root.Size = Vector3.new(2, 2, 1)
                        root.Massless = false
                        root.CanCollide = false
                    end
                    local sb = root:FindFirstChild("Hitbox3D")
                    if sb then sb:Destroy() end
                end
            end
        end
    end
end)

-- Aimbot Prediction Logic
DarkMenu.Connections.Aimbot = RunService.RenderStepped:Connect(function()
    pcall(function()
        local isAiming = false
        local aimKey = DarkMenu.Settings.Aimbot.Key
        if aimKey.EnumType == Enum.UserInputType then
            isAiming = UserInputService:IsMouseButtonPressed(aimKey)
        elseif aimKey.EnumType == Enum.KeyCode then
            isAiming = UserInputService:IsKeyDown(aimKey)
        end
        
        if DarkMenu.Settings.Aimbot.Enabled and isAiming and not DarkMenu.UI.Visible then
            local target = GetClosest()
            if target and target.Character then
                local p = target.Character:FindFirstChild(DarkMenu.Settings.Aimbot.Part)
                if p then
                    local targetPos = p.Position
                    if DarkMenu.Settings.Aimbot.Prediction and p.Parent:FindFirstChild("HumanoidRootPart") then
                        targetPos = targetPos + (p.Parent.HumanoidRootPart.Velocity * DarkMenu.Settings.Aimbot.PredComp)
                    end
                    
                    local currentCFrame = Camera.CFrame
                    local targetCFrame = CFrame.new(currentCFrame.Position, targetPos)
                    if DarkMenu.Settings.Aimbot.Smooth > 1 then
                        Camera.CFrame = currentCFrame:Lerp(targetCFrame, 1 / DarkMenu.Settings.Aimbot.Smooth)
                    else
                        Camera.CFrame = targetCFrame
                    end
                end
            end
        end
    end)
end)

-- Anti-AFK Implementation
LocalPlayer.Idled:Connect(function()
    if DarkMenu.Settings.Misc.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Auto-Clicker Loop
task.spawn(function()
    while task.wait(0.05) do
        if DarkMenu.Settings.Misc.AutoClicker and not DarkMenu.UI.Visible then
            VirtualUser:ClickButton1(Vector2.new(0,0))
        end
    end
end)

-- [[ KILL AURA / TP-KILL (v18.5 MONSTER EDITION) ]]
local AuraTick = 0
DarkMenu.Connections.Aura = RunService.Heartbeat:Connect(function()
    pcall(function()
        if DarkMenu.Settings.Misc.KillAura then
            local lchar = Utils:GetCharacter(LocalPlayer)
            local lroot = Utils:GetRoot(lchar)
            local lhum = Utils:GetHumanoid(lchar)
            if not lroot or not lhum or lhum.Health <= 0 then return end

            -- Auto-Equip Best Tool
            local tool = lchar:FindFirstChildOfClass("Tool")
            if not tool then
                for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if item:IsA("Tool") then
                        lhum:EquipTool(item)
                        tool = item
                        break
                    end
                end
            end

            -- Monster Targeting (Massive Area Scan)
            local targets = {}
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local proot = Utils:GetRoot(p.Character)
                    local phum = Utils:GetHumanoid(p.Character)
                    if proot and phum and phum.Health > 0 then
                        if not DarkMenu.Settings.ESP.Team or p.Team ~= LocalPlayer.Team then
                            local dist = (lroot.Position - proot.Position).Magnitude
                            if dist <= DarkMenu.Settings.Misc.AuraRange then
                                table.insert(targets, proot)
                            end
                        end
                    end
                end
            end

            -- Lethal Execution Loop
            if #targets > 0 then
                for _, targetRoot in pairs(targets) do
                    -- Stick to Target Back (Best for registering hits)
                    lroot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 2)
                    lroot.Velocity = Vector3.new(0,0,0) -- Stop physics jitter
                    
                    -- Look at target
                    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetRoot.Position)

                    -- Multi-Method Attack Activation
                    if tool then
                        tool:Activate()
                        -- Double Tap for games with high debounce
                        pcall(function() tool.Handle.Size = Vector3.new(5, 5, 5) end) -- Reach Hack
                    end
                    VirtualUser:Button1Down(Vector2.new(0,0))
                    task.wait(0.01) -- Micro-wait to register server-side
                    VirtualUser:Button1Up(Vector2.new(0,0))
                end
            end
        end
    end)
end)

-- [[ NOCLIP & OVERRIDE PHYSICS SYNC ]]
DarkMenu.Connections.Noclip = RunService.Stepped:Connect(function()
    local char = Utils:GetCharacter(LocalPlayer)
    if char then
        if DarkMenu.Settings.Player.Spinbot then
            local root = Utils:GetRoot(char)
            if root then
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(DarkMenu.Settings.Player.SpinSpeed), 0)
            end
        end
        if DarkMenu.Settings.Player.Noclip then
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    p.CanCollide = false
                end
            end
        end
        
        -- WalkSpeed and JumpPower continuous reinforcement
        local hum = Utils:GetHumanoid(char)
        if hum then
            if DarkMenu.Settings.Player.WS ~= 16 then hum.WalkSpeed = DarkMenu.Settings.Player.WS end
            if DarkMenu.Settings.Player.JP ~= 50 then hum.JumpPower = DarkMenu.Settings.Player.JP end
        end
    end
end)

-- Default Tab Selection
task.defer(function()
    if Tabs["Assist"] and Tabs["Assist"].Select then
        Tabs["Assist"].Select()
    end
end)

-- Final Execution Log
print("[DarkMenu] Supreme Edition Carregada com Sucesso!")
Utils:Notify("DarkMenu", "Script Carregado! Aperte M para abrir.", 5)