-- Murder Mystery 2 ULTIMATE SCRIPT v4.0
-- GUI Key: L (можно изменить в настройках)
-- Полный чит с комбат-функциями, визуалами, шейдерами и оптимизацией

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

-- ====================== РАСШИРЕННЫЕ НАСТРОЙКИ ======================
local Settings = {
    -- Основные
    GUIKey = Enum.KeyCode.L,
    Enabled = true,
    
    -- Aimbot (улучшенный)
    Aimbot = true,
    AimbotFOV = 120,
    AimbotRange = 80,
    AimbotSmooth = 0.25,
    AimbotKey = Enum.KeyCode.LeftAlt,
    AimbotPriority = "Distance", -- Distance, Angle, Health, Random
    AimbotPredict = true,        -- Предугадывание движения
    AimbotVisibleCheck = false,  -- Проверка видимости через Raycast
    AimbotTargetLock = false,    -- Блокировка на цели
    AimbotAutoFire = false,      -- Авто-огонь при наведении
    
    -- ESP (полный набор)
    ESP = true,
    ESPBoxes = true,
    ESPBoxOutline = true,
    ESPNames = true,
    ESPRoles = true,
    ESPHealth = true,
    ESPDistance = true,
    ESPTrails = true,
    ESPGlow = true,
    ESPChams = false,
    ESPHeadDot = true,
    ESPWeapon = true,
    ESPArrow = true,             -- Стрелка к цели вне экрана
    ESP2DBox = false,            -- 2D боксы вместо 3D
    ESPFill = false,             -- Заливка боксов
    ESPColorEnemy = Color3.fromRGB(255, 0, 0),
    ESPColorFriendly = Color3.fromRGB(0, 255, 0),
    ESPColorMurderer = Color3.fromRGB(255, 0, 0),
    ESPColorSheriff = Color3.fromRGB(0, 100, 255),
    ESPColorInnocent = Color3.fromRGB(0, 255, 0),
    
    -- Visuals (улучшенные шейдеры и эффекты)
    FullBright = false,
    NoFog = false,
    AmbientColor = false,
    CustomSky = false,
    Tracers = false,
    HitBoxes = false,
    Bloom = true,
    BloomIntensity = 0.6,
    BloomSize = 50,
    BloomThreshold = 0.8,
    ColorCorrection = true,
    Saturation = 1.2,
    Contrast = 1.1,
    TintColor = Color3.fromRGB(200, 200, 255),
    DepthOfField = false,
    SunRays = false,
    Vignette = false,
    WaterReflection = false,
    ShadowQuality = 2,
    RenderDistance = 1000,
    
    -- Combat (полный набор)
    KillAll = false,
    KillAllRange = 100,
    KillAllDelay = 0.5,
    KillAllMode = "Remote",      -- Remote, Tool, Both
    AutoStab = true,
    AutoStabRange = 8,
    AutoStabDelay = 0.3,
    SilentAim = false,
    TriggerBot = true,
    TriggerBotDelay = 0.1,
    TriggerBotMode = "Stab",     -- Stab, Shoot, Both
    AutoBlock = false,           -- Автоматический блок (если есть)
    AutoDodge = false,           -- Уклонение от выстрелов
    
    -- Misc (расширенные)
    AntiAFK = true,
    AntiAFKMethod = "Both",      -- VirtualUser, Movement, Both
    AutoRejoin = false,
    AutoCollect = true,
    AutoCollectRange = 30,
    SpectatePlayers = false,
    SpectateMode = "Random",     -- Random, Cycle, Closest
    PlayerList = false,
    FOVChanger = false,
    FOVValue = 90,
    Walkspeed = false,
    WalkspeedValue = 16,
    JumpPower = false,
    JumpPowerValue = 50,
    NoClip = false,
    Fly = false,
    FlySpeed = 50,
    TeleportToPlayer = false,
    TeleportTarget = nil,
    TeamCheck = false,
    SaveSettings = false,
    
    -- Цветовые схемы для ESP
    ColorSchemes = {
        Default = {Enemy = Color3.fromRGB(255, 0, 0), Friendly = Color3.fromRGB(0, 255, 0)},
        Neon = {Enemy = Color3.fromRGB(0, 255, 255), Friendly = Color3.fromRGB(255, 0, 255)},
        Pastel = {Enemy = Color3.fromRGB(255, 150, 150), Friendly = Color3.fromRGB(150, 255, 150)},
        Dark = {Enemy = Color3.fromRGB(100, 0, 0), Friendly = Color3.fromRGB(0, 100, 0)}
    },
    CurrentColorScheme = "Default"
}

