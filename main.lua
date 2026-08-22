-- Murder Mystery 2 ULTIMATE SCRIPT v6.1 [XENO WORKING]
-- Fly = E | NoClip = F | Menu = L

print("[XENO] Загрузка MM2 Ultimate v6.1...")

-- ====================== НАСТРОЙКИ ======================
local Settings = {
    Aimbot = true,
    ESP = true,
    KillAll = false,
    AutoStab = true,
    TriggerBot = true,
    Fly = false,
    NoClip = false,
    FullBright = false,
    NoFog = false,
    
    AimbotFOV = 120,
    AimbotRange = 80,
    AimbotSmooth = 0.3,
    KillAllRange = 100,
    AutoStabRange = 8,
    FlySpeed = 50,
    
    AimbotKey = "LeftAlt",
    ToggleMenu = "L",
    ToggleFly = "E",        -- НОВЫЙ БИНД
    ToggleNoClip = "F",     -- НОВЫЙ БИНД
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

-- ====================== БЕЗОПАСНЫЙ ВЫЗОВ ======================
local function SafeCall(func)
    local success, err = pcall(func)
    if not success then
        warn("[XENO] Ошибка: " .. tostring(err))
    end
    return success
end

-- ====================== ПОЛУЧЕНИЕ РОЛИ (ИСПРАВЛЕНО) ======================
local function GetPlayerRole(player)
    -- Проверяем несколько возможных мест хранения роли
    local role = "Innocent"
    
    -- Способ 1: Атрибуты (самый частый)
    if player:GetAttribute("Role") then
        role = player:GetAttribute("Role")
    -- Способ 2: Данные игрока
    elseif player:FindFirstChild("Data") and player.Data:FindFirstChild("Role") then
        role = player.Data.Role.Value
    -- Способ 3: Статус (для старых версий)
    elseif player:FindFirstChild("Status") and player.Status:FindFirstChild("Role") then
        role = player.Status.Role.Value
    -- Способ 4: Проверка по оружию (если у игрока есть нож — убийца)
    elseif player.Character and player.Character:FindFirstChildOfClass("Tool") then
        local tool = player.Character:FindFirstChildOfClass("Tool")
        if tool and (tool.Name:lower():find("knife") or tool.Name:lower():find("dagger")) then
            role = "Murderer"
        elseif tool and tool.Name:lower():find("gun") then
            role = "Sheriff"
        end
    end
    
    return role
end

-- ====================== ЦВЕТА РОЛЕЙ ======================
local function GetRoleColor(role)
    if role == "Murderer" then
        return Color3.fromRGB(255, 0, 0)    -- Красный
    elseif role == "Sheriff" then
        return Color3.fromRGB(0, 100, 255)  -- Синий
    else
        return Color3.fromRGB(0, 255, 0)    -- Зелёный (Innocent)
    end
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

-- ====================== ESP (ИСПРАВЛЕН) ======================
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
        -- Удаляем старый ESP
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
            
            -- ПОЛУЧАЕМ РОЛЬ (ИСПРАВЛЕНО)
            local role = GetPlayerRole(player)
            local color = GetRoleColor(role)
            
            -- Бокс
            local box = Instance.new("BoxHandleAdornment")
            box.Size = Vector3.new(2.5, 4.5, 2.5)
            box.Adornee = root
            box.AlwaysOnTop = true
            box.Color3 = color
            box.Transparency = 0.5
            box.Parent = espGui
            
            -- Имя + Роль
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
            local roleLabel = Instance.new("TextLabel")
            roleLabel.Size = UDim2.new(1, 0, 0.5, 0)
            roleLabel.Position = UDim2.new(0, 0, 0.5, 0)
            roleLabel.BackgroundTransparency = 1
            roleLabel.Text = role
            roleLabel.TextColor3 = color
            roleLabel.TextScaled = true
            roleLabel.Font = Enum.Font.GothamBold
            roleLabel.Parent = nameGui
            
            -- Точка на голове
            local head = character:FindFirstChild("Head")
            if head then
                local dot = Instance.new("BillboardGui")
                dot.Adornee = head
                dot.Size = UDim2.new(0, 12, 0, 12)
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
        frame.Size = UDim2.new(0, 280, 0, 380)
        frame.Position = UDim2.new(0.5, -140, 0.5, -190)
        frame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
        frame.BackgroundTransparency = 0.1
        frame.BorderSizePixel = 2
        frame.BorderColor3 = Color3.fromRGB(0, 200, 255)
        frame.Active = true
        frame.Draggable = true
        frame.Parent = screenGui
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 30)
        title.BackgroundTransparency = 1
        title.Text = "⚡ MM2 ULTIMATE v6.1 ⚡"
        title.TextColor3 = Color3.fromRGB(0, 255, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 18
        title.Parent = frame
        
        local bindInfo = Instance.new("TextLabel")
        bindInfo.Size = UDim2.new(1, 0, 0, 50)
        bindInfo.Position = UDim2.new(0, 0, 0, 32)
        bindInfo.BackgroundTransparency = 1
        bindInfo.Text = "L=Menu | E=Fly | F=NoClip | End=KillAll"
        bindInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
        bindInfo.Font = Enum.Font.Gotham
        bindInfo.TextSize = 12
        bindInfo.TextScaled = true
        bindInfo.Parent = frame
        
        local function CreateCheckbox(text, setting, yPos)
            local box = Instance.new("TextButton")
            box.Size = UDim2.new(0.9, 0, 0, 26)
            box.Position = UDim2.new(0.05, 0, 0, yPos)
            box.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
            box.Text = "⬜ " .. text .. ": OFF"
            box.TextColor3 = Color3.fromRGB(200, 200, 200)
            box.Font = Enum.Font.Gotham
            box.TextSize = 13
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
        
        CreateCheckbox("Aimbot", "Aimbot", 85)
        CreateCheckbox("ESP", "ESP", 115)
        CreateCheckbox("AutoStab", "AutoStab", 145)
        CreateCheckbox("TriggerBot", "TriggerBot", 175)
        CreateCheckbox("Fly", "Fly", 205)
        CreateCheckbox("NoClip", "NoClip", 235)
        CreateCheckbox("FullBright", "FullBright", 265)
        CreateCheckbox("No Fog", "NoFog", 295)
        
        local killBtn = Instance.new("TextButton")
        killBtn.Size = UDim2.new(0.6, 0, 0, 32)
        killBtn.Position = UDim2.new(0.2, 0, 0, 330)
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
        
        -- ESP (обновляем раз в 0.5 секунды)
        if tick() % 0.5 < 0.05 then
            if Settings.ESP then
                if not CoreGui:FindFirstChild("ESP_GUI") then
                    CreateESP()
                end
            else
                local espGui = CoreGui:FindFirstChild("ESP_GUI")
                if espGui then espGui:Destroy() end
            end
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
        
        -- Fly + NoClip
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                -- Fly
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
                else
                    humanoid.PlatformStand = false
                end
                
                -- NoClip
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = not Settings.NoClip
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

-- ====================== ОБРАБОТЧИК КЛАВИШ (НОВЫЕ БИНДЫ) ======================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local key = input.KeyCode.Name
    
    -- Menu
    if key == Settings.ToggleMenu then
        local menu = CoreGui:FindFirstChild("MM2_Menu")
        if menu then
            menu.Enabled = not menu.Enabled
        end
    end
    
    -- Fly (E)
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
    
    -- NoClip (F)
    if key == Settings.ToggleNoClip then
        Settings.NoClip = not Settings.NoClip
        print("[XENO] NoClip: " .. (Settings.NoClip and "ON" or "OFF"))
    end
    
    -- Kill All (End)
    if key == Settings.KillAllKey then
        Settings.KillAll = true
        KillAll()
        Settings.KillAll = false
        print("[XENO] Kill All выполнено!")
    end
end)

-- ====================== ЗАПУСК ======================
print("[XENO] Запуск MM2 Ultimate v6.1...")

-- Создание меню
CreateMenu()

-- Запуск основного цикла
RunService.Heartbeat:Connect(MainLoop)

-- Уведомление
StarterGui:SetCore("SendNotification", {
    Title = "MM2 ULTIMATE v6.1",
    Text = "✅ Скрипт загружен!\nL=Menu | E=Fly | F=NoClip | End=KillAll",
    Duration = 5
})

print("[XENO] ✅ MM2 Ultimate v6.1 загружен!")
print("[XENO] 🎮 L - Menu | E - Fly | F - NoClip | End - Kill All")
print("[XENO] 🎯 Роли отображаются корректно!")
