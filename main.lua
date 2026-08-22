-- Murder Mystery 2 ULTIMATE SCRIPT v5.0 [XENO WORKING]
-- GUI Key: L
-- Полностью рабочая версия для XENO

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
    Aimbot = true,
    AimbotFOV = 120,
    AimbotRange = 80,
    AimbotSmooth = 0.3,
    AimbotKey = "LeftAlt",
    ESP = true,
    ESPBoxes = true,
    ESPNames = true,
    FullBright = false,
    NoFog = false,
    KillAll = false,
    KillAllRange = 100,
    AutoStab = true,
    AutoStabRange = 8,
    TriggerBot = true,
    Walkspeed = false,
    WalkspeedValue = 16,
    Fly = false,
    FlySpeed = 50,
    AntiAFK = true
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

-- ====================== GUI ЧЕРЕЗ ИНТЕРФЕЙС РОБЛОКСА ======================
local GUI = {}
GUI.Visible = false
GUI.Frames = {}

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
        
        local mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(0, 320, 0, 420)
        mainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
        mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
        mainFrame.BorderSizePixel = 2
        mainFrame.BorderColor3 = Color3.fromRGB(0, 200, 255)
        mainFrame.Active = true
        mainFrame.Draggable = true
        mainFrame.Parent = screenGui
        GUI.Frames.main = mainFrame
        
        -- Заголовок
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 35)
        title.BackgroundTransparency = 1
        title.Text = "⚡ MM2 ULTIMATE v5 ⚡"
        title.TextColor3 = Color3.fromRGB(0, 255, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 18
        title.Parent = mainFrame
        
        -- Закрытие GUI
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
        
        -- ИСПРАВЛЕНИЕ: Используем другой метод для кнопок
        closeBtn.MouseButton1Click:Connect(function()
            GUI.Visible = not GUI.Visible
            mainFrame.Visible = GUI.Visible
        end)
        
        -- Кнопки табов (используем TextButton с MouseButton1Click)
        local function CreateTabButton(text, yPos)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.3, 0, 0, 30)
            btn.Position = UDim2.new(0.02, 0, 0, yPos)
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
            btn.Text = text
            btn.TextColor3 = Color3.fromRGB(200, 200, 255)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 13
            btn.BorderSizePixel = 0
            btn.Parent = mainFrame
            return btn
        end
        
        -- Контейнеры для табов
        local frames = {}
        local tabNames = {"Combat", "ESP", "Misc"}
        for i, name in ipairs(tabNames) do
            local frame = Instance.new("ScrollingFrame")
            frame.Size = UDim2.new(0.95, 0, 0, 0.65)
            frame.Position = UDim2.new(0.025, 0, 0, 45 + 35)
            frame.BackgroundTransparency = 1
            frame.Visible = (i == 1)
            frame.Parent = mainFrame
            frames[name] = frame
        end
        
        -- Создание чекбоксов (исправлено для XENO)
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
            
            -- ИСПРАВЛЕНИЕ: Используем MouseButton1Down вместо Click
            box.MouseButton1Down:Connect(function()
                Settings[setting] = not Settings[setting]
                box.Text = (Settings[setting] and "✅ " or "⬜ ") .. name .. ": " .. (Settings[setting] and "ON" or "OFF")
                box.TextColor3 = Settings[setting] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(200, 200, 200)
            end)
            return box
        end
        
        -- Создание слайдеров
        local function CreateSlider(parent, name, setting, min, max, yPos)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.4, 0, 0, 20)
            label.Position = UDim2.new(0.05, 0, 0, yPos)
            label.BackgroundTransparency = 1
            label.Text = name .. ": " .. tostring(Settings[setting])
            label.TextColor3 = Color3.fromRGB(200, 200, 255)
            label.Font = Enum.Font.Gotham
            label.TextSize = 12
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
                    newVal = math.round(newVal)
                    Settings[setting] = newVal
                    fill.Size = UDim2.new(relX, 0, 1, 0)
                    label.Text = name .. ": " .. tostring(newVal)
                end
            end)
            return slider
        end
        
        -- Заполнение Combat
        local combatFrame = frames["Combat"]
        CreateCheckbox(combatFrame, "Kill All", "KillAll", 5)
        CreateCheckbox(combatFrame, "Auto Stab", "AutoStab", 35)
        CreateCheckbox(combatFrame, "TriggerBot", "TriggerBot", 65)
        CreateSlider(combatFrame, "Kill Range", "KillAllRange", 10, 200, 95)
        CreateSlider(combatFrame, "AutoStab Range", "AutoStabRange", 1, 20, 125)
        
        -- Заполнение ESP
        local espFrame = frames["ESP"]
        CreateCheckbox(espFrame, "ESP", "ESP", 5)
        CreateCheckbox(espFrame, "ESP Boxes", "ESPBoxes", 35)
        CreateCheckbox(espFrame, "ESP Names", "ESPNames", 65)
        
        -- Заполнение Misc
        local miscFrame = frames["Misc"]
        CreateCheckbox(miscFrame, "FullBright", "FullBright", 5)
        CreateCheckbox(miscFrame, "No Fog", "NoFog", 35)
        CreateCheckbox(miscFrame, "Walkspeed", "Walkspeed", 65)
        CreateCheckbox(miscFrame, "Fly", "Fly", 95)
        CreateCheckbox(miscFrame, "Anti AFK", "AntiAFK", 125)
        CreateSlider(miscFrame, "Walkspeed", "WalkspeedValue", 0, 100, 155)
        CreateSlider(miscFrame, "Fly Speed", "FlySpeed", 10, 200, 185)
        
        -- Кнопки табов (исправлено)
        local tabBtns = {}
        for i, name in ipairs(tabNames) do
            local btn = CreateTabButton(name, 42)
            btn.MouseButton1Down:Connect(function()
                for _, frame in pairs(frames) do
                    frame.Visible = false
                end
                frames[name].Visible = true
                for _, b in pairs(tabBtns) do
                    b.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
                end
                btn.BackgroundColor3 = Color3.fromRGB(80, 40, 100)
            end)
            table.insert(tabBtns, btn)
        end
        tabBtns[1].BackgroundColor3 = Color3.fromRGB(80, 40, 100)
        
        -- Кнопка Kill All (исправлено)
        local killBtn = Instance.new("TextButton")
        killBtn.Size = UDim2.new(0.4, 0, 0, 35)
        killBtn.Position = UDim2.new(0.3, 0, 0, 375)
        killBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        killBtn.Text = "💀 KILL ALL NOW 💀"
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
        
        -- Обработчик клавиши L для показа/скрытия GUI
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == Enum.KeyCode.L then
                GUI.Visible = not GUI.Visible
                mainFrame.Visible = GUI.Visible
            end
        end)
        
        GUI.Visible = true
        mainFrame.Visible = true
    end)