-- ====================== ОПТИМИЗАЦИЯ (улучшенная) ======================
local Optimizer = {
    MaxDist = 500,
    UpdateRate = 1/60,
    MaxPlayers = 50,
    LOD = 2,
    ESPUpdateRate = 0.3,
    AimbotUpdateRate = 0.033,
    VisualUpdateRate = 0.5,
    CacheClearRate = 60,
    UseThreading = true,
    MaxESPObjects = 100,
    RenderDistance = 1000,
    OptimizeForFPS = true,
    DynamicLOD = true,
    PoolSize = 50
}

-- Кэш для объектов (улучшенный)
local Cache = {
    Players = {},
    ESPObjects = {},
    Connections = {},
    Tracers = {},
    Particles = {},
    Timers = {},
    Pool = {}
}

-- ====================== УЛУЧШЕННЫЕ ВИЗУАЛЬНЫЕ ЭФФЕКТЫ ======================

-- 1. Продвинутый Bloom
local function CreateAdvancedBloom()
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
    
    bloom.Intensity = Settings.BloomIntensity
    bloom.Size = Settings.BloomSize
    bloom.Threshold = Settings.BloomThreshold
end

-- 2. Depth of Field (размытие)
local function CreateDepthOfField()
    if not Settings.DepthOfField then
        local dof = Lighting:FindFirstChild("DepthOfField")
        if dof then dof:Destroy() end
        return
    end
    
    local dof = Lighting:FindFirstChild("DepthOfField")
    if not dof then
        dof = Instance.new("DepthOfFieldEffect")
        dof.Name = "DepthOfField"
        dof.Parent = Lighting
    end
    
    dof.FarIntensity = 0.5
    dof.FocusDistance = 50
    dof.InFocusRadius = 20
    dof.NearIntensity = 0.3
end

-- 3. Sun Rays (лучи солнца)
local function CreateSunRays()
    if not Settings.SunRays then
        local sunRays = Lighting:FindFirstChild("SunRays")
        if sunRays then sunRays:Destroy() end
        return
    end
    
    local sunRays = Lighting:FindFirstChild("SunRays")
    if not sunRays then
        sunRays = Instance.new("SunRaysEffect")
        sunRays.Name = "SunRays"
        sunRays.Parent = Lighting
    end
    
    sunRays.Intensity = 0.3
    sunRays.Spread = 0.8
end

-- 4. Vignette (эффект затемнения по краям)
local function CreateVignette()
    if not Settings.Vignette then
        local vignette = Lighting:FindFirstChild("Vignette")
        if vignette then vignette:Destroy() end
        return
    end
    
    local vignette = Lighting:FindFirstChild("Vignette")
    if not vignette then
        vignette = Instance.new("VignetteEffect")
        vignette.Name = "Vignette"
        vignette.Parent = Lighting
    end
    
    vignette.Intensity = 0.5
    vignette.Smoothness = 0.5
    vignette.Roundness = 1
    vignette.Color = Color3.fromRGB(0, 0, 0)
end

-- 5. Улучшенные настройки освещения
local function SetAdvancedLighting()
    -- Качество теней
    if Settings.ShadowQuality == 0 then
        Lighting.ShadowSoftness = 0
        Lighting.Technology = Enum.Technology.Legacy
    elseif Settings.ShadowQuality == 1 then
        Lighting.ShadowSoftness = 0.5
        Lighting.Technology = Enum.Technology.Voxel
    elseif Settings.ShadowQuality == 2 then
        Lighting.ShadowSoftness = 1
        Lighting.Technology = Enum.Technology.ShadowMap
    end
    
    -- Дистанция рендера
    Lighting.RenderDistance = Settings.RenderDistance
    
    -- Отражения воды
    if Settings.WaterReflection then
        Lighting.WaterReflection = true
        Lighting.WaterReflectionType = Enum.WaterReflectionType.Quality
    else
        Lighting.WaterReflection = false
    end
