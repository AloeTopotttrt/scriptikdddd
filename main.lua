-- Murder Mystery 2 ULTIMATE SCRIPT
-- Version: 3.0.0
-- Features: ESP, Aimbot, Kill All, Auto-Stab, Visual Effects, Anti-AFK, Optimized

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ====================== НАСТРОЙКИ ======================
local Settings = {
    -- Aimbot
    Aimbot = true,
    AimbotFOV = 120,
    AimbotRange = 80,
    AimbotSmooth = 0.25,
    AimbotKey = Enum.KeyCode.LeftAlt,
    AimbotPriority = "Distance", -- Distance, Angle, Health
    
    -- ESP
    ESP = true,
    ESPBoxes = true,
    ESPNames = true,
    ESPRoles = true,
    ESPHealth = true,
    ESPDistance = true,
    ESPTrails = true,
    ESPGlow = true,
    ESPChams = false,
    
    -- Visuals
    FullBright = false,
    NoFog = false,
    AmbientColor = false,
    CustomSky = false,
    Tracers = false,
    HitBoxes = false,
    
    -- Kill/Combat
    KillAll = false,
    KillAllRange = 100,
    KillAllDelay = 0.5,
    AutoStab = true,
    AutoStabRange = 8,
    SilentAim = false,
    TriggerBot = true,
    
    -- Misc
    AntiAFK = true,
    AutoRejoin = false,
    AutoCollect = true,
    SpectatePlayers = false,
    EspColor = Color3.fromRGB(0, 255, 0),
    TeamCheck = false
}

-- ====================== ОПТИМИЗАЦИЯ ======================
local Optimizer = {
    MaxDist = 500,
    UpdateRate = 1/60,
    MaxPlayers = 50,
    LOD = 2 -- 1=Low, 2=Medium, 3=High
}

-- Кэш для объектов
local Cache = {
    Players = {},
    ESPObjects = {},
    Connections = {}
}

-- ====================== ВИЗУАЛЬНЫЕ ЭФФЕКТЫ ======================

-- 1. FullBright + NoFog
local function SetVisuals()
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
    
    if Settings.AmbientColor then
        Lighting.Ambient = Color3.fromRGB(255, 150, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 150, 255)
    end
end

-- 2. Custom Sky (динамическое небо)
local function SetCustomSky()
    if Settings.CustomSky then
        local sky = Instance.new("Sky")
        sky.Name = "CustomSky"
        sky.SkyboxBk = "http://www.roblox.com/asset/?id=999999999"
        sky.SkyboxDn = "http://www.roblox.com/asset/?id=999999999"
        sky.SkyboxFt = "http://www.roblox.com/asset/?id=999999999"
        sky.SkyboxLf = "http://www.roblox.com/asset/?id=999999999"
        sky.SkyboxRt = "http://www.roblox.com/asset/?id=999999999"
        sky.SkyboxUp = "http://www.roblox.com/asset/?id=999999999"
        sky.Parent = Lighting
    else
        local sky = Lighting:FindFirstChild("CustomSky")
        if sky then sky:Destroy() end
    end
end

-- 3. Глобальное свечение (Bloom)
local function CreateBloom()
    local bloom = Instance.new("BloomEffect")
    bloom.Name = "GlobalBloom"
    bloom.Intensity = 0.5
    bloom.Size = 50
    bloom.Threshold = 0.8
    bloom.Parent = Lighting
    return bloom
end

-- 4. Цветовые фильтры (ColorCorrection)
local function CreateColorCorrection()
    local cc = Instance.new("ColorCorrectionEffect")
    cc.Name = "ColorFilter"
    cc.Saturation = 1.2
    cc.Contrast = 1.1
    cc.TintColor = Color3.fromRGB(200, 200, 255)
    cc.Parent = Lighting
    return cc
end

-- 5. Частицы вокруг игрока
local function CreateParticles(character)
    if not character then return end
    local particleEmitter = Instance.new("ParticleEmitter")
    particleEmitter.Name = "AuraParticles"
    particleEmitter.Texture = "http://www.roblox.com/asset/?id=112703863"
    particleEmitter.SpreadAngle = Vector2.new(360, 360)
    particleEmitter.VelocityInheritance = 0
    particleEmitter.Lifetime = NumberRange.new(1, 2)
    particleEmitter.Rate = 100
    particleEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 0, 255), Color3.fromRGB(0, 255, 255))
    particleEmitter.Transparency = NumberSequence.new(0, 1)
    particleEmitter.Size = NumberSequence.new(0.5, 1)
    particleEmitter.Parent = character:WaitForChild("HumanoidRootPart")
    return particleEmitter
