-- Murder Mystery 2 ULTIMATE SCRIPT v4.0 [XENO-OPTIMIZED]
-- GUI Key: L (можно изменить)
-- Полностью переработан для XENO Executor

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")

-- ====================== БЕЗОПАСНЫЙ ЗАПУСК ======================
local function safeCall(func)
    local success, result = pcall(func)
    if not success then
        warn("Ошибка в функции: " .. tostring(result))
        return nil
    end
    return result
end

-- ====================== НАСТРОЙКИ (облегчённые для XENO) ======================
local Settings = {
    -- Основные
    GUIKey = "L",
    Enabled = true,
    
    -- Aimbot
    Aimbot = true,
    AimbotFOV = 120,
    AimbotRange = 80,
    AimbotSmooth = 0.25,
    AimbotKey = "LeftAlt",
    AimbotPriority = "Distance",
    AimbotPredict = true,
    AimbotTargetLock = false,
    
    -- ESP (упрощён для XENO)
    ESP = true,
    ESPBoxes = true,
    ESPNames = true,
    ESPRoles = true,
    ESPHealth = true,
    ESPDistance = true,
    ESPTracers = false,
    ESPHeadDot = true,
    
    -- Visuals (рабочие для XENO)
    FullBright = false,
    NoFog = false,
    Tracers = false,
    Bloom = true,
    ColorCorrection = true,
    Saturation = 1.2,
    
    -- Combat
    KillAll = false,
    KillAllRange = 100,
    KillAllDelay = 0.5,
    AutoStab = true,
    AutoStabRange = 8,
    TriggerBot = true,
    TriggerBotDelay = 0.1,
    
    -- Misc
    AntiAFK = true,
    AutoCollect = true,
    Walkspeed = false,
    WalkspeedValue = 16,
    JumpPower = false,
    JumpPowerValue = 50,
    Fly = false,
    FlySpeed = 50,
    TeamCheck = false
}

-- ====================== ОПТИМИЗАЦИЯ ДЛЯ XENO ======================
local Optimizer = {
    MaxDist = 500,
    ESPUpdateRate = 0.3,
    AimbotUpdateRate = 0.033,
    VisualUpdateRate = 0.5,
    CacheClearRate = 60,
    UseDrawingAPI = true
}

-- Кэш для объектов
local Cache = {
    Players = {},
    ESPObjects = {},
    Tracers = {},
    Connections = {}
}

-- ====================== ВИЗУАЛЬНЫЕ ЭФФЕКТЫ (АДАПТИРОВАНЫ) ======================

local function SetVisuals()
    safeCall(function()
        if Settings.FullBright then
            Lighting.Brightness = 5
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        else
            Lighting.Brightness = 1
            Lighting.Ambient = Color3.fromRGB(100, 100, 100)
            Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)
        end

        if Settings.NoFog then
            Lighting.FogEnd = 1000
            Lighting.FogStart = 1000
        else
            Lighting.FogEnd = 500
            Lighting.FogStart = 0
        end
    end)
end

local function CreateBloom()
    safeCall(function()
        if not Settings.Bloom then
            local bloom = Lighting:FindFirstChild("GlobalBloom")
            if bloom then bloom:Destroy() end
            return
        end
        
        local bloom = Lighting:FindFirstChild("GlobalBloom")
        if not bloom then
            bloom = Instance.new("BloomEffect")
            bloom.Name = "GlobalBloom"
            bloom.Parent = Lighting
        end
        
        bloom.Intensity = 0.5
        bloom.Size = 50
        bloom.Threshold = 0.8
    end)
end

local function CreateColorCorrection()
    safeCall(function()
        if not Settings.ColorCorrection then
            local cc = Lighting:FindFirstChild("ColorFilter")
            if cc then cc:Destroy() end
            return
        end
        
        local cc = Lighting:FindFirstChild("ColorFilter")
        if not cc then
            cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "ColorFilter"
            cc.Parent = Lighting
        end
        
        cc.Saturation = Settings.Saturation
        cc.Contrast = 1.1
        cc.TintColor = Color3.fromRGB(200, 200, 255)
    end)