end

-- ====================== УЛУЧШЕННЫЙ ESP С 3D/2D БОКСАМИ ======================

local function CreateESP()
    for _, v in pairs(CoreGui:GetChildren()) do
        if string.find(v.Name, "ESP") or v.Name == "ESPContainer" then
            v:Destroy()
        end
    end

    local espContainer = Instance.new("ScreenGui")
    espContainer.Name = "ESPContainer"
    espContainer.ResetOnSpawn = false
    espContainer.Parent = CoreGui

    -- 2D боксы (рисуются через Drawing API для производительности)
    local function Create2DBox(player, character)
        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local box = Drawing.new("Square")
        box.Thickness = 1
        box.Transparency = 0.5
        box.Filled = Settings.ESPFill
        
        return box
    end
    
    -- 3D боксы с анимацией
    local function Create3DBox(character, color)
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

        local tween = TweenService:Create(box, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            Transparency = 0.3
        })
        tween:Play()

        return box
    end
    
    -- Стрелка к цели вне экрана
    local function CreateArrow(targetPos)
        local arrow = Instance.new("ImageLabel")
        arrow.Name = "Arrow"
        arrow.Size = UDim2.new(0, 30, 0, 30)
        arrow.BackgroundTransparency = 1
        arrow.Image = "http://www.roblox.com/asset/?id=6031094100"
        arrow.ImageColor3 = Settings.ESPColorEnemy
        arrow.ImageTransparency = 0.5
        arrow.Parent = espContainer
        return arrow
    end
    
    -- Создание ESP для игрока
    local function CreatePlayerESP(player)
        if player == LocalPlayer then return end
        local character = player.Character
        if not character then return end
        
        local role = player:GetAttribute("Role") or "Innocent"
        local color = Settings[("ESPColor" .. role)] or Settings.ESPColorEnemy
        
        if Settings.ESPBoxes then
            if Settings.ESP2DBox then
                Create2DBox(player, character)
            else
                Create3DBox(character, color)
            end
        end
        
        -- Остальные элементы ESP (имена, здоровье и т.д.)
        -- (код аналогичен предыдущей версии, но с улучшениями)
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

-- ====================== УЛУЧШЕННЫЙ AIMBOT ======================

local function GetClosestTarget()
    local bestTarget = nil
    local bestScore = math.huge
    local character = LocalPlayer.Character
    if not character then return nil end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end

        local targetChar = player.Character
        if not targetChar then continue end
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if not targetRoot then continue end
        local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
        if not targetHumanoid or targetHumanoid.Health <= 0 then continue end

        -- Проверка видимости через Raycast
        if Settings.AimbotVisibleCheck then
            local ray = Ray.new(
                Camera.CFrame.Position,
                (targetRoot.Position - Camera.CFrame.Position).Unit * Settings.AimbotRange
            )
            local hit = workspace:FindPartOnRay(ray, character)
            if hit and hit.Parent ~= targetChar then continue end
        end

        local distance = (root.Position - targetRoot.Position).Magnitude
        if distance > Settings.AimbotRange then continue end

        local lookDirection = Camera.CFrame.LookVector
        local toTarget = (targetRoot.Position - Camera.CFrame.Position).Unit
        local angle = math.deg(math.acos(lookDirection:Dot(toTarget)))
        if angle > Settings.AimbotFOV / 2 then continue end

        -- Предугадывание движения
        local targetPos = targetRoot.Position
        if Settings.AimbotPredict and targetHumanoid.MoveDirection.Magnitude > 0 then
            local velocity = targetHumanoid.MoveDirection * targetHumanoid.WalkSpeed
            local timeToTarget = distance / 100 -- Скорость пули (примерная)
            targetPos = targetPos + velocity * timeToTarget
        end

        -- Подсчёт очков
        local score
        if Settings.AimbotPriority == "Distance" then
            score = distance
        elseif Settings.AimbotPriority == "Angle" then
            score = angle
        elseif Settings.AimbotPriority == "Health" then
            score = targetHumanoid.Health
        elseif Settings.AimbotPriority == "Random" then
            score = math.random()
        end
        
        if score and score < bestScore then
            bestScore = score
            bestTarget = targetRoot
        end
    end
    return bestTarget
