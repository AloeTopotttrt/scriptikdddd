-- Murder Mystery 2 ULTIMATE SCRIPT v5.3 [XENO] - ЦВЕТНАЯ ПОДСВЕТКА РОЛЕЙ
-- GUI Key: L
-- Innocent = Зелёный, Murderer = Красный, Sheriff = Синий

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

-- ====================== НАСТРОЙКИ ======================
local Settings = {
    -- Combat
    KillAll = false,
    KillAllRange = 100,
    KillAllDelay = 0.5,
    AutoStab = true,
    AutoStabRange = 8,
    TriggerBot = true,
    TriggerBotDelay = 0.1,
    
    -- Aimbot
    Aimbot = true,
    AimbotFOV = 120,
    AimbotRange = 80,
    AimbotSmooth = 0.3,
    AimbotKey = "LeftAlt",
    
    -- ESP
    ESP = true,
    ESPBoxes = true,
    ESPNames = true,
    ESPRoles = true,
    ESPHealth = true,
    ESPHeadDot = true,
    
    -- Visuals
    FullBright = false,
    NoFog = false,
    Bloom = true,
    Saturation = 1.2,
    
    -- Misc
    Walkspeed = false,
    WalkspeedValue = 16,
    JumpPower = false,
    JumpPowerValue = 50,
    Fly = false,
    FlySpeed = 50,
    AntiAFK = true,
    TeamCheck = false
}

-- ====================== ЦВЕТА РОЛЕЙ ======================
local ROLE_COLORS = {
    Innocent = Color3.fromRGB(0, 255, 0),    -- Зелёный
    Murderer = Color3.fromRGB(255, 0, 0),    -- Красный
    Sheriff = Color3.fromRGB(0, 100, 255)    -- Синий
}

-- ====================== БЕЗОПАСНЫЙ ВЫЗОВ ======================
local function SafeCall(func)
    local success, err = pcall(func)
    if not success then
        warn("[XENO] Error: " .. tostring(err))
        return nil
    end
    return true
end

-- ====================== СОЗДАНИЕ GUI ======================
local GUI = {}
GUI.Visible = true