end

-- ====================== ESP (ЧЕРЕЗ DRAWING API ДЛЯ XENO) ======================

local function CreateESP()
    safeCall(function()
        -- Очистка старых ESP
        for _, v in pairs(CoreGui:GetChildren()) do
            if string.find(v.Name, "ESP") or v.Name == "ESPContainer" then
                v:Destroy()
            end
        end
        
        -- Очистка старых Drawing объектов
        for player, tracer in pairs(Cache.Tracers) do
            if tracer then
                pcall(function() tracer:Remove() end)
                Cache.Tracers[player] = nil
            end
        end

        local espContainer = Instance.new("ScreenGui")
        espContainer.Name = "ESPContainer"
        espContainer.ResetOnSpawn = false
        espContainer.Parent = CoreGui
        
        -- Создание 3D боксов
        local function CreateBox(character, color)
            local root = character:FindFirstChild("HumanoidRootPart")
            if not root then return nil end

            local box = Instance.new("BoxHandleAdornment")
            box.Size = Vector3.new(2.5, 4.5, 2.5)
            box.Adornee = root
            box.AlwaysOnTop = true
            box.ZIndex = 999
            box.Color3 = color
            box.Transparency = 0.6
            box.Parent = espContainer

            return box
        end
        
        -- Создание имен
        local function CreateNameTag(character, player)
            local root = character:FindFirstChild("HumanoidRootPart")
            if not root then return nil end

            local nameGui = Instance.new("BillboardGui")
            nameGui.Name = "NameTag"
            nameGui.Adornee = root
            nameGui.Size = UDim2.new(0, 200, 0, 50)
            nameGui.StudsOffset = Vector3.new(0, 3.5, 0)
            nameGui.AlwaysOnTop = true
            nameGui.Parent = espContainer

            local mainLabel = Instance.new("TextLabel")
            mainLabel.Size = UDim2.new(1, 0, 0.5, 0)
            mainLabel.BackgroundTransparency = 1
            mainLabel.Text = player.Name
            mainLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            mainLabel.TextScaled = true
            mainLabel.Font = Enum.Font.GothamBold
            mainLabel.Parent = nameGui

            -- Роль
            local roleLabel = Instance.new("TextLabel")
            roleLabel.Size = UDim2.new(1, 0, 0.5, 0)
            roleLabel.Position = UDim2.new(0, 0, 0.5, 0)
            roleLabel.BackgroundTransparency = 1
            roleLabel.Text = "Innocent"
            roleLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            roleLabel.TextScaled = true
            roleLabel.Font = Enum.Font.Gotham
            roleLabel.Parent = nameGui
            
            -- Дистанция
            local distLabel = Instance.new("TextLabel")
            distLabel.Size = UDim2.new(1, 0, 0.3, 0)
            distLabel.Position = UDim2.new(0, 0, -0.3, 0)
            distLabel.BackgroundTransparency = 1
            distLabel.Text = "0m"
            distLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            distLabel.TextScaled = true
            distLabel.Font = Enum.Font.Gotham
            distLabel.Parent = nameGui

            -- Обновление роли
            local function UpdateRole()
                local role = player:GetAttribute("Role") or "Innocent"
                local colors = {
                    Murderer = Color3.fromRGB(255, 0, 0),
                    Sheriff = Color3.fromRGB(0, 100, 255),
                    Innocent = Color3.fromRGB(0, 255, 0)
                }
                roleLabel.Text = role
                roleLabel.TextColor3 = colors[role] or Color3.fromRGB(255, 255, 255)
            end
            
            player:GetAttributeChangedSignal("Role"):Connect(UpdateRole)
            UpdateRole()

            return nameGui
        end
        
        -- Создание головных точек (для XENO)
        local function CreateHeadDot(character, color)
            local head = character:FindFirstChild("Head")
            if not head then return nil end
            
            local dot = Instance.new("BillboardGui")
            dot.Name = "HeadDot"
            dot.Adornee = head
            dot.Size = UDim2.new(0, 20, 0, 20)
            dot.AlwaysOnTop = true
            dot.Parent = espContainer
            
            local circle = Instance.new("Frame")
            circle.Size = UDim2.new(1, 0, 1, 0)
            circle.BackgroundColor3 = color
            circle.BorderSizePixel = 0
            circle.Parent = dot
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = circle
            
            return dot
        end
        
        -- Создание Health Bar
        local function CreateHealthBar(character)
            local root = character:FindFirstChild("HumanoidRootPart")
            if not root then return nil end
            
            local healthBar = Instance.new("BillboardGui")
            healthBar.Name = "HealthBar"
            healthBar.Adornee = root
            healthBar.Size = UDim2.new(0, 50, 0, 5)
            healthBar.StudsOffset = Vector3.new(0, 2.5, 0)
            healthBar.AlwaysOnTop = true
            healthBar.Parent = espContainer

            local bg = Instance.new("Frame")
            bg.Size = UDim2.new(1, 0, 1, 0)
            bg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            bg.BorderSizePixel = 0
            bg.Parent = healthBar

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(1, 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            fill.BorderSizePixel = 0
            fill.Parent = bg

            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    fill.Size = UDim2.new(healthPercent, 0, 1, 0)
                    fill.BackgroundColor3 = Color3.fromRGB(
                        255 * (1 - healthPercent),
                        255 * healthPercent,
                        0
                    )
                end)
            end
            
            return healthBar
        end
        
        -- Создание ESP для игрока
        local function CreatePlayerESP(player)
            if player == LocalPlayer then return end
            local character = player.Character
            if not character then return end
            
            local role = player:GetAttribute("Role") or "Innocent"
            local colors = {
                Murderer = Color3.fromRGB(255, 0, 0),
                Sheriff = Color3.fromRGB(0, 100, 255),
                Innocent = Color3.fromRGB(0, 255, 0)
            }
            local color = colors[role] or Color3.fromRGB(255, 0, 0)

            if Settings.ESPBoxes then
                CreateBox(character, color)
            end
            
            if Settings.ESPNames then
                CreateNameTag(character, player)
            end
            
            if Settings.ESPHealth then
                CreateHealthBar(character)
            end
            
            if Settings.ESPHeadDot then
                CreateHeadDot(character, color)
            end
        end
        
        -- Применяем ко всем игрокам
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                CreatePlayerESP(player)
            end
        end
        
        -- Подписка на новых игроков
        local connection = Players.PlayerAdded:Connect(CreatePlayerESP)
        table.insert(Cache.Connections, connection)
        
        return espContainer
    end)