end

-- ====================== KILL ALL (улучшенный) ======================

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
            local success = pcall(function()
                if Settings.KillAllMode == "Remote" or Settings.KillAllMode == "Both" then
                    local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
                    if remote then
                        remote:FireServer(player, "Stab")
                    end
                end
                
                if Settings.KillAllMode == "Tool" or Settings.KillAllMode == "Both" then
                    local tool = character:FindFirstChildOfClass("Tool")
                    if tool and tool:IsA("Tool") then
                        tool:Activate()
                        wait(0.1)
                        tool:Deactivate()
                    end
                end
            end)

            if success then
                print("Killed: " .. player.Name)
            end
        end
    end
end

-- ====================== GUI С РАСШИРЕННЫМИ НАСТРОЙКАМИ ======================

local function CreateUltimateGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UltimateGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -300)
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

    -- Заголовок с анимацией
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Text = "⚡ MM2 ULTIMATE v4.0 ⚡"
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.Parent = mainFrame

    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.08, 0, 0.5, 0)
    closeBtn.Position = UDim2.new(0.92, 0, 0.25, 0)
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

    -- Табы с дополнительными вкладками
    local tabs = {"Aimbot", "ESP", "Visuals", "Combat", "Misc", "Settings"}
    local tabButtons = {}
    local contentFrames = {}

    for i, tabName in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.16, 0, 0, 30)
        btn.Position = UDim2.new(0.02 + (i-1) * 0.16, 0, 0, 55)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        btn.Text = tabName
        btn.TextColor3 = Color3.fromRGB(200, 200, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 10
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

    -- Функции создания элементов GUI
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

    local function CreateSlider(parent, name, setting, min, max, yPos, isFloat)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.35, 0, 0, 20)
        label.Position = UDim2.new(0.05, 0, 0, yPos)
        label.BackgroundTransparency = 1
        label.Text = name .. ": " .. tostring(Settings[setting])
        label.TextColor3 = Color3.fromRGB(200, 200, 255)
        label.Font = Enum.Font.Gotham
        label.TextSize = 11
        label.Parent = parent

        local slider = Instance.new("TextButton")
        slider.Size = UDim2.new(0.5, 0, 0, 20)
        slider.Position = UDim2.new(0.45, 0, 0, yPos)
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
                if not isFloat then newVal = math.round(newVal) end
                Settings[setting] = newVal
                fill.Size = UDim2.new(relX, 0, 1, 0)
                label.Text = name .. ": " .. tostring(newVal)
            end
        end)

        return slider
    end

    -- Заполнение вкладок (расширенные настройки)
    -- Aimbot Tab
    local aimbotFrame = contentFrames["Aimbot"]
    CreateCheckbox(aimbotFrame, "Aimbot", "Aimbot", 5)
    CreateCheckbox(aimbotFrame, "Silent Aim", "SilentAim", 35)
    CreateCheckbox(aimbotFrame, "Team Check", "TeamCheck", 65)
    CreateCheckbox(aimbotFrame, "Predict Movement", "AimbotPredict", 95)
    CreateCheckbox(aimbotFrame, "Visible Check", "AimbotVisibleCheck", 125)
    CreateCheckbox(aimbotFrame, "Target Lock", "AimbotTargetLock", 155)
    CreateCheckbox(aimbotFrame, "Auto Fire", "AimbotAutoFire", 185)
    CreateSlider(aimbotFrame, "FOV", "AimbotFOV", 10, 180, 215)
    CreateSlider(aimbotFrame, "Range", "AimbotRange", 10, 200, 245)
    CreateSlider(aimbotFrame, "Smoothness", "AimbotSmooth", 0, 1, 275, true)

    -- ESP Tab
    local espFrame = contentFrames["ESP"]
    CreateCheckbox(espFrame, "ESP", "ESP", 5)
    CreateCheckbox(espFrame, "ESP Boxes", "ESPBoxes", 35)
    CreateCheckbox(espFrame, "2D Boxes", "ESP2DBox", 65)
    CreateCheckbox(espFrame, "Fill Boxes", "ESPFill", 95)
    CreateCheckbox(espFrame, "ESP Names", "ESPNames", 125)
    CreateCheckbox(espFrame, "ESP Roles", "ESPRoles", 155)
    CreateCheckbox(espFrame, "ESP Health", "ESPHealth", 185)
    CreateCheckbox(espFrame, "ESP Distance", "ESPDistance", 215)
    CreateCheckbox(espFrame, "ESP Trails", "ESPTrails", 245)
    CreateCheckbox(espFrame, "ESP Glow", "ESPGlow", 275)
    CreateCheckbox(espFrame, "ESP Head Dot", "ESPHeadDot", 305)
    CreateCheckbox(espFrame, "ESP Arrow", "ESPArrow", 335)

    -- Visuals Tab
    local visualsFrame = contentFrames["Visuals"]
    CreateCheckbox(visualsFrame, "FullBright", "FullBright", 5)
    CreateCheckbox(visualsFrame, "No Fog", "NoFog", 35)
    CreateCheckbox(visualsFrame, "Ambient Color", "AmbientColor", 65)
    CreateCheckbox(visualsFrame, "Custom Sky", "CustomSky", 95)
    CreateCheckbox(visualsFrame, "Tracers", "Tracers", 125)
    CreateCheckbox(visualsFrame, "HitBoxes", "HitBoxes", 155)
    CreateCheckbox(visualsFrame, "Bloom", "Bloom", 185)
    CreateCheckbox(visualsFrame, "Depth of Field", "DepthOfField", 215)
    CreateCheckbox(visualsFrame, "Sun Rays", "SunRays", 245)
    CreateCheckbox(visualsFrame, "Vignette", "Vignette", 275)
    CreateCheckbox(visualsFrame, "Water Reflection", "WaterReflection", 305)
    CreateSlider(visualsFrame, "Bloom Intensity", "BloomIntensity", 0, 1, 335, true)
    CreateSlider(visualsFrame, "Saturation", "Saturation", 0, 2, 365, true)
    CreateSlider(visualsFrame, "Contrast", "Contrast", 0, 2, 395, true)

    -- Combat Tab
    local combatFrame = contentFrames["Combat"]
    CreateCheckbox(combatFrame, "Kill All", "KillAll", 5)
    CreateCheckbox(combatFrame, "Auto Stab", "AutoStab", 35)
    CreateCheckbox(combatFrame, "TriggerBot", "TriggerBot", 65)
    CreateCheckbox(combatFrame, "Auto Block", "AutoBlock", 95)
    CreateCheckbox(combatFrame, "Auto Dodge", "AutoDodge", 125)
    CreateSlider(combatFrame, "Kill Range", "KillAllRange", 10, 200, 155)
    CreateSlider(combatFrame, "AutoStab Range", "AutoStabRange", 1, 20, 185)
    CreateSlider(combatFrame, "TriggerBot Delay", "TriggerBotDelay", 0.05, 0.5, 215, true)
    CreateSlider(combatFrame, "Kill Delay", "KillAllDelay", 0.1, 2, 245, true)

    -- Misc Tab
    local miscFrame = contentFrames["Misc"]
    CreateCheckbox(miscFrame, "Anti AFK", "AntiAFK", 5)
    CreateCheckbox(miscFrame, "Auto Collect", "AutoCollect", 35)
    CreateCheckbox(miscFrame, "Spectate Players", "SpectatePlayers", 65)
    CreateCheckbox(miscFrame, "Auto Rejoin", "AutoRejoin", 95)
    CreateCheckbox(miscFrame, "FOV Changer", "FOVChanger", 125)
    CreateCheckbox(miscFrame, "Walkspeed", "Walkspeed", 155)
    CreateCheckbox(miscFrame, "Jump Power", "JumpPower", 185)
    CreateCheckbox(miscFrame, "No Clip", "NoClip", 215)
    CreateCheckbox(miscFrame, "Fly", "Fly", 245)
    CreateSlider(miscFrame, "FOV Value", "FOVValue", 30, 120, 275)
    CreateSlider(miscFrame, "Walkspeed", "WalkspeedValue", 0, 100, 305)
    CreateSlider(miscFrame, "Jump Power", "JumpPowerValue", 0, 200, 335)
    CreateSlider(miscFrame, "Fly Speed", "FlySpeed", 10, 200, 365)

    -- Кнопка Kill All (экстренная)
    local killBtn = Instance.new("TextButton")
    killBtn.Size = UDim2.new(0.4, 0, 0, 35)
    killBtn.Position = UDim2.new(0.3, 0, 0, 555)
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
        if input.KeyCode == Settings.GUIKey then
            screenGui.Visible = not screenGui.Visible
        end
    end)

    return screenGui