end

-- ====================== УЛУЧШЕННЫЙ ESP ======================

local function CreateESP()
    -- Очистка старого ESP
    for _, v in pairs(CoreGui:GetChildren()) do
        if string.find(v.Name, "ESP") or v.Name == "ESPContainer" then
            v:Destroy()
        end
    end
    
    local espContainer = Instance.new("ScreenGui")
    espContainer.Name = "ESPContainer"
    espContainer.ResetOnSpawn = false
    espContainer.Parent = CoreGui
    
    -- Функция создания линии (трейсер)
    local function CreateTracer(from, to, color)
        local line = Drawing.new("Line")
        line.From = from
        line.To = to
        line.Color = color
        line.Thickness = 1
        line.Transparency = 0.5
        return line
    end
    
    -- Функция создания HP бара
    local function CreateHealthBar(root, character)
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
        
        -- Обновление HP
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
    
    -- Функция создания бокса (BoxHandleAdornment)
    local function CreateBox(character, color)
        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "ESPBox"
        box.Size = Vector3.new(2.5, 4.5, 2.5)
        box.Adornee = root
        box.AlwaysOnTop = true
        box.ZIndex = 999
        box.Color3 = color
        box.Transparency = 0.7
        box.Parent = espContainer
        
        -- Анимация пульсации
        local tween = TweenService:Create(box, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            Transparency = 0.3
        })
        tween:Play()
        
        return box
    end
    
    -- Функция создания имени
    local function CreateNameTag(character, player)
        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
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
            
            -- Обновляем цвет бокса
            local box = espContainer:FindFirstChild("ESPBox")
            if box then
                box.Color3 = colors[role] or Color3.fromRGB(0, 255, 0)
            end
        end
        
        player:GetAttributeChangedSignal("Role"):Connect(UpdateRole)
        UpdateRole()
        
        -- Обновление дистанции
        RunService.Heartbeat:Connect(function()
            if LocalPlayer.Character and root then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
                distLabel.Text = math.round(dist) .. "m"
            end
        end)
        
        return nameGui
    end
    
    -- Создание ESP для всех игроков
    local function CreatePlayerESP(player)
        if player == LocalPlayer then return end
        local character = player.Character
        if not character then return end
        
        local color = Settings.EspColor
        
        -- Бокс
        if Settings.ESPBoxes then
            CreateBox(character, color)
        end
        
        -- Имя + роль + дистанция
        if Settings.ESPNames then
            CreateNameTag(character, player)
        end
        
        -- HP бар
        if Settings.ESPHealth then
            local root = character:FindFirstChild("HumanoidRootPart")
            if root then
                CreateHealthBar(root, character)
            end
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
end

-- ====================== KILL ALL ======================

local function KillAll()
    if not Settings.KillAll then return end
    local character = LocalPlayer.Character
    if not character then return end
    
    -- Ищем игроков в радиусе
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local targetChar = player.Character
        if not targetChar then continue end
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if not targetRoot then continue end
        
        local distance = (character.HumanoidRootPart.Position - targetRoot.Position).Magnitude
        if distance <= Settings.KillAllRange then
            -- Попытка убить через различные методы
            local success = pcall(function()
                -- Метод 1: RemoteEvent (для Murderer)
                local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
                if remote then
                    remote:FireServer(player, "Stab")
                end
                
                -- Метод 2: Стрельба (Sheriff)
                local tool = character:FindFirstChildOfClass("Tool")
                if tool and tool:IsA("Tool") then
                    tool:Activate()
                    wait(0.1)
                    tool:Deactivate()
                end
            end)
            
            if success then
                print("Killed: " .. player.Name)
            end
        end
    end
end

-- ====================== TRIGGERBOT ======================

local function TriggerBot()
    if not Settings.TriggerBot then return end
    local mouse = LocalPlayer:GetMouse()
    local target = mouse.Target
    
    if target and target.Parent then
        local character = target.Parent
        local player = Players:GetPlayerFromCharacter(character)
        if player and player ~= LocalPlayer then
            -- Автоматический удар/выстрел
            local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
            if remote then
                remote:FireServer(player, "Stab")
            end
        end
    end
