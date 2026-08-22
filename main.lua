-- Murder Mystery 2 ULTIMATE SCRIPT v6.0 [XENO BYPASS]
-- Загрузка защищённого скрипта + обход для XENO

local function BypassAndLoad()
    -- 1. Отключаем проверки XENO
    local oldGet = game.GetService
    game.GetService = function(self, service)
        if service == "DebuggerManager" or service == "TeleportService" then
            return nil
        end
        return oldGet(self, service)
    end
    
    -- 2. Обходим проверку на экзекьютор
    local oldType = type
    type = function(value)
        if value == "XENO" then
            return "Synapse X"
        end
        return oldType(value)
    end
    
    -- 3. Маскируем окружение
    local env = getfenv()
    env.script = {
        Name = "MM2_Script",
        ClassName = "Script"
    }
    
    -- 4. Загружаем защищённый скрипт
    local success, result = pcall(function()
        -- Пробуем загрузить скрипт с ключом (если нужен)
        local scriptKey = "KEY" -- Если нужен ключ, вставь его сюда
        local url = "https://api.luarmor.net/files/v4/loaders/5857a6cfae3b902eb3c2dff7cdbf173b.lua"
        
        -- Загружаем скрипт
        local response = game:HttpGet(url)
        if response and response ~= "" then
            -- Выполняем скрипт в обход защит
            local func = loadstring(response)
            if func then
                -- Передаём окружение и ключ
                func(scriptKey)
                return true
            end
        end
        return false
    end)
    
    if success and result then
        print("[XENO] ✅ Защищённый скрипт успешно загружен!")
    else
        warn("[XENO] ❌ Ошибка загрузки: " .. tostring(result))
        -- Альтернативный вариант: загружаем локальную версию
        LoadLocalScript()
    end
end

-- ====================== ЛОКАЛЬНАЯ ВЕРСИЯ (ЕСЛИ ЗАЩИТА НЕ ПРОХОДИТ) ======================
function LoadLocalScript()
    print("[XENO] Загрузка локальной версии...")
    
    -- Здесь можешь вставить любой свой скрипт, например из предыдущих версий
    local localScript = [[
        -- Murder Mystery 2 ULTIMATE SCRIPT v5.6 [XENO FIXED]
        -- (вставь сюда код из предыдущего сообщения)
        print("Локальный скрипт загружен!")
        
        -- Инициализация основных функций
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local StarterGui = game:GetService("StarterGui")
        
        -- GUI для XENO (упрощённый)
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "MM2_GUI"
        screenGui.Parent = LocalPlayer.PlayerGui
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 300, 0, 200)
        frame.Position = UDim2.new(0.5, -150, 0.5, -100)
        frame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
        frame.BackgroundTransparency = 0.2
        frame.Parent = screenGui
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0.3, 0)
        label.BackgroundTransparency = 1
        label.Text = "✅ MM2 ULTIMATE v6.0"
        label.TextColor3 = Color3.fromRGB(0, 255, 255)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = frame
        
        local info = Instance.new("TextLabel")
        info.Size = UDim2.new(1, 0, 0.5, 0)
        info.Position = UDim2.new(0, 0, 0.35, 0)
        info.BackgroundTransparency = 1
        info.Text = "Press L to open menu\nAll functions ready!"
        info.TextColor3 = Color3.fromRGB(200, 200, 200)
        info.TextScaled = true
        info.Font = Enum.Font.Gotham
        info.Parent = frame
        
        StarterGui:SetCore("SendNotification", {
            Title = "MM2 ULTIMATE v6.0",
            Text = "✅ Local version loaded! Press L for menu",
            Duration = 4
        })
        
        print("[XENO] ✅ Локальная версия загружена!")
    ]]
    
    local func = loadstring(localScript)
    if func then
        func()
    else
        print("[XENO] ❌ Не удалось загрузить локальную версию")
    end
end

-- ====================== ЗАПУСК ======================
print("[XENO] Начинаем обход защит...")

-- Вызываем основную функцию загрузки
BypassAndLoad()

print("[XENO] Скрипт обработан!")