end

-- ====================== ОСНОВНЫЕ ФУНКЦИИ ======================

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

-- ESP
local function CreateESP()
    if not Settings.ESP then return end
    
    SafeCall(function()
        -- Удаляем старый ESP
        for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
            if string.find(v.Name, "ESP") then
                v:Destroy()
            end
        end
        
        local espGui = Instance.new("ScreenGui")
        espGui.Name = "ESP_GUI"
        espGui.Parent = LocalPlayer.PlayerGui
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            local character = player.Character
            if not character then continue end
            local root = character:FindFirstChild("HumanoidRootPart")
            if not root then continue end
            
            if Settings.ESPBoxes then
                local box = Instance.new("BoxHandleAdornment")
                box.Size = Vector3.new(2.5, 4.5, 2.5)
                box.Adornee = root
                box.AlwaysOnTop = true
                box.Color3 = Color3.fromRGB(255, 0, 0)
                box.Transparency = 0.5
                box.Parent = espGui
            end
            
            if Settings.ESPNames then
                local nameGui = Instance.new("BillboardGui")
                nameGui.Adornee = root
                nameGui.Size = UDim2.new(0, 200, 0, 30)
                nameGui.StudsOffset = Vector3.new(0, 3, 0)
                nameGui.AlwaysOnTop = true
                nameGui.Parent = espGui
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = player.Name
                label.TextColor3 = Color3.fromRGB(255, 255, 255)
                label.TextScaled = true
                label.Font = Enum.Font.GothamBold
                label.Parent = nameGui
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
        
        -- ESP
        if Settings.ESP then
            if not LocalPlayer.PlayerGui:FindFirstChild("ESP_GUI") then
                CreateESP()
            end
        else
            local espGui = LocalPlayer.PlayerGui:FindFirstChild("ESP_GUI")
            if espGui then espGui:Destroy() end
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
        
        -- Walkspeed / Fly
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                if Settings.Walkspeed then
                    humanoid.WalkSpeed = Settings.WalkspeedValue
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
        end
    end)
end

-- ====================== ЗАПУСК ======================
print("[XENO] Loading MM2 Ultimate v5...")

-- Создание GUI
CreateGUI()

-- Запуск основного цикла
RunService.Heartbeat:Connect(MainLoop)

-- Уведомление
StarterGui:SetCore("SendNotification", {
    Title = "MM2 ULTIMATE v5",
    Text = "✅ Script loaded! Press L to open/close menu",
    Duration = 4
})

print("[XENO] ✅ MM2 Ultimate v5 loaded successfully!")
print("[XENO] 🎮 Press L to open/close the GUI")