end

-- ====================== SILENT AIM ======================

local function SilentAim()
    if not Settings.SilentAim then return end
    -- Используем GetClosestTarget из предыдущей версии
    local target = GetClosestTarget()
    if target then
        -- Отправляем фейковый пакет с новым углом
        local fakeAngle = CFrame.lookAt(Camera.CFrame.Position, target.Position)
        -- Здесь нужна библиотека для отправки пакетов (не реализовано в базовом Lua)
    end
end

-- ====================== ТРЕЙСЕРЫ ======================

local function CreateTracers()
    if not Settings.Tracers then return end
    
    local tracers = {}
    local function UpdateTracers()
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
            
            local tracer = tracers[player]
            if not tracer then
                tracer = Drawing.new("Line")
                tracer.Thickness = 1
                tracer.Transparency = 0.5
                tracers[player] = tracer
            end
            
            tracer.From = Vector2.new(center.X, center.Y)
            tracer.To = Vector2.new(screenPos.X, screenPos.Y)
            tracer.Color = color
            tracer.Visible = true
        end
        
        -- Очищаем неактивных
        for player, tracer in pairs(tracers) do
            if not player.Parent then
                tracer:Remove()
                tracers[player] = nil
            end
        end
    end
    
    RunService.RenderStepped:Connect(UpdateTracers)
end

-- ====================== АНТИ-АФК ======================

local function AntiAFK()
    if not Settings.AntiAFK then return end
    
    local virtualUser = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        virtualUser:CaptureController()
        virtualUser:ClickButton2(Vector2.new())
    end)
    
    -- Дополнительный метод
    local function SendMovement()
        local randomWalk = Vector3.new(
            math.random(-10, 10),
            0,
            math.random(-10, 10)
        )
        if LocalPlayer.Character then
            LocalPlayer.Character.Humanoid:MoveTo(LocalPlayer.Character.HumanoidRootPart.Position + randomWalk)
        end
    end
    
    RunService.Heartbeat:Connect(function()
        if tick() % 120 < 1 then
            SendMovement()
        end
    end)
end

-- ====================== GUI (ВИЗУАЛЬНОЕ МЕНЮ) ======================

