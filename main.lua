-- Murder Mystery 2 ULTIMATE SCRIPT v6.0 [XENO WORKING]
-- Простая и стабильная версия

print("[XENO] Загрузка MM2 Ultimate...")

-- ====================== ОСНОВНЫЕ НАСТРОЙКИ ======================
local Settings = {
    -- Режимы
    Aimbot = true,
    ESP = true,
    KillAll = false,
    AutoStab = true,
    TriggerBot = true,
    Fly = false,
    NoClip = false,
    FullBright = false,
    NoFog = false,
    
    -- Параметры
    AimbotFOV = 120,
    AimbotRange = 80,
    AimbotSmooth = 0.3,
    KillAllRange = 100,
    AutoStabRange = 8,
    WalkspeedValue = 16,
    FlySpeed = 50,
    
    -- Клавиши
    AimbotKey = "LeftAlt",
    ToggleMenu = "L",
    ToggleFly = "K",
    ToggleNoClip = "N",
    KillAllKey = "End"
}

-- ====================== СЕРВИСЫ ======================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

-- ====================== ФУНКЦИИ БЕЗОПАСНОСТИ ======================
local function SafeCall(func)
    local success, err = pcall(func)
    if not success then
        warn("[XENO] Ошибка: " .. tostring(err))
    end
    return success
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
                local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
                if remote then
                    remote:FireServer(player, "Stab")
                end
            end)
            wait(0.3)
        end
    end
end

-- ====================== ESP ======================
local function CreateESP()
    if not Settings.ESP then
        for _, v in pairs(CoreGui:GetChildren()) do
            if string.find(v.Name, "ESP") then
                v:Destroy()
            end
        end
        return
    end
    
    SafeCall(function()
        for _, v in pairs(CoreGui:GetChildren()) do
            if string.find(v.Name, "ESP") then
                v:Destroy()
            end
        end
        
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
            
            -- Цвет по роли
            local role = player:GetAttribute("Role") or "Innocent"
            local color = Color3.fromRGB(0, 255, 0) -- Innocent = зелёный
            if role == "Murderer" then color = Color3.fromRGB(255, 0, 0) end
            if role == "Sheriff" then color = Color3.fromRGB(0, 100, 255) end
            
            -- Бокс
            local box = Instance.new("BoxHandleAdornment")
            box.Size = Vector3.new(2.5, 4.5, 2.5)
            box.Adornee = root
            box.AlwaysOnTop = true
            box.Color3 = color
            box.Transparency = 0.5
            box.Parent = espGui
            
            -- Имя
            local nameGui = Instance.new("BillboardGui")
            nameGui.Adornee = root
            nameGui.Size = UDim2.new(0, 200, 0, 40)
            nameGui.StudsOffset = Vector3.new(0, 3, 0)
            nameGui.AlwaysOnTop = true
            nameGui.Parent = espGui
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = player.Name .. " [" .. role .. "]"
            label.TextColor3 = color
            label.TextScaled = true
            label.Font = Enum.Font.GothamBold
            label.Parent = nameGui
        end
    end)
end

-- ====================== СОЗДАНИЕ МЕНЮ ======================
local function CreateMenu()
    SafeCall(function()
        for _, v in pairs(CoreGui:GetChildren()) do
            if v.Name == "MM2_Menu" then
                v:Destroy()
            end
        end
        
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "MM2_Menu"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = CoreGui
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 250, 0, 350)
        frame.Position = UDim2.new(0.5, -125, 0.5, -175)
        frame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
        frame.BackgroundTransparency = 0.1
        frame.BorderSizePixel = 2
        frame.BorderColor3 = Color3.fromRGB(0, 200, 255)
        frame.Active = true
        frame.Draggable = true
        frame.Parent = screenGui
        
        -- Заголовок
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 30)
        title.BackgroundTransparency = 1
        title.Text = "⚡ MM2 ULTIMATE ⚡"
        title.TextColor3 = Color3.fromRGB(0, 255, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 18
        title.Parent = frame
        
        -- Бинды
        local bindInfo = Instance.new("TextLabel")
        bindInfo.Size = UDim2.new(1, 0, 0, 40)
        bindInfo.Position = UDim2.new(0, 0, 0, 32)
        bindInfo.BackgroundTransparency = 1
        bindInfo.Text = "L=Menu | K=Fly | N=NoClip | End=KillAll"
        bindInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
        bindInfo.Font = Enum.Font.Gotham
        bindInfo.TextSize = 11
        bindInfo.TextScaled = true
        bindInfo.Parent = frame
        
        -- Функция создания чекбокса
        local function CreateCheckbox(text, setting, yPos)
            local box = Instance.new("TextButton")
            box.Size = UDim2.new(0.9, 0, 0, 25)
            box.Position = UDim2.new(0.05, 0, 0, yPos)
            box.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
            box.Text = "⬜ " .. text .. ": OFF"
            box.TextColor3 = Color3.fromRGB(200, 200, 200)
            box.Font = Enum.Font.Gotham
            box.TextSize = 12
            box.TextXAlignment = Enum.TextXAlignment.Left
            box.BorderSizePixel = 0
            box.Parent = frame
            
            box.MouseButton1Down:Connect(function()
                Settings[setting] = not Settings[setting]
                box.Text = (Settings[setting] and "✅ " or "⬜ ") .. text .. ": " .. (Settings[setting] and "ON" or "OFF")
                box.TextColor3 = Settings[setting] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(200, 200, 200)
            end)
            return box
        end
        
        -- Чекбоксы
        CreateCheckbox("Aimbot", "Aimbot", 75)
        CreateCheckbox("ESP", "ESP", 105)
        CreateCheckbox("AutoStab", "AutoStab", 135)
        CreateCheckbox("TriggerBot", "TriggerBot", 165)
        CreateCheckbox("Fly", "Fly", 195)
        CreateCheckbox("NoClip", "NoClip", 225)
        CreateCheckbox("FullBright", "FullBright", 255)
        
        -- Кнопка Kill All
        local killBtn = Instance.new("TextButton")
        killBtn.Size = UDim2.new(0.6, 0, 0, 30)
        killBtn.Position = UDim2.new(0.2, 0, 0, 290)
        killBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        killBtn.Text = "💀 KILL ALL"
        killBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        killBtn.Font = Enum.Font.GothamBold
        killBtn.TextSize = 14
        killBtn.Parent = frame
        
        killBtn.MouseButton1Down:Connect(function()
            Settings.KillAll = true
            KillAll()
            Settings.KillAll = false
            print("[XENO] Kill All выполнено!")
        end)
        
        return screenGui
    end)