local function CreateGUI()
    SafeCall(function()
        -- Удаляем старый GUI
        for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
            if v.Name == "MM2_GUI" then
                v:Destroy()
            end
        end
        
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "MM2_GUI"
        screenGui.Parent = LocalPlayer.PlayerGui
        
        -- Основное окно
        local mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(0, 350, 0, 500)
        mainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
        mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
        mainFrame.BorderSizePixel = 2
        mainFrame.BorderColor3 = Color3.fromRGB(0, 200, 255)
        mainFrame.Active = true
        mainFrame.Draggable = true
        mainFrame.Parent = screenGui
        
        -- Заголовок
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 35)
        title.BackgroundTransparency = 1
        title.Text = "⚡ MM2 ULTIMATE v5.3 ⚡"
        title.TextColor3 = Color3.fromRGB(0, 255, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 18
        title.Parent = mainFrame
        
        -- Кнопка закрытия
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0.12, 0, 0.7, 0)
        closeBtn.Position = UDim2.new(0.88, 0, 0.15, 0)
        closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        closeBtn.Text = "X"
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 14
        closeBtn.BorderSizePixel = 0
        closeBtn.Parent = title
        closeBtn.MouseButton1Down:Connect(function()
            GUI.Visible = not GUI.Visible
            mainFrame.Visible = GUI.Visible
        end)
        
        -- Контейнер для вкладок
        local tabContainer = Instance.new("Frame")
        tabContainer.Size = UDim2.new(1, 0, 0, 35)
        tabContainer.Position = UDim2.new(0, 0, 0, 38)
        tabContainer.BackgroundTransparency = 1
        tabContainer.Parent = mainFrame
        
        -- Контейнер для содержимого
        local contentContainer = Instance.new("Frame")
        contentContainer.Size = UDim2.new(1, 0, 1, -78)
        contentContainer.Position = UDim2.new(0, 0, 0, 78)
        contentContainer.BackgroundTransparency = 1
        contentContainer.Parent = mainFrame
        
        -- Вкладки
        local tabs = {"Combat", "Aimbot", "ESP", "Visuals", "Misc"}
        local tabButtons = {}
        local contentFrames = {}
        
        for i, tabName in ipairs(tabs) do
            -- Кнопка вкладки
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.2, 0, 1, 0)
            btn.Position = UDim2.new(0.05 + (i-1) * 0.2, 0, 0, 0)
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
            btn.Text = tabName
            btn.TextColor3 = Color3.fromRGB(200, 200, 255)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 11
            btn.BorderSizePixel = 1
            btn.BorderColor3 = Color3.fromRGB(60, 60, 80)
            btn.Parent = tabContainer
            
            -- Контент вкладки (ScrollingFrame)
            local content = Instance.new("ScrollingFrame")
            content.Size = UDim2.new(1, 0, 1, 0)
            content.Position = UDim2.new(0, 0, 0, 0)
            content.BackgroundTransparency = 1
            content.BorderSizePixel = 0
            content.CanvasSize = UDim2.new(0, 0, 0, 0)
            content.ScrollBarThickness = 6
            content.Visible = (i == 1)
            content.Parent = contentContainer
            
            contentFrames[tabName] = content
            tabButtons[tabName] = btn
            
            btn.MouseButton1Down:Connect(function()
                for name, frame in pairs(contentFrames) do
                    frame.Visible = (name == tabName)
                end
                for name, button in pairs(tabButtons) do
                    button.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
                end
                btn.BackgroundColor3 = Color3.fromRGB(80, 40, 100)
            end)
        end
        tabButtons["Combat"].BackgroundColor3 = Color3.fromRGB(80, 40, 100)
        
        -- Функции создания элементов
        local function CreateCheckbox(parent, name, setting, yPos)
            local box = Instance.new("TextButton")
            box.Size = UDim2.new(0.9, 0, 0, 28)
            box.Position = UDim2.new(0.05, 0, 0, yPos)
            box.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
            box.Text = "⬜ " .. name .. ": OFF"
            box.TextColor3 = Color3.fromRGB(200, 200, 200)
            box.Font = Enum.Font.Gotham
            box.TextSize = 13
            box.TextXAlignment = Enum.TextXAlignment.Left
            box.BorderSizePixel = 0
            box.Parent = parent
            
            box.MouseButton1Down:Connect(function()
                Settings[setting] = not Settings[setting]
                box.Text = (Settings[setting] and "✅ " or "⬜ ") .. name .. ": " .. (Settings[setting] and "ON" or "OFF")
                box.TextColor3 = Settings[setting] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(200, 200, 200)
            end)
            
            parent.CanvasSize = UDim2.new(0, 0, 0, yPos + 40)
            return box
        end
        
        local function CreateSlider(parent, name, setting, min, max, yPos, isFloat)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.4, 0, 0, 22)
            label.Position = UDim2.new(0.05, 0, 0, yPos)
            label.BackgroundTransparency = 1
            label.Text = name .. ": " .. tostring(Settings[setting])
            label.TextColor3 = Color3.fromRGB(200, 200, 255)
            label.Font = Enum.Font.Gotham
            label.TextSize = 12
            label.Parent = parent
            
            local slider = Instance.new("TextButton")
            slider.Size = UDim2.new(0.45, 0, 0, 22)
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
                    if not isFloat then
                        newVal = math.round(newVal)
                    else
                        newVal = math.round(newVal * 100) / 100
                    end
                    Settings[setting] = newVal
                    fill.Size = UDim2.new(relX, 0, 1, 0)
                    label.Text = name .. ": " .. tostring(newVal)
                end
            end)
            
            parent.CanvasSize = UDim2.new(0, 0, 0, yPos + 40)
            return slider
        end
        
        -- ===== ЗАПОЛНЕНИЕ ВКЛАДОК =====
        
        -- 1. COMBAT TAB
        local combatFrame = contentFrames["Combat"]
        local y = 5
        CreateCheckbox(combatFrame, "Kill All", "KillAll", y); y = y + 32
        CreateCheckbox(combatFrame, "Auto Stab", "AutoStab", y); y = y + 32
        CreateCheckbox(combatFrame, "TriggerBot", "TriggerBot", y); y = y + 32
        CreateCheckbox(combatFrame, "Team Check", "TeamCheck", y); y = y + 38
        CreateSlider(combatFrame, "Kill Range", "KillAllRange", 10, 200, y); y = y + 30
        CreateSlider(combatFrame, "AutoStab Range", "AutoStabRange", 1, 20, y); y = y + 30
        CreateSlider(combatFrame, "TriggerBot Delay", "TriggerBotDelay", 0.05, 0.5, y, true); y = y + 30
        combatFrame.CanvasSize = UDim2.new(0, 0, 0, y + 20)
        
        -- 2. AIMBOT TAB
        local aimbotFrame = contentFrames["Aimbot"]
        y = 5
        CreateCheckbox(aimbotFrame, "Aimbot", "Aimbot", y); y = y + 32
        CreateCheckbox(aimbotFrame, "Team Check", "TeamCheck", y); y = y + 38
        CreateSlider(aimbotFrame, "FOV", "AimbotFOV", 10, 180, y); y = y + 30
        CreateSlider(aimbotFrame, "Range", "AimbotRange", 10, 200, y); y = y + 30
        CreateSlider(aimbotFrame, "Smoothness", "AimbotSmooth", 0, 1, y, true); y = y + 30
        aimbotFrame.CanvasSize = UDim2.new(0, 0, 0, y + 20)
        
        -- 3. ESP TAB
        local espFrame = contentFrames["ESP"]
        y = 5
        CreateCheckbox(espFrame, "ESP", "ESP", y); y = y + 32
        CreateCheckbox(espFrame, "ESP Boxes", "ESPBoxes", y); y = y + 32
        CreateCheckbox(espFrame, "ESP Names", "ESPNames", y); y = y + 32
        CreateCheckbox(espFrame, "ESP Roles", "ESPRoles", y); y = y + 32
        CreateCheckbox(espFrame, "ESP Health", "ESPHealth", y); y = y + 32
        CreateCheckbox(espFrame, "ESP Head Dot", "ESPHeadDot", y); y = y + 32
        espFrame.CanvasSize = UDim2.new(0, 0, 0, y + 20)
        
        -- 4. VISUALS TAB
        local visualsFrame = contentFrames["Visuals"]
        y = 5
        CreateCheckbox(visualsFrame, "FullBright", "FullBright", y); y = y + 32
        CreateCheckbox(visualsFrame, "No Fog", "NoFog", y); y = y + 32
        CreateCheckbox(visualsFrame, "Bloom", "Bloom", y); y = y + 38
        CreateSlider(visualsFrame, "Saturation", "Saturation", 0, 2, y, true); y = y + 30
        visualsFrame.CanvasSize = UDim2.new(0, 0, 0, y + 20)
        
        -- 5. MISC TAB
        local miscFrame = contentFrames["Misc"]
        y = 5
        CreateCheckbox(miscFrame, "Walkspeed", "Walkspeed", y); y = y + 32
        CreateCheckbox(miscFrame, "Jump Power", "JumpPower", y); y = y + 32
        CreateCheckbox(miscFrame, "Fly", "Fly", y); y = y + 32
        CreateCheckbox(miscFrame, "Anti AFK", "AntiAFK", y); y = y + 38
        CreateSlider(miscFrame, "Walkspeed", "WalkspeedValue", 0, 100, y); y = y + 30
        CreateSlider(miscFrame, "Jump Power", "JumpPowerValue", 0, 200, y); y = y + 30
        CreateSlider(miscFrame, "Fly Speed", "FlySpeed", 10, 200, y); y = y + 30
        miscFrame.CanvasSize = UDim2.new(0, 0, 0, y + 20)
        
        -- Кнопка KILL ALL
        local killBtn = Instance.new("TextButton")
        killBtn.Size = UDim2.new(0.4, 0, 0, 35)
        killBtn.Position = UDim2.new(0.3, 0, 0, 455)
        killBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        killBtn.Text = "💀 KILL ALL 💀"
        killBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        killBtn.Font = Enum.Font.GothamBold
        killBtn.TextSize = 14
        killBtn.Parent = mainFrame
        killBtn.MouseButton1Down:Connect(function()
            Settings.KillAll = true
            KillAll()
            Settings.KillAll = false
            print("[XENO] Kill All executed!")
        end)
        
        -- Обработчик клавиши L
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == Enum.KeyCode.L then
                GUI.Visible = not GUI.Visible
                mainFrame.Visible = GUI.Visible
            end
        end)
        
        GUI.Visible = true
        mainFrame.Visible = true
        
        print("[XENO] GUI created successfully!")
    end)