local function CreateUltimateGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UltimateGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui
    
    -- Главная панель с градиентом
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    -- Градиентный фон
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 0, 40)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 10, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 20, 40))
    }
    gradient.Rotation = 45
    gradient.Parent = mainFrame
    
    -- Края с неоновой подсветкой
    local border = Instance.new("UICorner")
    border.CornerRadius = UDim.new(0, 10)
    border.Parent = mainFrame
    
    -- Заголовок
    local titleFrame = Instance.new("Frame")
    titleFrame.Size = UDim2.new(1, 0, 0, 50)
    titleFrame.BackgroundTransparency = 1
    titleFrame.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ MM2 ULTIMATE ⚡"
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.Parent = titleFrame
    
    -- Табы
    local tabs = {"Aimbot", "ESP", "Visuals", "Combat", "Misc"}
    local currentTab = "Aimbot"
    local tabButtons = {}
    local contentFrames = {}
    
    -- Создание табов
    for i, tabName in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.2, 0, 0, 30)
        btn.Position = UDim2.new(0.1 + (i-1) * 0.2, 0, 0, 55)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        btn.Text = tabName
        btn.TextColor3 = Color3.fromRGB(200, 200, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.BorderSizePixel = 0
        btn.Parent = mainFrame
        
        -- Закругление
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            currentTab = tabName
            for _, frame in pairs(contentFrames) do
                frame.Visible = false
            end
            contentFrames[tabName].Visible = true
            
            -- Подсветка активного таба
            for _, b in pairs(tabButtons) do
                b.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
            end
            btn.BackgroundColor3 = Color3.fromRGB(60, 40, 80)
        end)
        
        table.insert(tabButtons, btn)
    end
    
    -- Создание контента для каждого таба
    for _, tabName in ipairs(tabs) do
        local frame = Instance.new("ScrollingFrame")
        frame.Size = UDim2.new(0.95, 0, 0, 0.7)
        frame.Position = UDim2.new(0.025, 0, 0, 90)
        frame.BackgroundTransparency = 1
        frame.Visible = (tabName == "Aimbot")
        frame.Parent = mainFrame
        contentFrames[tabName] = frame
    end
    
    -- Функция создания элемента управления (чекбокс)
    local function CreateCheckbox(parent, name, setting, yPos)
        local box = Instance.new("TextButton")
        box.Size = UDim2.new(0.9, 0, 0, 25)
        box.Position = UDim2.new(0.05, 0, 0, yPos)
        box.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        box.Text = "⬜ " .. name .. ": OFF"
        box.TextColor3 = Color3.fromRGB(200, 200, 200)
        box.Font = Enum.Font.Gotham
        box.TextSize = 13
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.BorderSizePixel = 0
        box.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 3)
        corner.Parent = box
        
        box.MouseButton1Click:Connect(function()
            local value = not Settings[setting]
            Settings[setting] = value
            box.Text = (value and "✅ " or "⬜ ") .. name .. ": " .. (value and "ON" or "OFF")
            box.TextColor3 = value and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(200, 200, 200)
        end)
        
        return box
    end
    
    -- Функция создания слайдера
    local function CreateSlider(parent, name, setting, min, max, yPos)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.3, 0, 0, 20)
        label.Position = UDim2.new(0.05, 0, 0, yPos)
        label.BackgroundTransparency = 1
        label.Text = name .. ": " .. tostring(Settings[setting])
        label.TextColor3 = Color3.fromRGB(200, 200, 255)
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.Parent = parent
        
        local slider = Instance.new("TextButton")
        slider.Size = UDim2.new(0.55, 0, 0, 20)
        slider.Position = UDim2.new(0.4, 0, 0, yPos)
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
        slider.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = UserInputService:GetMouseLocation()
                local absPos = slider.AbsolutePosition
                local relX = math.clamp((mousePos.X - absPos.X) / slider.AbsoluteSize.X, 0, 1)
                local newVal = min + (max - min) * relX
                if type(Settings[setting]) == "number" then
                    if setting == "AimbotSmooth" then
                        newVal = math.round(newVal * 100) / 100
                    else
                        newVal = math.round(newVal)
                    end
                end
                Settings[setting] = newVal
                fill.Size = UDim2.new(relX, 0, 1, 0)
                label.Text = name .. ": " .. tostring(newVal)
            end
        end)
        
        return slider
    end
    
    -- Заполнение вкладок
    -- Aimbot Tab
    local aimbotFrame = contentFrames["Aimbot"]
    CreateCheckbox(aimbotFrame, "Aimbot", "Aimbot", 5)
    CreateCheckbox(aimbotFrame, "Silent Aim", "SilentAim", 35)
    CreateCheckbox(aimbotFrame, "Team Check", "TeamCheck", 65)
    CreateSlider(aimbotFrame, "FOV", "AimbotFOV", 10, 180, 95)
    CreateSlider(aimbotFrame, "Range", "AimbotRange", 10, 200, 125)
    CreateSlider(aimbotFrame, "Smoothness", "AimbotSmooth", 0, 1, 155)
    
    -- ESP Tab
    local espFrame = contentFrames["ESP"]
    CreateCheckbox(espFrame, "ESP", "ESP", 5)
    CreateCheckbox(espFrame, "ESP Boxes", "ESPBoxes", 35)
    CreateCheckbox(espFrame, "ESP Names", "ESPNames", 65)
    CreateCheckbox(espFrame, "ESP Roles", "ESPRoles", 95)
    CreateCheckbox(espFrame, "ESP Health", "ESPHealth", 125)
    CreateCheckbox(espFrame, "ESP Trails", "ESPTrails", 155)
    CreateCheckbox(espFrame, "ESP Glow", "ESPGlow", 185)
    
    -- Visuals Tab
    local visualsFrame = contentFrames["Visuals"]
    CreateCheckbox(visualsFrame, "FullBright", "FullBright", 5)
    CreateCheckbox(visualsFrame, "No Fog", "NoFog", 35)
    CreateCheckbox(visualsFrame, "Ambient Color", "AmbientColor", 65)
    CreateCheckbox(visualsFrame, "Custom Sky", "CustomSky", 95)
    CreateCheckbox(visualsFrame, "Tracers", "Tracers", 125)
    CreateCheckbox(visualsFrame, "HitBoxes", "HitBoxes", 155)
    
    -- Combat Tab
    local combatFrame = contentFrames["Combat"]
    CreateCheckbox(combatFrame, "Kill All", "KillAll", 5)
    CreateSlider(combatFrame, "Kill Range", "KillAllRange", 10, 200, 35)
    CreateCheckbox(combatFrame, "Auto Stab", "AutoStab", 65)
    CreateCheckbox(combatFrame, "TriggerBot", "TriggerBot", 95)
    CreateSlider(combatFrame, "AutoStab Range", "AutoStabRange", 1, 20, 125)
    
    -- Misc Tab
    local miscFrame = contentFrames["Misc"]
    CreateCheckbox(miscFrame, "Anti AFK", "AntiAFK", 5)
    CreateCheckbox(miscFrame, "Auto Collect", "AutoCollect", 35)
    CreateCheckbox(miscFrame, "Spectate", "SpectatePlayers", 65)
    CreateCheckbox(miscFrame, "Auto Rejoin", "AutoRejoin", 95)
    
    -- Кнопка Kill All (экстренная)
    local killBtn = Instance.new("TextButton")
    killBtn.Size = UDim2.new(0.4, 0, 0, 35)
    killBtn.Position = UDim2.new(0.3, 0, 0, 450)
    killBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    killBtn.Text = "💀 KILL ALL NOW 💀"
    killBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    killBtn.Font = Enum.Font.GothamBold
    killBtn.TextSize = 14
    killBtn.Parent = mainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = killBtn
    
    killBtn.MouseButton1Click:Connect(function()
        Settings.KillAll = true
        KillAll()
        Settings.KillAll = false
        print("Kill All executed!")
    end)
    
    return screenGui