end

-- ====================== AIMBOT (АДАПТИРОВАН ДЛЯ XENO) ======================

local function GetClosestTarget()
    local bestTarget = nil
    local bestScore = math.huge
    local character = LocalPlayer.Character
    if not character then return nil end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end

        local targetChar = player.Character
        if not targetChar then continue end
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if not targetRoot then continue end
        local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
        if not targetHumanoid or targetHumanoid.Health <= 0 then continue end

        local distance = (root.Position - targetRoot.Position).Magnitude
        if distance > Settings.AimbotRange then continue end

        local lookDirection = Camera.CFrame.LookVector
        local toTarget = (targetRoot.Position - Camera.CFrame.Position).Unit
        local angle = math.deg(math.acos(lookDirection:Dot(toTarget)))
        if angle > Settings.AimbotFOV / 2 then continue end

        local score = distance
        if Settings.AimbotPriority == "Angle" then
            score = angle
        elseif Settings.AimbotPriority == "Health" then
            score = targetHumanoid.Health
        end
        
        if score < bestScore then
            bestScore = score
            bestTarget = targetRoot
        end
    end
    return bestTarget
end

-- ====================== TRACERS (ЧЕРЕЗ DRAWING API) ======================

local function CreateTracers()
    if not Settings.Tracers then return end
    
    -- Очистка старых трейсеров
    for player, tracer in pairs(Cache.Tracers) do
        pcall(function() tracer:Remove() end)
        Cache.Tracers[player] = nil
    end
    
    local function UpdateTracers()
        if not Settings.Tracers then return end
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            local character = player.Character
            if not character then continue end
            local root = character:FindFirstChild("HumanoidRootPart")
            if not root then continue end

            local screenPos, onScreen = Camera:WorldToScreenPoint(root.Position)
            if not onScreen then continue end

            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local color = player.Team == LocalPlayer.Team and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

            local tracer = Cache.Tracers[player]
            if not tracer then
                tracer = Drawing.new("Line")
                tracer.Thickness = 1
                tracer.Transparency = 0.5
                Cache.Tracers[player] = tracer
            end

            tracer.From = Vector2.new(center.X, center.Y)
            tracer.To = Vector2.new(screenPos.X, screenPos.Y)
            tracer.Color = color
            tracer.Visible = true
        end
        
        -- Очистка удалённых игроков
        for player, tracer in pairs(Cache.Tracers) do
            if not player.Parent then
                pcall(function() tracer:Remove() end)
                Cache.Tracers[player] = nil
            end
        end
    end
    
    RunService.RenderStepped:Connect(UpdateTracers)