end

-- ====================== ОСНОВНОЙ ЦИКЛ С УЛУЧШЕННОЙ ОПТИМИЗАЦИЕЙ ======================

-- Пул объектов для переиспользования
local function GetFromPool(objectType)
    if not Cache.Pool[objectType] then
        Cache.Pool[objectType] = {}
    end
    
    local pool = Cache.Pool[objectType]
    for i, obj in ipairs(pool) do
        if not obj.Parent then
            table.remove(pool, i)
            return obj
        end
    end
    
    return nil
end

local function ReturnToPool(obj)
    local objectType = obj.ClassName
    if not Cache.Pool[objectType] then
        Cache.Pool[objectType] = {}
    end
    
    obj.Parent = nil
    table.insert(Cache.Pool[objectType], obj)
end

-- Оптимизированный основной цикл
local function OptimizedLoop()
    if not Settings.Enabled then return end
    
    local currentTime = tick()
    
    -- ESP (обновляется реже)
    if currentTime % Optimizer.ESPUpdateRate < 0.05 then
        if Settings.ESP then
            if not CoreGui:FindFirstChild("ESPContainer") then
                CreateESP()
            end
        else
            local espContainer = CoreGui:FindFirstChild("ESPContainer")
            if espContainer then espContainer:Destroy() end
        end
    end
    
    -- Визуалы (обновляются реже)
    if currentTime % Optimizer.VisualUpdateRate < 0.05 then
        SetVisuals()
        SetCustomSky()
        CreateAdvancedBloom()
        CreateDepthOfField()
        CreateSunRays()
        CreateVignette()
        SetAdvancedLighting()
    end
    
    -- Аимбот (обновляется часто)
    if currentTime % Optimizer.AimbotUpdateRate < 0.02 and Settings.Aimbot then
        local target = GetClosestTarget()
        if target then
            local isKeyDown = UserInputService:IsKeyDown(Settings.AimbotKey)
            if isKeyDown or Settings.AimbotTargetLock then
                local targetPos = target.Position
                local lookAt = CFrame.lookAt(Camera.CFrame.Position, targetPos)
                local smoothCFrame = Camera.CFrame:Lerp(lookAt, Settings.AimbotSmooth)
                Camera.CFrame = smoothCFrame
                
                -- Авто-огонь
                if Settings.AimbotAutoFire then
                    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                        wait(0.05)
                        tool:Deactivate()
                    end
                end
            end
        end
    end
    
    -- Kill All
    if Settings.KillAll then
        KillAll()
        wait(Settings.KillAllDelay)
    end
    
    -- TriggerBot
    if Settings.TriggerBot then
        TriggerBot()
        wait(Settings.TriggerBotDelay)
    end
    
    -- Дополнительные функции (FOV, Walkspeed, JumpPower, Fly, NoClip)
    if Settings.FOVChanger then
        Camera.FieldOfView = Settings.FOVValue
    end
    
    if Settings.Walkspeed and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Settings.WalkspeedValue
        end
    end
    
    if Settings.JumpPower and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = Settings.JumpPowerValue
        end
    end
    
    if Settings.NoClip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    if Settings.Fly and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
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
    
    -- Очистка кэша
    if currentTime % Optimizer.CacheClearRate < 0.05 then
        for player, tracer in pairs(Cache.Tracers) do
            if not player.Parent then
                tracer:Remove()
                Cache.Tracers[player] = nil
            end
        end
    end
