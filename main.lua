-- Murder Mystery 2 - Advanced Script
-- Version: 2.3.7
-- Compatible with: Roblox MM2 (Latest)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ======================== НАСТРОЙКИ ========================
local Settings = {
    Aimbot = true,
    ESP = true,
    AutoStab = true,
    ShowRoles = true,
    FOV = 120,              -- угол обзора в градусах
    Range = 50,             -- дальность в студиях
    Smoothness = 0.3,       -- плавность наведения
    TeamCheck = false,      -- false = наводится на всех
    ActiveOnKey = "LeftAlt" -- клавиша активации аимбота
}

-- ======================== ОСНОВНАЯ ЛОГИКА ========================

-- Создаём GUI (окно управления)
local function CreateGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MM2ScriptGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 250, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "MM2 ASSIST [ ]"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = mainFrame
    
    -- Чекбоксы
    local checkboxes = {
        {name = "Aimbot", setting = "Aimbot"},
        {name = "ESP", setting = "ESP"},
        {name = "AutoStab", setting = "AutoStab"},
        {name = "ShowRoles", setting = "ShowRoles"}
    }
    
    for i, cb in ipairs(checkboxes) do
        local yPos = 40 + (i-1) * 35
        local checkbox = Instance.new("TextButton")
        checkbox.Size = UDim2.new(0.9, 0, 0, 30)
        checkbox.Position = UDim2.new(0.05, 0, 0, yPos)
        checkbox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        checkbox.Text = cb.name .. ": ON"
        checkbox.TextColor3 = Color3.fromRGB(0, 255, 0)
        checkbox.Font = Enum.Font.Gotham
        checkbox.TextSize = 14
        checkbox.BorderSizePixel = 1
        checkbox.BorderColor3 = Color3.fromRGB(100, 100, 120)
        checkbox.Parent = mainFrame
        
        checkbox.MouseButton1Click:Connect(function()
            Settings[cb.setting] = not Settings[cb.setting]
            checkbox.Text = cb.name .. ": " .. (Settings[cb.setting] and "ON" or "OFF")
            checkbox.TextColor3 = Settings[cb.setting] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        end)
    end
    
    -- Слайдеры (FOV, Range, Smooth)
    local sliders = {
        {name = "FOV", setting = "FOV", min = 30, max = 180, default = 120},
        {name = "Range", setting = "Range", min = 10, max = 100, default = 50},
        {name = "Smooth", setting = "Smoothness", min = 0, max = 1, default = 0.3}
    }
    
    for i, sl in ipairs(sliders) do
        local yPos = 160 + (i-1) * 45
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.4, 0, 0, 20)
        label.Position = UDim2.new(0.05, 0, 0, yPos)
        label.BackgroundTransparency = 1
        label.Text = sl.name .. ": " .. tostring(Settings[sl.setting])
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.Parent = mainFrame
        
        local slider = Instance.new("TextButton")
        slider.Size = UDim2.new(0.5, 0, 0, 20)
        slider.Position = UDim2.new(0.45, 0, 0, yPos)
        slider.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        slider.Text = ""
        slider.BorderSizePixel = 1
        slider.BorderColor3 = Color3.fromRGB(150, 150, 170)
        slider.Parent = mainFrame
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((Settings[sl.setting] - sl.min) / (sl.max - sl.min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        fill.BorderSizePixel = 0
        fill.Parent = slider
        
        local dragging = false
        slider.MouseButton1Down:Connect(function()
            dragging = true
        end)
        slider.MouseButton1Up:Connect(function()
            dragging = false
        end)
        slider.MouseLeave:Connect(function()
            dragging = false
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = UserInputService:GetMouseLocation()
                local absPos = slider.AbsolutePosition
                local relX = math.clamp((mousePos.X - absPos.X) / slider.AbsoluteSize.X, 0, 1)
                local newVal = sl.min + (sl.max - sl.min) * relX
                if sl.setting == "Smoothness" then
                    newVal = math.round(newVal * 10) / 10
                else
                    newVal = math.round(newVal)
                end
                Settings[sl.setting] = newVal
                fill.Size = UDim2.new(relX, 0, 1, 0)
                label.Text = sl.name .. ": " .. tostring(newVal)
            end
        end)
    end
    
    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.2, 0, 0, 25)
    closeBtn.Position = UDim2.new(0.8, 0, 0, 275)
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = mainFrame
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
end

-- ======================== AIMBOT ========================
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
        
        local distance = (root.Position - targetRoot.Position).Magnitude
        if distance > Settings.Range then continue end
        
        -- Проверка угла обзора
        local lookDirection = Camera.CFrame.LookVector
        local toTarget = (targetRoot.Position - Camera.CFrame.Position).Unit
        local angle = math.deg(math.acos(lookDirection:Dot(toTarget)))
        if angle > Settings.FOV / 2 then continue end
        
        -- Оценка (приоритет по расстоянию и углу)
        local score = distance * 0.6 + angle * 0.4
        if score < bestScore then
            bestScore = score
            bestTarget = targetRoot
        end
    end
    return bestTarget
end

-- ======================== ESP ========================
local function CreateESP()
    -- Удаляем старые ESP
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == "MM2ESP" then v:Destroy() end
    end
    
    local espGui = Instance.new("ScreenGui")
    espGui.Name = "MM2ESP"
    espGui.ResetOnSpawn = false
    espGui.Parent = CoreGui
    
    local function AddESPForPlayer(player)
        if player == LocalPlayer then return end
        local character = player.Character
        if not character then return end
        
        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "ESPBox"
        box.Size = Vector3.new(2, 4, 2)
        box.Adornee = root
        box.AlwaysOnTop = true
        box.ZIndex = 999
        box.Color3 = player.Team == LocalPlayer.Team and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        box.Transparency = 0.5
        box.Parent = espGui
        
        -- Имя и роль
        local nameLabel = Instance.new("BillboardGui")
        nameLabel.Name = "NameLabel"
        nameLabel.Adornee = root
        nameLabel.Size = UDim2.new(0, 200, 0, 40)
        nameLabel.AlwaysOnTop = true
        nameLabel.Parent = espGui
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = player.Name
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextScaled = true
        label.Font = Enum.Font.Gotham
        label.Parent = nameLabel
        
        -- Обновление роли
        local roleUpdate = player:GetAttributeChangedSignal("Role"):Connect(function()
            local role = player:GetAttribute("Role") or "Innocent"
            local colors = {
                Murderer = Color3.fromRGB(255, 0, 0),
                Sheriff = Color3.fromRGB(0, 0, 255),
                Innocent = Color3.fromRGB(0, 255, 0)
            }
            label.Text = player.Name .. " [" .. role .. "]"
            label.TextColor3 = colors[role] or Color3.fromRGB(255, 255, 255)
        end)
        
        -- Очистка при удалении игрока
        player.AncestryChanged:Connect(function()
            if not player.Parent then
                box:Destroy()
                nameLabel:Destroy()
            end
        end)
    end
    
    -- Добавляем ESP для всех игроков
    for _, player in ipairs(Players:GetPlayers()) do
        AddESPForPlayer(player)
    end
    
    -- Следим за новыми игроками
    Players.PlayerAdded:Connect(AddESPForPlayer)
end

-- ======================== AUTO STAB ========================
local function AutoStab()
    if not Settings.AutoStab then return end
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    -- Проверяем, является ли игрок убийцей
    local isMurderer = false
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():find("knife") then
            isMurderer = true
            break
        end
    end
    
    if not isMurderer then return end
    
    -- Ищем ближайшего игрока для удара
    local closestPlayer = nil
    local closestDist = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local targetChar = player.Character
        if not targetChar then continue end
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if not targetRoot then continue end
        
        local dist = (character.HumanoidRootPart.Position - targetRoot.Position).Magnitude
        if dist < 8 and dist < closestDist then
            closestDist = dist
            closestPlayer = player
        end
    end
    
    if closestPlayer then
        -- Имитация удара (для Synapse/Krnl)
        local args = {
            [1] = closestPlayer
        }
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
    end
end

-- ======================== ГЛАВНЫЙ ЦИКЛ ========================
local function MainLoop()
    -- Аимбот
    if Settings.Aimbot then
        local target = GetClosestTarget()
        if target and UserInputService:IsKeyDown(Enum.KeyCode[Settings.ActiveOnKey] or Enum.KeyCode.LeftAlt) then
            local targetPos = target.Position
            local cameraPos = Camera.CFrame.Position
            local lookAt = CFrame.lookAt(cameraPos, targetPos)
            local smoothCFrame = Camera.CFrame:Lerp(lookAt, Settings.Smoothness)
            Camera.CFrame = smoothCFrame
        end
    end
    
    -- Авто-удар
    AutoStab()
    
    -- ESP (обновление при изменении настроек)
    if Settings.ESP then
        if not CoreGui:FindFirstChild("MM2ESP") then
            CreateESP()
        end
    else
        local espGui = CoreGui:FindFirstChild("MM2ESP")
        if espGui then espGui:Destroy() end
    end
end

-- ======================== ЗАПУСК ========================
-- Создаём GUI при загрузке
CreateGUI()

-- Запускаем основной цикл
RunService.Heartbeat:Connect(MainLoop)

-- Отображение ролей (пассивно)
Players.PlayerAdded:Connect(function(player)
    player:GetAttributeChangedSignal("Role"):Connect(function()
        if Settings.ShowRoles then
            local role = player:GetAttribute("Role") or "Innocent"
            print(player.Name .. " is " .. role)
        end
    end)
end)

-- Уведомление об успешной загрузке
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "MM2 Script",
    Text = "Loaded successfully! Press ] to open GUI",
    Duration = 3
})

print("MM2 Script Loaded - made by Pluma (tg: plumajb)")