end

-- ====================== ОСНОВНЫЕ ФУНКЦИИ (С ЦВЕТАМИ) ======================

-- Функция получения цвета по роли
local function GetRoleColor(player)
    local role = player:GetAttribute("Role") or "Innocent"
    return ROLE_COLORS[role] or ROLE_COLORS.Innocent
end

-- Аимбот
local function GetClosestTarget()
    local character = LocalPlayer.Character
    if not character then return nil end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local bestTarget = nil
    local bestScore = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
        
        local targetChar = player.Character
        if not targetChar then continue end
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if not targetRoot then continue end
        local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        local distance = (root.Position - targetRoot.Position).Magnitude
        if distance > Settings.AimbotRange then continue end
        
        local lookDirection = Camera.CFrame.LookVector
        local toTarget = (targetRoot.Position - Camera.CFrame.Position).Unit
        local angle = math.deg(math.acos(lookDirection:Dot(toTarget)))
        if angle > Settings.AimbotFOV / 2 then continue end
        
        local score = distance * 0.6 + angle * 0.4
        if score < bestScore then
            bestScore = score
            bestTarget = targetRoot
        end
    end
    return bestTarget
end

-- Kill All
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
            SafeCall(function()
                local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
                if remote then
                    remote:FireServer(player, "Stab")
                end
            end)
            wait(Settings.KillAllDelay)
        end
    end