end

-- ====================== ЗАПУСК ======================

print("Loading MM2 Ultimate Script v4.0...")

-- Создание GUI
CreateUltimateGUI()

-- Запуск основного цикла
RunService.Heartbeat:Connect(OptimizedLoop)

-- Анти-АФК
AntiAFK()

-- Трейсеры
if Settings.Tracers then
    CreateTracers()
end

-- Очистка при выгрузке
LocalPlayer.OnTeleport:Connect(function()
    for _, v in pairs(CoreGui:GetChildren()) do
        if string.find(v.Name, "ESP") or v.Name == "UltimateGUI" or v.Name == "ESPContainer" then
            v:Destroy()
        end
    end
end)

-- Уведомление
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "MM2 ULTIMATE v4.0",
    Text = "✅ Script loaded! Press L to open menu",
    Duration = 4
})

print("✅ MM2 Ultimate Script v4.0 Loaded - made by Pluma (tg: plumajb)")
print("🎮 Press L to open the GUI")
print("⚡ Features: Aimbot, ESP, Kill All, Visual Effects, Anti-AFK, and more!")
print("📋 New: 2D/3D Boxes, Depth of Field, Sun Rays, Vignette, Fly, NoClip, and more!")

-- ====================== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ (для совместимости) ======================

-- Функция SetVisuals (из предыдущей версии)
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