end

-- ====================== KILL ALL ======================

local function KillAll()
    if not Settings.KillAll then return end
    local character = LocalPlayer.Character
    if not character then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local targetChar = player.Character
        if not targetChar then continue end
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if not targetRoot then continue end

        local distance = (character.HumanoidRootPart.Position - targetRoot.Position).Magnitude
        if distance <= Settings.KillAllRange then
            safeCall(function()
                local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
                if remote then
                    remote:FireServer(player, "Stab")
                end

                local tool = character:FindFirstChildOfClass("Tool")
                if tool and tool:IsA("Tool") then
                    tool:Activate()
                    wait(0.1)
                    tool:Deactivate()
                end
            end)
        end
    end
end

-- ====================== TRIGGERBOT ======================

local function TriggerBot()
    if not Settings.TriggerBot then return end
    local mouse = LocalPlayer:GetMouse()
    if not mouse then return end
    local target = mouse.Target

    if target and target.Parent then
        local character = target.Parent
        local player = Players:GetPlayerFromCharacter(character)
        if player and player ~= LocalPlayer then
            safeCall(function()
                local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
                if remote then
                    remote:FireServer(player, "Stab")
                end
            end)
        end
    end
end

-- ====================== АНТИ-АФК ======================

local function AntiAFK()
    if not Settings.AntiAFK then return end

    safeCall(function()
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)

    local function SendMovement()
        local randomWalk = Vector3.new(
            math.random(-5, 5),
            0,
            math.random(-5, 5)
        )
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:MoveTo(LocalPlayer.Character.HumanoidRootPart.Position + randomWalk)
            end
        end
    end
    
    RunService.Heartbeat:Connect(function()
        if tick() % 60 < 1 then
            SendMovement()
        end
    end)
end

-- ====================== GUI (УПРОЩЁН ДЛЯ XENO) ======================

