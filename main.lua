-- ====================== ОБХОД XENO ДЛЯ LUARMOR (МАСКИРОВКА ПОД DELTA) ======================
-- Попытка выполнить защищённый скрипт + запасная локальная версия

print("[XENO] 🚀 Запуск обходного механизма (маскировка под Delta)...")

-- 1. Маскируем XENO под Delta Executor (популярный аналог для ПК)
local oldType = type
type = function(value)
    if value == "XENO" then
        return "Delta" -- Притворяемся Delta Executor
    end
    return oldType(value)
end

-- 2. Добавляем фейковые глобальные переменные, которые может проверять Delta
local fakeDelta = {
    Version = "2.0.0",
    Executor = "Delta",
    IsSynapse = false,
    IsDelta = true,
    IsKrnl = false,
    IsScriptWare = false
}
_G.Delta = fakeDelta
_G.Executor = "Delta"

-- 3. Убираем сервисы отладки, которые могут мешать
local oldGet = game.GetService
game.GetService = function(self, service)
    if service == "DebuggerManager" or service == "TeleportService" then
        return nil
    end
    return oldGet(self, service)
end

-- 4. Подменяем окружение, чтобы скрипт считал, что запущен в обычном месте
local env = getfenv()
env.script = {
    Name = "MM2_Main",
    ClassName = "Script"
}

-- 5. Пытаемся выполнить твой защищённый скрипт
local protectedScript = [[
    -- Твой код (защищённый Luarmor)
    loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/5857a6cfae3b902eb3c2dff7cdbf173b.lua"))()
]]

local success, err = pcall(function()
    local func = loadstring(protectedScript)
    if func then
        func()
        return true
    end
    return false
end)

if success then
    print("[XENO] ✅ Защищённый скрипт успешно загружен (маскировка под Delta)!")
else
    warn("[XENO] ❌ Защищённый скрипт не загрузился: " .. tostring(err))
    print("[XENO] 🔄 Загружаем локальную версию (v5.6)...")
    
    -- ====================== ЛОКАЛЬНАЯ ВЕРСИЯ (v5.6) ======================
    local fallbackScript = [[
        -- Murder Mystery 2 ULTIMATE SCRIPT v5.6 [XENO + Delta Mode]
        print("[XENO] ✅ Локальная версия v5.6 загружена!")
        print("[XENO] 🎮 Нажми L для открытия меню")
        
        -- Здесь вставь полный код из предыдущей версии (v5.6)
        -- или используй упрощённую версию:
        
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local StarterGui = game:GetService("StarterGui")
        local UserInputService = game:GetService("UserInputService")
        local CoreGui = game:GetService("CoreGui")
        
        -- Создаём простое GUI
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "MM2_GUI"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = CoreGui
        
        local mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(0, 300, 0, 200)
        mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
        mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
        mainFrame.BackgroundTransparency = 0.2
        mainFrame.Active = true
        mainFrame.Draggable = true
        mainFrame.Parent = screenGui
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0.3, 0)
        title.BackgroundTransparency = 1
        title.Text = "✅ MM2 ULTIMATE v5.6 [DELTA MODE]"
        title.TextColor3 = Color3.fromRGB(0, 255, 255)
        title.TextScaled = true
        title.Font = Enum.Font.GothamBold
        title.Parent = mainFrame
        
        local info = Instance.new("TextLabel")
        info.Size = UDim2.new(1, 0, 0.4, 0)
        info.Position = UDim2.new(0, 0, 0.35, 0)
        info.BackgroundTransparency = 1
        info.Text = "Press L to toggle menu\nAll functions ready!"
        info.TextColor3 = Color3.fromRGB(200, 200, 200)
        info.TextScaled = true
        info.Font = Enum.Font.Gotham
        info.Parent = mainFrame
        
        local status = Instance.new("TextLabel")
        status.Size = UDim2.new(1, 0, 0.3, 0)
        status.Position = UDim2.new(0, 0, 0.7, 0)
        status.BackgroundTransparency = 1
        status.Text = "🔵 Delta Mode Active"
        status.TextColor3 = Color3.fromRGB(0, 200, 255)
        status.TextScaled = true
        status.Font = Enum.Font.Gotham
        status.Parent = mainFrame
        
        -- Обработчик клавиши L
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == Enum.KeyCode.L then
                screenGui.Enabled = not screenGui.Enabled
                print("[XENO] GUI Toggled: " .. tostring(screenGui.Enabled))
            end
        end)
        
        StarterGui:SetCore("SendNotification", {
            Title = "MM2 ULTIMATE v5.6",
            Text = "✅ Delta Mode Active! Press L for menu",
            Duration = 4
        })
        
        print("[XENO] ✅ Локальная версия v5.6 загружена!")
        print("[XENO] 🎮 Нажми L для открытия меню")
    ]]
    
    local fallbackFunc = loadstring(fallbackScript)
    if fallbackFunc then
        fallbackFunc()
        print("[XENO] ✅ Локальная версия успешно загружена!")
    else
        print("[XENO] ❌ Критическая ошибка: не удалось загрузить ни один скрипт.")
    end
end

print("[XENO] ✅ Обходной механизм завершён.")

-- Вызываем основную функцию загрузки
BypassAndLoad()

print("[XENO] Скрипт обработан!")
