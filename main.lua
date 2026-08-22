-- Murder Mystery 2 ULTIMATE SCRIPT v4.1 [XENO FIXED]
-- GUI Key: L (можно изменить)
-- Полностью переработан для XENO Executor

-- ====================== ОБХОД БЛОКИРОВОК XENO ======================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

-- ====================== НАСТРОЙКИ (все в одном месте) ======================
local Settings = {
    GUIKey = "L",
    Aimbot = true,
    AimbotFOV = 120,
    AimbotRange = 80,
    AimbotSmooth = 0.25,
    AimbotKey = "LeftAlt",
    ESP = true,
    ESPBoxes = true,
    ESPNames = true,
    ESPRoles = true,
    ESPHealth = true,
    FullBright = false,
    NoFog = false,
    KillAll = false,
    KillAllRange = 100,
    AutoStab = true,
    AutoStabRange = 8,
    TriggerBot = true,
    AntiAFK = true,
    Walkspeed = false,
    WalkspeedValue = 16,
    JumpPower = false,
    JumpPowerValue = 50,
    Fly = false,
    FlySpeed = 50
}

-- ====================== ОБЩАЯ ФУНКЦИЯ БЕЗОПАСНОГО ВЫЗОВА ======================
local function SafeCall(func)
    local success, result = pcall(func)
    if not success then
        warn("[XENO] Ошибка: " .. tostring(result))
        return nil
    end
    return result
end

-- ====================== АИМБОТ ======================
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