local function CreateGUI()
    safeCall(function()
        -- Удаляем старый GUI
        local oldGUI = CoreGui:FindFirstChild("UltimateGUI")
        if oldGUI then oldGUI:Destroy() end
        
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "UltimateGUI"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = CoreGui

        local mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(0, 320, 0, 450)
        mainFrame.Position = UDim2.new(0.5, -160, 0.5, -225)
        mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
        mainFrame.BorderSizePixel = 2
        mainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
        mainFrame.Active = true
        mainFrame.Draggable = true
        mainFrame.Parent = screenGui

        -- Заголовок
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 40)
        title.BackgroundTransparency = 1
        title.Text = "⚡ MM2 ULTIMATE [XENO] ⚡"
        title.TextColor3 = Color3.fromRGB(0, 255, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 18
        title.Parent = mainFrame

        -- Кнопка закрытия
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0.15, 0, 0.6, 0)
        closeBtn.Position = UDim2.new(0.85, 0, 0.2, 0)
        closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        closeBtn.Text = "✕"
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 16
        closeBtn.BorderSizePixel = 0
        closeBtn.Parent = title
        
        closeBtn.MouseButton1Click:Connect(function()
            screenGui.Visible = not screenGui.Visible
        end)

        -- Создание чекбокса
        local function CreateCheckbox(parent, name, setting, yPos)
            local box = Instance.new("TextButton")
            box.Size = UDim2.new(0.9, 0, 0, 25)
            box.Position = UDim2.new(0.05, 0, 0, yPos)
            box.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            box.Text = "⬜ " .. name .. ": OFF"
            box.TextColor3 = Color3.fromRGB(200, 200, 200)
            box.Font = Enum.Font.Gotham
            box.TextSize = 12
            box.TextXAlignment = Enum.TextXAlignment.Left
            box.BorderSizePixel = 0
            box.Parent = parent

            box.MouseButton1Click:Connect(function()
                local value = not Settings[setting]
                Settings[setting] = value
                box.Text = (value and "✅ " or "⬜ ") .. name .. ": " .. (value and "ON" or "OFF")
                box.TextColor3 = value and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(200, 200, 200)
            end)

            return box
        end

        -- Создание слайдера
        local function CreateSlider(parent, name, setting, min, max, yPos)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.4, 0, 0, 20)
            label.Position = UDim2.new(0.05, 0, 0, yPos)
            label.BackgroundTransparency = 1
            label.Text = name .. ": " .. tostring(Settings[setting])
            label.TextColor3 = Color3.fromRGB(200, 200, 255)
            label.Font = Enum.Font.Gotham
            label.TextSize = 11
            label.Parent = parent

            local slider = Instance.new("TextButton")
            slider.Size = UDim2.new(0.45, 0, 0, 20)
            slider.Position = UDim2.new(0.5, 0, 0, yPos)
            slider.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            slider.Text = ""
            slider.BorderSizePixel = 0
            slider.Parent = parent

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((Settings[setting] - min) / (max - min), 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
            fill.BorderSizePixel = 0
            fill.Parent = slider

            local dragging = false
            slider.MouseButton1Down:Connect(function() dragging = true end)
            slider.MouseButton1Up:Connect(function() dragging = false end)
            slider.MouseLeave:Connect(function() dragging = false end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mousePos = UserInputService:GetMouseLocation()
                    local absPos = slider.AbsolutePosition
                    local relX = math.clamp((mousePos.X - absPos.X) / slider.AbsoluteSize.X, 0, 1)
                    local newVal = min + (max - min) * relX
                    if setting ~= "AimbotSmooth" then
                        newVal = math.round(newVal)
                    end
                    Settings[setting] = newVal
                    fill.Size = UDim2.new(relX, 0, 1, 0)
                    label.Text = name .. ": " .. tostring(newVal)
                end
            end)

            return slider
        end

        -- Табы
        local tabs = {"Combat", "ESP", "Visual", "Misc"}
        local tabButtons = {}
        local contentFrames = {}

        for i, tabName in ipairs(tabs) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.25, 0, 0, 25)
            btn.Position = UDim2.new(0.05 + (i-1) * 0.25, 0, 0, 45)
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
            btn.Text = tabName
            btn.TextColor3 = Color3.fromRGB(200, 200, 255)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 11
            btn.BorderSizePixel = 0
            btn.Parent = mainFrame

            btn.MouseButton1Click:Connect(function()
                for _, frame in pairs(contentFrames) do
                    frame.Visible = false
                end
                contentFrames[tabName].Visible = true
                
                for _, b in pairs(tabButtons) do
                    b.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
                end
                btn.BackgroundColor3 = Color3.fromRGB(60, 40, 80)
            end)

            table.insert(tabButtons, btn)
        end

        for _, tabName in ipairs(tabs) do
            local frame = Instance.new("ScrollingFrame")
            frame.Size = UDim2.new(0.95, 0, 0, 0.7)
            frame.Position = UDim2.new(0.025, 0, 0, 75)
            frame.BackgroundTransparency = 1
            frame.Visible = (tabName == "Combat")
            frame.Parent = mainFrame
            contentFrames[tabName] = frame
        end

        -- Заполнение вкладок
        -- Combat Tab
        local combatFrame = contentFrames["Combat"]
        CreateCheckbox(combatFrame, "Kill All", "KillAll", 5)
        CreateCheckbox(combatFrame, "Auto Stab", "AutoStab", 35)
        CreateCheckbox(combatFrame, "TriggerBot", "TriggerBot", 65)
        CreateCheckbox(combatFrame, "Team Check", "TeamCheck", 95)
        CreateSlider(combatFrame, "Kill Range", "KillAllRange", 10, 200, 125)
        CreateSlider(combatFrame, "AutoStab Range", "AutoStabRange", 1, 20, 155)
        CreateSlider(combatFrame, "TriggerBot Delay", "TriggerBotDelay", 0.05, 0.5, 185, true)

        -- ESP Tab
        local espFrame = contentFrames["ESP"]
        CreateCheckbox(espFrame, "ESP", "ESP", 5)
        CreateCheckbox(espFrame, "ESP Boxes", "ESPBoxes", 35)
        CreateCheckbox(espFrame, "ESP Names", "ESPNames", 65)
        CreateCheckbox(espFrame, "ESP Roles", "ESPRoles", 95)
        CreateCheckbox(espFrame, "ESP Health", "ESPHealth", 125)
        CreateCheckbox(espFrame, "ESP Distance", "ESPDistance", 155)
        CreateCheckbox(espFrame, "ESP Head Dot", "ESPHeadDot", 185)

        -- Visual Tab
        local visualsFrame = contentFrames["Visual"]
        CreateCheckbox(visualsFrame, "FullBright", "FullBright", 5)
        CreateCheckbox(visualsFrame, "No Fog", "NoFog", 35)
        CreateCheckbox(visualsFrame, "Tracers", "Tracers", 65)
        CreateCheckbox(visualsFrame, "Bloom", "Bloom", 95)
        CreateCheckbox(visualsFrame, "Color Correction", "ColorCorrection", 125)
        CreateSlider(visualsFrame, "Saturation", "Saturation", 0, 2, 155, true)

        -- Misc Tab
        local miscFrame = contentFrames["Misc"]
        CreateCheckbox(miscFrame, "Anti AFK", "AntiAFK", 5)
        CreateCheckbox(miscFrame, "Auto Collect", "AutoCollect", 35)
        CreateCheckbox(miscFrame, "Walkspeed", "Walkspeed", 65)
        CreateCheckbox(miscFrame, "Jump Power", "JumpPower", 95)
        CreateCheckbox(miscFrame, "Fly", "Fly", 125)
        CreateSlider(miscFrame, "Walkspeed", "WalkspeedValue", 0, 100, 155)
        CreateSlider(miscFrame, "Jump Power", "JumpPowerValue", 0, 200, 185)
        CreateSlider(miscFrame, "Fly Speed", "FlySpeed", 10, 200, 215)

        -- Кнопка Kill All
        local killBtn = Instance.new("TextButton")
        killBtn.Size = UDim2.new(0.4, 0, 0, 35)
        killBtn.Position = UDim2.new(0.3, 0, 0, 405)
        killBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        killBtn.Text = "💀 KILL ALL 💀"
        killBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        killBtn.Font = Enum.Font.GothamBold
        killBtn.TextSize = 14
        killBtn.Parent = mainFrame

        killBtn.MouseButton1Click:Connect(function()
            Settings.KillAll = true
            KillAll()
            Settings.KillAll = false
            print("Kill All executed!")
        end)

        -- Обработчик клавиши L
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == Enum.KeyCode[Settings.GUIKey] then
                screenGui.Visible = not screenGui.Visible
            end
        end)

        return screenGui
    end)