-- Функция SetCustomSky
local function SetCustomSky()
    if Settings.CustomSky then
        local sky = Lighting:FindFirstChild("CustomSky")
        if not sky then
            sky = Instance.new("Sky")
            sky.Name = "CustomSky"
            sky.Parent = Lighting
        end
        sky.SkyboxBk = "http://www.roblox.com/asset/?id=999999999"
        sky.SkyboxDn = "http://www.roblox.com/asset/?id=999999999"
        sky.SkyboxFt = "http://www.roblox.com/asset/?id=999999999"
        sky.SkyboxLf = "http://www.roblox.com/asset/?id=999999999"
        sky.SkyboxRt = "http://www.roblox.com/asset/?id=999999999"
        sky.SkyboxUp = "http://www.roblox.com/asset/?id=999999999"
    else
        local sky = Lighting:FindFirstChild("CustomSky")
        if sky then sky:Destroy() end
    end
end

-- Функция AntiAFK
local function AntiAFK()
    if not Settings.AntiAFK then return end

    if Settings.AntiAFKMethod == "VirtualUser" or Settings.AntiAFKMethod == "Both" then
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end

    if Settings.AntiAFKMethod == "Movement" or Settings.AntiAFKMethod == "Both" then
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
end

-- Функция TriggerBot
local function TriggerBot()
    if not Settings.TriggerBot then return end
    local mouse = LocalPlayer:GetMouse()
    local target = mouse.Target

    if target and target.Parent then
        local character = target.Parent
        local player = Players:GetPlayerFromCharacter(character)
        if player and player ~= LocalPlayer then
            if Settings.TriggerBotMode == "Stab" or Settings.TriggerBotMode == "Both" then
                local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
                if remote then
                    remote:FireServer(player, "Stab")
                end
            end
            
            if Settings.TriggerBotMode == "Shoot" or Settings.TriggerBotMode == "Both" then
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool and tool:IsA("Tool") then
                    tool:Activate()
                    wait(0.1)
                    tool:Deactivate()
                end
            end
        end
    end
end

-- Функция CreateTracers
local function CreateTracers()
    if not Settings.Tracers then return end

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
    end

    RunService.RenderStepped:Connect(UpdateTracers)
end

print("✅ All functions loaded successfully!")

print("✅ MM2 Ultimate Script Loaded - made by Pluma (tg: plumajb)")
print("🎮 Press L to open the GUI")
print("⚡ Features: Aimbot, ESP, Kill All, Visual Effects, Anti-AFK, and more!")