-- ====================== ESP (упрощён для XENO) ======================
local function CreateESP()
    SafeCall(function()
        -- Удаляем старый ESP
        for _, v in pairs(CoreGui:GetChildren()) do
            if string.find(v.Name or "", "ESP") then
                v:Destroy()
            end
        end
        
        if not Settings.ESP then return end
        
        local espGui = Instance.new("ScreenGui")
        espGui.Name = "ESP_GUI"
        espGui.ResetOnSpawn = false
        espGui.Parent = CoreGui
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            local character = player.Character
            if not character then continue end
            
            local root = character:FindFirstChild("HumanoidRootPart")
            if not root then continue end
            
            -- Бокс
            if Settings.ESPBoxes then
                local box = Instance.new("BoxHandleAdornment")
                box.Size = Vector3.new(2.5, 4.5, 2.5)
                box.Adornee = root
                box.AlwaysOnTop = true
                box.Color3 = Color3.fromRGB(255, 0, 0)
                box.Transparency = 0.6
                box.Parent = espGui
            end
            
            -- Имя + роль
            if Settings.ESPNames then
                local nameGui = Instance.new("BillboardGui")
                nameGui.Adornee = root
                nameGui.Size = UDim2.new(0, 200, 0, 50)
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
            SafeCall(function()
                -- Метод 1: RemoteEvent
                local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
                if remote then
                    remote:FireServer(player, "Stab")
                end
                
                -- Метод 2: Tool
                local tool = character:FindFirstChildOfClass("Tool")
                if tool then
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

-- ====================== GUI ======================
local function CreateGUI()
    SafeCall(function()
        -- Удаляем старый GUI
        local oldGui = CoreGui:FindFirstChild("MM2_GUI")
        if oldGui then oldGui:Destroy() end
        
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "MM2_GUI"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = CoreGui
        
        local mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(0, 300, 0, 400)
        mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
        mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
        mainFrame.BorderSizePixel = 2
        mainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
        mainFrame.Active = true
        mainFrame.Draggable = true
        mainFrame.Parent = screenGui
        
        -- Заголовок
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 35)
        title.BackgroundTransparency = 1
        title.Text = "⚡ MM2 ULTIMATE ⚡"
        title.TextColor3 = Color3.fromRGB(0, 255, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 18
        title.Parent = mainFrame
        
        -- Кнопка закрытия
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0.15, 0, 0.6, 0)
        closeBtn.Position = UDim2.new(0.85, 0, 0.2, 0)
        closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        closeBtn.Text = "X"
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 14
        closeBtn.BorderSizePixel = 0
        closeBtn.Parent = title
        closeBtn.MouseButton1Click:Connect(function()
            screenGui.Visible = not screenGui.Visible
        end)
        
        -- Функция создания чекбокса
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
                Settings[setting] = not Settings[setting]
                box.Text = (Settings[setting] and "✅ " or "⬜ ") .. name .. ": " .. (Settings[setting] and "ON" or "OFF")
                box.TextColor3 = Settings[setting] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(200, 200, 200)
            end)
            return box
        end
        
        -- Функция создания слайдера
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
                    newVal = math.round(newVal)
                    Settings[setting] = newVal
                    fill.Size = UDim2.new(relX, 0, 1, 0)
                    label.Text = name .. ": " .. tostring(newVal)
                end
            end)
            return slider
        end
        
        -- Combat Tab
        local combatFrame = Instance.new("ScrollingFrame")
        combatFrame.Size = UDim2.new(0.95, 0, 0, 0.7)
        combatFrame.Position = UDim2.new(0.025, 0, 0, 40)
        combatFrame.BackgroundTransparency = 1
        combatFrame.Parent = mainFrame
        
        CreateCheckbox(combatFrame, "Kill All", "KillAll", 5)
        CreateCheckbox(combatFrame, "Auto Stab", "AutoStab", 35)
        CreateCheckbox(combatFrame, "TriggerBot", "TriggerBot", 65)
        CreateSlider(combatFrame, "Kill Range", "KillAllRange", 10, 200, 95)
        CreateSlider(combatFrame, "AutoStab Range", "AutoStabRange", 1, 20, 125)
        
        -- ESP Tab
        local espFrame = Instance.new("ScrollingFrame")
        espFrame.Size = UDim2.new(0.95, 0, 0, 0.7)
        espFrame.Position = UDim2.new(0.025, 0, 0, 40)
        espFrame.BackgroundTransparency = 1
        espFrame.Visible = false
        espFrame.Parent = mainFrame
        
        CreateCheckbox(espFrame, "ESP", "ESP", 5)
        CreateCheckbox(espFrame, "ESP Boxes", "ESPBoxes", 35)
        CreateCheckbox(espFrame, "ESP Names", "ESPNames", 65)
        CreateCheckbox(espFrame, "ESP Roles", "ESPRoles", 95)
        CreateCheckbox(espFrame, "ESP Health", "ESPHealth", 125)
        
        -- Misc Tab
        local miscFrame = Instance.new("ScrollingFrame")
        miscFrame.Size = UDim2.new(0.95, 0, 0, 0.7)
        miscFrame.Position = UDim2.new(0.025, 0, 0, 40)
        miscFrame.BackgroundTransparency = 1
        miscFrame.Visible = false
        miscFrame.Parent = mainFrame
        
        CreateCheckbox(miscFrame, "FullBright", "FullBright", 5)
        CreateCheckbox(miscFrame, "No Fog", "NoFog", 35)
        CreateCheckbox(miscFrame, "Walkspeed", "Walkspeed", 65)
        CreateCheckbox(miscFrame, "Jump Power", "JumpPower", 95)
        CreateCheckbox(miscFrame, "Fly", "Fly", 125)
        CreateCheckbox(miscFrame, "Anti AFK", "AntiAFK", 155)
        CreateSlider(miscFrame, "Walkspeed", "WalkspeedValue", 0, 100, 185)
        CreateSlider(miscFrame, "Jump Power", "JumpPowerValue", 0, 200, 215)
        CreateSlider(miscFrame, "Fly Speed", "FlySpeed", 10, 200, 245)
        
        -- Табы
        local tabs = {"Combat", "ESP", "Misc"}
        for i, tabName in ipairs(tabs) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.33, 0, 0, 25)
            btn.Position = UDim2.new(0.01 + (i-1) * 0.33, 0, 0, 40)
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
            btn.Text = tabName
            btn.TextColor3 = Color3.fromRGB(200, 200, 255)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 12
            btn.BorderSizePixel = 0
            btn.Parent = mainFrame
            
            btn.MouseButton1Click:Connect(function()
                combatFrame.Visible = (tabName == "Combat")
                espFrame.Visible = (tabName == "ESP")
                miscFrame.Visible = (tabName == "Misc")
                for _, b in pairs(mainFrame:GetChildren()) do
                    if b:IsA("TextButton") and b.Size.Y.Offset == 25 and b.Text ~= "X" then
                        b.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
                    end
                end
                btn.BackgroundColor3 = Color3.fromRGB(60, 40, 80)
            end)
        end
        
        -- Кнопка Kill All
        local killBtn = Instance.new("TextButton")
        killBtn.Size = UDim2.new(0.4, 0, 0, 35)
        killBtn.Position = UDim2.new(0.3, 0, 0, 355)
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
            print("[XENO] Kill All executed!")
        end)
        
        -- Обработчик клавиши L
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == Enum.KeyCode[Settings.GUIKey] then
                screenGui.Visible = not screenGui.Visible
            end
        end)
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
            if not CoreGui:FindFirstChild("ESP_GUI") then
                CreateESP()
            end
        else
            local espGui = CoreGui:FindFirstChild("ESP_GUI")
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
        
        -- Walkspeed / JumpPower
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
        end
    end)
end

-- ====================== ЗАПУСК ======================
print("[XENO] Loading MM2 Ultimate...")

-- Создание GUI
CreateGUI()

-- Запуск основного цикла
RunService.Heartbeat:Connect(MainLoop)

-- Уведомление
StarterGui:SetCore("SendNotification", {
    Title = "MM2 ULTIMATE [XENO]",
    Text = "✅ Script loaded! Press L to open menu",
    Duration = 4
})

print("[XENO] ✅ MM2 Ultimate loaded successfully!")
print("[XENO] 🎮 Press L to open the GUI")