end

-- TriggerBot
local function TriggerBot()
    if not Settings.TriggerBot then return end
    local mouse = LocalPlayer:GetMouse()
    if not mouse then return end
    local target = mouse.Target
    if not target or not target.Parent then return end
    
    local character = target.Parent
    local player = Players:GetPlayerFromCharacter(character)
    if not player or player == LocalPlayer then return end
    
    SafeCall(function()
        local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
        if remote then
            remote:FireServer(player, "Stab")
        end
    end)
end

-- ====================== ESP С ЦВЕТНОЙ ПОДСВЕТКОЙ РОЛЕЙ ======================
local ESPObjects = {}

local function CreateESP()
    if not Settings.ESP then
        -- Удаляем ESP
        for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
            if string.find(v.Name, "ESP") then
                v:Destroy()
            end
        end
        ESPObjects = {}
        return
    end
    
    SafeCall(function()
        -- Удаляем старый ESP
        for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
            if string.find(v.Name, "ESP") then
                v:Destroy()
            end
        end
        ESPObjects = {}
        
        local espGui = Instance.new("ScreenGui")
        espGui.Name = "ESP_GUI"
        espGui.Parent = LocalPlayer.PlayerGui
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            local character = player.Character
            if not character then continue end
            
            local root = character:FindFirstChild("HumanoidRootPart")
            if not root then continue end
            
            -- Получаем цвет по роли
            local color = GetRoleColor(player)
            local role = player:GetAttribute("Role") or "Innocent"
            
            -- 1. БОКС (Box) - цвет зависит от роли
            if Settings.ESPBoxes then
                local box = Instance.new("BoxHandleAdornment")
                box.Size = Vector3.new(2.5, 4.5, 2.5)
                box.Adornee = root
                box.AlwaysOnTop = true
                box.Color3 = color
                box.Transparency = 0.5
                box.Parent = espGui
                table.insert(ESPObjects, box)
            end
            
            -- 2. ИМЯ + РОЛЬ
            if Settings.ESPNames then
                local nameGui = Instance.new("BillboardGui")
                nameGui.Adornee = root
                nameGui.Size = UDim2.new(0, 220, 0, 50)
                nameGui.StudsOffset = Vector3.new(0, 3.5, 0)
                nameGui.AlwaysOnTop = true
                nameGui.Parent = espGui
                
                -- Имя игрока (белое)
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = player.Name
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.TextScaled = true
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.Parent = nameGui
                
                -- Роль (цветная)
                if Settings.ESPRoles then
                    local roleLabel = Instance.new("TextLabel")
                    roleLabel.Size = UDim2.new(1, 0, 0.5, 0)
                    roleLabel.Position = UDim2.new(0, 0, 0.5, 0)
                    roleLabel.BackgroundTransparency = 1
                    roleLabel.Text = role
                    roleLabel.TextColor3 = color
                    roleLabel.TextScaled = true
                    roleLabel.Font = Enum.Font.GothamBold
                    roleLabel.Parent = nameGui
                end
            end
            
            -- 3. ТОЧКА НА ГОЛОВЕ (цветная)
            if Settings.ESPHeadDot then
                local head = character:FindFirstChild("Head")
                if head then
                    local dot = Instance.new("BillboardGui")
                    dot.Adornee = head
                    dot.Size = UDim2.new(0, 15, 0, 15)
                    dot.AlwaysOnTop = true
                    dot.Parent = espGui
                    
                    local circle = Instance.new("Frame")
                    circle.Size = UDim2.new(1, 0, 1, 0)
                    circle.BackgroundColor3 = color
                    circle.BorderSizePixel = 0
                    circle.Parent = dot
                    
                    local corner = Instance.new("UICorner")
                    corner.CornerRadius = UDim.new(1, 0)
                    corner.Parent = circle
                end
            end
            
            -- 4. HP БАР (зелёный → красный в зависимости от здоровья)
            if Settings.ESPHealth then
                local healthBar = Instance.new("BillboardGui")
                healthBar.Adornee = root
                healthBar.Size = UDim2.new(0, 50, 0, 5)
                healthBar.StudsOffset = Vector3.new(0, 2.5, 0)
                healthBar.AlwaysOnTop = true
                healthBar.Parent = espGui
                
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
            end
        end
        
        -- Подписываемся на изменения ролей (динамическое обновление)
        local function UpdateESP()
            -- Просто пересоздаём ESP при смене роли
            CreateESP()
        end
        
        -- Следим за изменением роли у всех игроков
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                player:GetAttributeChangedSignal("Role"):Connect(UpdateESP)
            end
        end
    end)