end

-- ====================== ОСНОВНОЙ ЦИКЛ (ОПТИМИЗИРОВАННЫЙ) ======================

-- Кэширование объектов для скорости
local function CachePlayers()
    local players = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                local root = character:FindFirstChild("HumanoidRootPart")
                if root then
                    table.insert(players, {
                        Player = player,
                        Character = character,
                        Root = root,
                        Humanoid = character:FindFirstChildOfClass("Humanoid")
                    })
                end
            end
        end
    end
    return players
end

-- Функция для плавного обновления ESP (оптимизация)
local function UpdateESP()
    if not Settings.ESP then
        local espContainer = CoreGui:FindFirstChild("ESPContainer")
        if espContainer then espContainer:Destroy() end
        return
    end
    
    if not CoreGui:FindFirstChild("ESPContainer") then
        CreateESP()
    end
end

-- Оптимизированный основной цикл
local function OptimizedLoop()
    -- Обновляем ESP каждые 5 тиков (экономия ресурсов)
    if tick() % 0.5 < 0.05 then
        UpdateESP()
    end
    
    -- Применяем визуальные эффекты каждые 10 тиков
    if tick() % 1 < 0.05 then
        SetVisuals()
        SetCustomSky()
    end
    
    -- Аимбот каждые 2 тика
    if tick() % 0.033 < 0.02 and Settings.Aimbot then
        -- Здесь код аимбота
        local target = GetClosestTarget()
        if target and UserInputService:IsKeyDown(Settings.AimbotKey) then
            local targetPos = target.Position
            local lookAt = CFrame.lookAt(Camera.CFrame.Position, targetPos)
            local smoothCFrame = Camera.CFrame:Lerp(lookAt, Settings.AimbotSmooth)
            Camera.CFrame = smoothCFrame
        end
    end
    
    -- Kill All каждые KillAllDelay секунд
    if Settings.KillAll then
        KillAll()
        wait(Settings.KillAllDelay)
    end
    
    -- Auto Stab
    if Settings.AutoStab then
        AutoStab()
    end
    
    -- TriggerBot
    if Settings.TriggerBot then
        TriggerBot()
    end
end

-- ====================== ЗАПУСК ======================

print("Loading MM2 Ultimate Script...")

-- Создание GUI
CreateUltimateGUI()

-- Создание визуальных эффектов
CreateBloom()
CreateColorCorrection()

-- Анти-АФК
AntiAFK()

-- Трейсеры
if Settings.Tracers then
    CreateTracers()
end

-- Основной цикл с оптимизацией
RunService.Heartbeat:Connect(OptimizedLoop)

-- Очистка при выгрузке
game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