end

-- ====================== ОСНОВНОЙ ЦИКЛ ======================
local function MainLoop()
    SafeCall(function()
        -- Аимбот
        if Settings.Aimbot then
            local target = GetClosestTarget()
            if target and UserInputService:IsKeyDown(Enum.KeyCode[Settings.AimbotKey]) then
                local lookAt = CFrame.lookAt(Camera.CFrame.Position, target.Position)
                Camera.CFrame = Camera.CFrame:Lerp(lookAt, Settings.AimbotSmooth)
            end
        end
        
        -- ESP (обновляем раз в секунду)
        if tick() % 1 < 0.05 then
            if Settings.ESP then
                if not CoreGui:FindFirstChild("ESP_GUI") then
                    CreateESP()
                end
            else
                local espGui = CoreGui:FindFirstChild("ESP_GUI")
                if espGui then espGui:Destroy() end
            end
        end
        
        -- FullBright
        if Settings.FullBright then
            Lighting.Brightness = 5
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        else
            Lighting.Brightness = 1
            Lighting.Ambient = Color3.fromRGB(100, 100, 100)
        end
        
        -- NoFog
        if Settings.NoFog then
            Lighting.FogEnd = 1000
        else
            Lighting.FogEnd = 500
        end
        
        -- Fly
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
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
                
                -- NoClip
                if Settings.NoClip then
                    for _, part in ipairs(character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                else
                    for _, part in ipairs(character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                end
            end
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
        
        -- TriggerBot
        if Settings.TriggerBot then
            local mouse = LocalPlayer:GetMouse()
            if mouse then
                local target = mouse.Target
                if target and target.Parent then
                    local character = target.Parent
                    local player = Players:GetPlayerFromCharacter(character)
                    if player and player ~= LocalPlayer then
                        SafeCall(function()
                            local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
                            if remote then
                                remote:FireServer(player, "Stab")
                            end
                        end)
                    end
                end
            end
        end
    end)
end

-- ====================== ОБРАБОТЧИК КЛАВИШ ======================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local key = input.KeyCode.Name
    
    if key == Settings.ToggleMenu then
        local menu = CoreGui:FindFirstChild("MM2_Menu")
        if menu then
            menu.Enabled = not menu.Enabled
        end
    end
    
    if key == Settings.ToggleFly then
        Settings.Fly = not Settings.Fly
        print("[XENO] Fly: " .. (Settings.Fly and "ON" or "OFF"))
        if not Settings.Fly then
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid.PlatformStand = false end
            end
        end
    end
    
    if key == Settings.ToggleNoClip then
        Settings.NoClip = not Settings.NoClip
        print("[XENO] NoClip: " .. (Settings.NoClip and "ON" or "OFF"))
    end
    
    if key == Settings.KillAllKey then
        Settings.KillAll = true
        KillAll()
        Settings.KillAll = false
        print("[XENO] Kill All выполнено!")
    end
end)

-- ====================== ЗАПУСК ======================
print("[XENO] Запуск MM2 Ultimate...")

-- Создание меню
CreateMenu()

-- Запуск основного цикла
RunService.Heartbeat:Connect(MainLoop)

-- Уведомление
StarterGui:SetCore("SendNotification", {
    Title = "MM2 ULTIMATE v6.0",
    Text = "✅ Скрипт загружен! Нажми L для меню",
    Duration = 4
})

print("[XENO] ✅ MM2 Ultimate v6.0 загружен!")
print("[XENO] 🎮 Нажми L для открытия меню")
print("[XENO] ⌨️ K - Fly | N - NoClip | End - Kill All")