end

-- ====================== ОСНОВНОЙ ЦИКЛ ======================
local function MainLoop()
    SafeCall(function()
        -- Аимбот
        if Settings.Aimbot then
            local target = GetClosestTarget()
            if target and UserInputService:IsKeyDown(Enum.KeyCode[Settings.AimbotKey]) then
                local targetPos = target.Position
                local lookAt = CFrame.lookAt(Camera.CFrame.Position, targetPos)
                Camera.CFrame = Camera.CFrame:Lerp(lookAt, Settings.AimbotSmooth)
            end
        end
        
        -- ESP (обновляем раз в 5 секунд для синхронизации цветов)
        if Settings.ESP then
            if not LocalPlayer.PlayerGui:FindFirstChild("ESP_GUI") then
                CreateESP()
            end
        else
            local espGui = LocalPlayer.PlayerGui:FindFirstChild("ESP_GUI")
            if espGui then espGui:Destroy() end
            ESPObjects = {}
        end
        
        -- Visuals
        if Settings.FullBright then
            Lighting.Brightness = 5
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        else
            Lighting.Brightness = 1
            Lighting.Ambient = Color3.fromRGB(100, 100, 100)
        end
        
        if Settings.NoFog then
            Lighting.FogEnd = 1000
        else
            Lighting.FogEnd = 500
        end
        
        -- Bloom
        if Settings.Bloom then
            local bloom = Lighting:FindFirstChild("Bloom")
            if not bloom then
                bloom = Instance.new("BloomEffect")
                bloom.Name = "Bloom"
                bloom.Parent = Lighting
            end
            bloom.Intensity = 0.5
            bloom.Size = 50
            bloom.Threshold = 0.8
        else
            local bloom = Lighting:FindFirstChild("Bloom")
            if bloom then bloom:Destroy() end
        end
        
        -- Saturation
        local cc = Lighting:FindFirstChild("ColorCorrection")
        if not cc then
            cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "ColorCorrection"
            cc.Parent = Lighting
        end
        cc.Saturation = Settings.Saturation
        cc.Contrast = 1.1
        
        -- Walkspeed / JumpPower / Fly
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                if Settings.Walkspeed then
                    humanoid.WalkSpeed = Settings.WalkspeedValue
                end
                
                if Settings.JumpPower then
                    humanoid.JumpPower = Settings.JumpPowerValue
                end
                
                if Settings.Fly then
                    humanoid.PlatformStand = true
                    local root = character:FindFirstChild("HumanoidRootPart")
                    if root then
                        local direction = Vector3.new()
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + Camera.CFrame.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - Camera.CFrame.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - Camera.CFrame.RightVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + Camera.CFrame.RightVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0, 1, 0) end
                        if direction.Magnitude > 0 then
                            root.Velocity = direction.Unit * Settings.FlySpeed
                        end
                    end
                end
            end
        end
        
        -- TriggerBot
        if Settings.TriggerBot then
            TriggerBot()
            wait(Settings.TriggerBotDelay)
        end
        
        -- AutoStab
        if Settings.AutoStab then
            local character = LocalPlayer.Character
            if character then
                local root = character:FindFirstChild("HumanoidRootPart")
                if root then
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player == LocalPlayer then continue end
                        local targetChar = player.Character
                        if not targetChar then continue end
                        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                        if not targetRoot then continue end
                        
                        local distance = (root.Position - targetRoot.Position).Magnitude
                        if distance <= Settings.AutoStabRange then
                            SafeCall(function()
                                local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
                                if remote then
                                    remote:FireServer(player, "Stab")
                                end
                            end)
                            break
                        end
                    end
                end
            end
        end
    end)
end

-- ====================== ЗАПУСК ======================
print("[XENO] Loading MM2 Ultimate v5.3 (Color Roles)...")

-- Создание GUI
CreateGUI()

-- Запуск основного цикла
RunService.Heartbeat:Connect(MainLoop)

-- Анти-АФК
if Settings.AntiAFK then
    SafeCall(function()
        local VirtualUser = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

-- Уведомление
StarterGui:SetCore("SendNotification", {
    Title = "MM2 ULTIMATE v5.3",
    Text = "✅ Script loaded! Press L to open/close menu\n🟢 Innocent | 🔴 Murderer | 🔵 Sheriff",
    Duration = 5
})

print("[XENO] ✅ MM2 Ultimate v5.3 loaded successfully!")
print("[XENO] 🎮 Press L to open/close the GUI")
print("[XENO] 🟢 Innocent = Green | 🔴 Murderer = Red | 🔵 Sheriff = Blue")