end

-- ====================== ОСНОВНОЙ ЦИКЛ ======================

local function OptimizedLoop()
    if not Settings.Enabled then return end
    
    local currentTime = tick()
    
    -- ESP (обновляется реже)
    if currentTime % Optimizer.ESPUpdateRate < 0.05 then
        safeCall(function()
            if Settings.ESP then
                if not CoreGui:FindFirstChild("ESPContainer") then
                    CreateESP()
                end
            else
                local espContainer = CoreGui:FindFirstChild("ESPContainer")
                if espContainer then espContainer:Destroy() end
            end
        end)
    end
    
    -- Визуалы
    if currentTime % Optimizer.VisualUpdateRate < 0.05 then
        safeCall(function()
            SetVisuals()
            CreateBloom()
            CreateColorCorrection()
        end)
    end
    
    -- Аимбот
    if currentTime % Optimizer.AimbotUpdateRate < 0.02 and Settings.Aimbot then
        safeCall(function()
            local target = GetClosestTarget()
            if target then
                local isKeyDown = UserInputService:IsKeyDown(Enum.KeyCode[Settings.AimbotKey])
                if isKeyDown or Settings.AimbotTargetLock then
                    local targetPos = target.Position
                    local lookAt = CFrame.lookAt(Camera.CFrame.Position, targetPos)
                    local smoothCFrame = Camera.CFrame:Lerp(lookAt, Settings.AimbotSmooth)
                    Camera.CFrame = smoothCFrame
                end
            end
        end)
    end
    
    -- Kill All
    if Settings.KillAll then
        safeCall(function()
            KillAll()
            wait(Settings.KillAllDelay)
        end)
    end
    
    -- TriggerBot
    if Settings.TriggerBot then
        safeCall(function()
            TriggerBot()
            wait(Settings.TriggerBotDelay)
        end)
    end
    
    -- Walkspeed / JumpPower
    safeCall(function()
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                if Settings.Walkspeed then
                    humanoid.WalkSpeed = Settings.WalkspeedValue
                end
                if Settings.JumpPower then
                    humanoid.JumpPower = Settings.JumpPowerValue
                end
                if Settings.Fly then
                    humanoid.PlatformStand = true
                    local moveDirection = Vector3.new()
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + Camera.CFrame.LookVector * Settings.FlySpeed end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - Camera.CFrame.LookVector * Settings.FlySpeed end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - Camera.CFrame.RightVector * Settings.FlySpeed end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + Camera.CFrame.RightVector * Settings.FlySpeed end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, Settings.FlySpeed, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection = moveDirection - Vector3.new(0, Settings.FlySpeed, 0) end
                    LocalPlayer.Character.HumanoidRootPart.Velocity = moveDirection
                end
            end
        end
    end)
    
    -- Очистка кэша
    if currentTime % Optimizer.CacheClearRate < 0.05 then
        for player, tracer in pairs(Cache.Tracers) do
            if not player.Parent then
                pcall(function() tracer:Remove() end)
                Cache.Tracers[player] = nil
            end
        end
    end
end

-- ====================== ЗАПУСК ======================

print("Loading MM2 Ultimate for XENO...")

-- Создание GUI
CreateGUI()

-- Запуск анти-АФК
AntiAFK()

-- Запуск трейсеров
if Settings.Tracers then
    CreateTracers()
end

-- Основной цикл
RunService.Heartbeat:Connect(OptimizedLoop)

-- Очистка при выгрузке
LocalPlayer.OnTeleport:Connect(function()
    for _, v in pairs(CoreGui:GetChildren()) do
        if string.find(v.Name, "ESP") or v.Name == "UltimateGUI" or v.Name == "ESPContainer" then
            v:Destroy()
        end
    end
    for player, tracer in pairs(Cache.Tracers) do
        pcall(function() tracer:Remove() end)
        Cache.Tracers[player] = nil
    end
end)

-- Уведомление
StarterGui:SetCore("SendNotification", {
    Title = "MM2 ULTIMATE [XENO]",
    Text = "✅ Script loaded! Press L to open menu",
    Duration = 4
})

print("✅ MM2 Ultimate for XENO Loaded!")
print("🎮 Press L to open the GUI")
print("⚡ Features: Aimbot, ESP, Kill All, Fly, Visual Effects, Anti-AFK, and more!")
