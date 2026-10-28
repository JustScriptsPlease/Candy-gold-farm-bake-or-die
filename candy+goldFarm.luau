-- = ПОЛЕЗНЫЕ ПЕРЕМЕННЫЕ =
local TIMER_SECONDS = 2
local TELEPORT_OFFSET = Vector3.new(0, 3, 0)
local CANDY_INTERVAL = 1.25
local CHEST_PROMPT_WAIT = 3
local LOOP_DELAY = 0.05
local AUTO_PROMPT = true
local jump = true
local MIN_FARM_TIME = 10

-- ПРОСЬБА ОТРЕДАКТИРОВАТЬ ПОД СВОЁ УСТРОЙСТВО // КООРДИНАТЫ
local LOBBY_X, LOBBY_Y = 375, 325
local MATCH_CLICK_1_X, MATCH_CLICK_1_Y = 275, 325
local MATCH_CLICK_2_X, MATCH_CLICK_2_Y = 325, 215
local SKIP_X, SKIP_Y = 675, 205

-- КАСТОМИЗАЦИЯ ОЖИДАНИЙ
local LOBBY_WAIT = 5
local MATCH_WAIT_1 = 2
local MATCH_WAIT_2 = 2
local MATCH_LOOP_WAIT = 10

-- трогать только в экспериментальных целях!
local state = {
    running = false,
    chestsEnabled = true,
    eInterval = 0.25,
    normalEInterval = 1,
    emulationActive = false,
    promptActive = false,
    skipActive = true,
    devMode = false,
    exitAttempts = 0,
    stopClicked = false -- Флаг для полной остановки
}

-- ====== GUI ======
local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")

local gui = Instance.new("ScreenGui")
gui.Name = "CandyFarmGUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 200)
frame.Position = UDim2.new(0.5, -90, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 150, 50)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 0, 30)
title.Position = UDim2.new(0, 5, 0, 2)
title.BackgroundTransparency = 1
title.Text = "CandyCorn+GoldNuggets farm\nV1.4"
title.TextColor3 = Color3.fromRGB(255, 200, 100)
title.Font = Enum.Font.GothamBold
title.TextSize = 11
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextYAlignment = Enum.TextYAlignment.Top
title.Parent = frame

local skipBtn = Instance.new("TextButton")
skipBtn.Size = UDim2.new(0, 50, 0, 18)
skipBtn.Position = UDim2.new(1, -55, 0, 3)
skipBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
skipBtn.Text = "skip"
skipBtn.TextColor3 = Color3.new(1, 1, 1)
skipBtn.Font = Enum.Font.GothamBold
skipBtn.TextSize = 9
skipBtn.Visible = false
skipBtn.Parent = frame
skipBtn.MouseButton1Click:Connect(function()
    VIM:SendMouseButtonEvent(SKIP_X, SKIP_Y, 0, true, game, 1)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(SKIP_X, SKIP_Y, 0, false, game, 1)
end)

local noteBtn = Instance.new("TextButton")
noteBtn.Size = UDim2.new(0, 50, 0, 18)
noteBtn.Position = UDim2.new(1, -55, 0, 3)
noteBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 180)
noteBtn.Text = "патч-лог"
noteBtn.TextColor3 = Color3.new(1, 1, 1)
noteBtn.Font = Enum.Font.GothamBold
noteBtn.TextSize = 9
noteBtn.Visible = true
noteBtn.Parent = frame

local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(1, -10, 0, 20)
timerLabel.Position = UDim2.new(0, 5, 0, 35)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "Ready in: " .. TIMER_SECONDS .. "s"
timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timerLabel.Font = Enum.Font.GothamBold
timerLabel.TextSize = 14
timerLabel.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 0, 45)
statusLabel.Position = UDim2.new(0, 5, 0, 60)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "enabling farm..."
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 210)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 9
statusLabel.TextWrapped = true
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.TextYAlignment = Enum.TextYAlignment.Top
statusLabel.Parent = frame

local devModeBtn = Instance.new("TextButton")
devModeBtn.Size = UDim2.new(1, -10, 0, 25)
devModeBtn.Position = UDim2.new(0, 5, 0, 110)
devModeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 100)
devModeBtn.BorderSizePixel = 0
devModeBtn.Text = "dev mode (off)"
devModeBtn.TextColor3 = Color3.new(1, 1, 1)
devModeBtn.Font = Enum.Font.GothamBold
devModeBtn.TextSize = 10
devModeBtn.Parent = frame

local chestsBtn = Instance.new("TextButton")
chestsBtn.Size = UDim2.new(1, -10, 0, 25)
chestsBtn.Position = UDim2.new(0, 5, 0, 140)
chestsBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 60)
chestsBtn.BorderSizePixel = 0
chestsBtn.Text = "chests: (on)"
chestsBtn.TextColor3 = Color3.new(1, 1, 1)
chestsBtn.Font = Enum.Font.GothamBold
chestsBtn.TextSize = 10
chestsBtn.Parent = frame

local deactivateBtn = Instance.new("TextButton")
deactivateBtn.Size = UDim2.new(1, -10, 0, 25)
deactivateBtn.Position = UDim2.new(0, 5, 0, 170)
deactivateBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
deactivateBtn.BorderSizePixel = 0
deactivateBtn.Text = "🍌Stop Everything"
deactivateBtn.TextColor3 = Color3.new(1, 1, 1)
deactivateBtn.Font = Enum.Font.GothamBold
deactivateBtn.TextSize = 10
deactivateBtn.Parent = frame

-- ====== DEV MODE ЛОГИКА ======
devModeBtn.MouseButton1Click:Connect(function()
    state.devMode = not state.devMode
    if state.devMode then
        devModeBtn.Text = "dev mode (on)"
        devModeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 50)
        skipBtn.Visible = true
        noteBtn.Visible = false
    else
        devModeBtn.Text = "dev mode (off)"
        devModeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 100)
        skipBtn.Visible = false
        noteBtn.Visible = true
    end
end)

-- ====== ПАТЧ-ЛОГ И КЕТЧЕР ======
noteBtn.MouseButton1Click:Connect(function()
    frame:Destroy()
    
    local noteGui = Instance.new("ScreenGui")
    noteGui.Name = "NoteGUI"
    noteGui.ResetOnSpawn = false
    noteGui.DisplayOrder = 999
    noteGui.Parent = player:WaitForChild("PlayerGui")
    
    local noteFrame = Instance.new("Frame")
    noteFrame.Size = UDim2.new(0, 400, 0, 300)
    noteFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    noteFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    noteFrame.BorderSizePixel = 2
    noteFrame.BorderColor3 = Color3.fromRGB(100, 200, 255)
    noteFrame.Parent = noteGui
    
    local titleN = Instance.new("TextLabel")
    titleN.Size = UDim2.new(1, -10, 0, 30)
    titleN.Position = UDim2.new(0, 5, 0, 0)
    titleN.BackgroundTransparency = 1
    titleN.Text = "патч-лог & как использовать"
    titleN.TextColor3 = Color3.fromRGB(150, 220, 255)
    titleN.Font = Enum.Font.GothamBold
    titleN.TextSize = 14
    titleN.TextXAlignment = Enum.TextXAlignment.Left
    titleN.Parent = noteFrame
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 0, 200)
    scroll.Position = UDim2.new(0, 5, 0, 35)
    scroll.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    scroll.BorderSizePixel = 1
    scroll.BorderColor3 = Color3.fromRGB(80, 80, 120)
    scroll.ScrollBarThickness = 5
    scroll.CanvasSize = UDim2.new(0, 0, 0, 700)
    scroll.Parent = noteFrame
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -10, 0, 700)
    text.Position = UDim2.new(0, 5, 0, 5)
    text.BackgroundTransparency = 1
    text.Text = [[V1.2: добавлен ultra weapon crate (вероятно будет полезен, хз). И защита от ломания авто-фарма, почему бы нет. 
Как использовать? Вероятно, скрипт не будет работать на других устройствах. Просьба заменить переменные с помощью кетчера (кнопка снизу) на ваши устройства, а именно:
lobby x/y - поставить на кнопку play в лобби;  
match click 1 x/y - поставить на кнопку return to lobby после смерти; 
match click 2 x/y - поставить на кнопку yes после нажатия return to lobby
Skip x/y - поставить на кнопку SKIP когда идет кат-сцена с яйцом. 
Просьба ставить координаты именно x - y а не y - x так как первое всегда x а второе - y. 

Кнопка "Enable Chests": ON - включает в список фарма сундуки. OFF - выключает (просьба выключить до фарма или поставить переменную CHEST_PROMPT_WAIT на 0) 
Stop Everything: выключает фарм, без возможности включения. Просьба не кликать просто так. 
Test mode: дает возможность следить за тем что происходит, а так же заменяет лог на кнопку скип. Не удаляет гуи. 

Работает так: в лобби: скрипт обнаруживает лобби по скорости завершения фарма, жмет на кнопку play - запускает в матч. В матче: телепортируется к candy corn, собирая их, если появляется кат-сцена - скипает. После того как Кенди корн закончился - собирает candy corn chest,  и переходит к сундукам (ради золотых кусочков). После этого умирает и выходит (чтобы автоматически ливнуть если кто то остался в живых). Просьба поставить на авто-экзекьют. 

Кредиты: Ralsei_4k - основной разработчик. По вопросам писать в TikTok: @Ralsei_4k, или в Telegram: @Ralsei_4k, с хештегом #Ralsei4k в сообщении. 

open-source скрипт. Редактируйте его если хотите но указывайте меня если выставляете модификацию данного скрипта в публичный доступ]]
    text.TextColor3 = Color3.fromRGB(220, 220, 255)
    text.Font = Enum.Font.Gotham
    text.TextSize = 12
    text.TextWrapped = true
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.TextYAlignment = Enum.TextYAlignment.Top
    text.Parent = scroll
    
    local catcherBtn = Instance.new("TextButton")
    catcherBtn.Size = UDim2.new(0.5, -10, 0, 40)
    catcherBtn.Position = UDim2.new(0, 5, 0, 245)
    catcherBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
    catcherBtn.BorderSizePixel = 0
    catcherBtn.Text = "запустить catcher script\nдля установки координат"
    catcherBtn.TextColor3 = Color3.new(1, 1, 1)
    catcherBtn.Font = Enum.Font.GothamBold
    catcherBtn.TextSize = 10
    catcherBtn.Parent = noteFrame
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.5, -10, 0, 40)
    closeBtn.Position = UDim2.new(0.5, 5, 0, 245)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "закрыть лог"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 10
    closeBtn.Parent = noteFrame
    
    closeBtn.MouseButton1Click:Connect(function()
        noteGui:Destroy()
        print("перезапустите скрипт, пожалуйста.")
    end)
    
    catcherBtn.MouseButton1Click:Connect(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/JustScriptsPlease/Candy-GoldFarm/main/catcher.luau'))()
        print("catcher был включен. Удачной настройки!")
    end)
end)

-- ====== ЛОГИКА DEV MODE (СКРЫТИЕ) ======
local devModePressed = false
devModeBtn.MouseButton1Click:Connect(function()
    devModePressed = true
    devModeBtn.Text = "dev mode (active)"
    devModeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 50)
end)

task.spawn(function()
    task.wait(10)
    if not devModePressed then
        frame.Visible = false
        print("гуи было скрыто ради того чтобы не мешать фарму. Для того чтобы гуи не закрывалось включите тест-мод.")
    end
end)

-- ====== логика draggable для GUI ======
local dragging, dragStart, startPos = false, nil, nil
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)
frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- ====== некоторые кнопки ======
local function updateChestsBtn()
    if state.chestsEnabled then
        chestsBtn.Text = "chests: (on)"
        chestsBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 60)
    else
        chestsBtn.Text = "chests: (off)"
        chestsBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 40)
    end
end

chestsBtn.MouseButton1Click:Connect(function()
    state.chestsEnabled = not state.chestsEnabled
    updateChestsBtn()
end)

-- 👇 Stop Everything меняет текст на Potassium. и останавливает лобби-цикл
deactivateBtn.MouseButton1Click:Connect(function()
    state.running = false
    state.emulationActive = false
    state.promptActive = false
    state.skipActive = false
    state.chestsEnabled = false
    state.stopClicked = true -- 👈 Блокируем лобби-цикл
    updateChestsBtn()
    statusLabel.Text = "Stop Everything"
    deactivateBtn.Text = "Potassium."
    print("Stop Everything -> Potassium.")
end)

-- ====== КАМЕРА ВНИЗ ======
local function lookDown()
    local cam = workspace.CurrentCamera
    if not cam then return end
    pcall(function()
        cam.CFrame = CFrame.new(cam.CFrame.Position, cam.CFrame.Position + Vector3.new(0, -1, 0))
    end)
end

-- ====== ЦИКЛ СКИПА ======
task.spawn(function()
    task.wait(5)
    while state.skipActive do
        task.wait(2)
        if not state.skipActive then break end

        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then
            state.skipActive = false
            print("скип выключился, вы перешли на фарм сундуков")
            break
        end

        VIM:SendMouseButtonEvent(SKIP_X, SKIP_Y, 0, true, game, 1)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(SKIP_X, SKIP_Y, 0, false, game, 1)
    end
end)

-- ====== БЛОК 1: АВТО-ПРОМПТ ======
task.spawn(function()
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    while true do
        if not state.promptActive then
            task.wait(0.5)
            continue
        end
        local character = lp.Character or lp.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")
        local active = true
        local conn = lp.CharacterRemoving:Connect(function()
            active = false
            conn:Disconnect()
        end)
        while active and state.promptActive do
            for _, instance in ipairs(workspace:GetDescendants()) do
                if instance:IsA("ProximityPrompt") and state.promptActive then
                    local prompt = instance
                    local targetPart = prompt.Parent
                    if targetPart and targetPart:IsA("BasePart") and rootPart and rootPart.Parent then
                        local distance = (targetPart.Position - rootPart.Position).Magnitude
                        if distance <= prompt.MaxActivationDistance then
                            prompt:InputHoldBegin()
                            task.wait(2)
                            prompt:InputHoldEnd()
                        end
                    end
                end
            end
            task.wait(0.2)
        end
    end
end)

-- ====== БЛОК 2: МГНОВЕННЫЙ ИНТЕРАКТ ======
local ProximityPromptService = game:GetService("ProximityPromptService")
ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt, plr)
    if state.promptActive then
        fireproximityprompt(prompt)
    end
end)

-- ====== АВТО-ПРОМПТ ======
local function disablePromptDelay(prompt)
    if not AUTO_PROMPT then return end
    pcall(function()
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = math.huge
        prompt.RequiresLineOfSight = false
        prompt.Enabled = true
    end)
end

local function processAllPrompts()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then disablePromptDelay(obj) end
    end
end

workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("ProximityPrompt") then
        task.wait(0.1)
        disablePromptDelay(obj)
    end
end)

-- ====== ЭМУЛЯЦИЯ E ======
task.spawn(function()
    while true do
        if not state.emulationActive then
            task.wait(0.5)
            continue
        end
        pcall(function()
            VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.05)
            VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end)
        local interval = state.chestsEnabled and state.eInterval or state.normalEInterval
        task.wait(interval)
    end
end)

-- ====== ПОИСК ======
local function findModels(names)
    local results, set = {}, {}
    for _, n in ipairs(names) do set[n:lower()] = true end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and set[obj.Name:lower()] then
            table.insert(results, obj)
        end
    end
    return results
end

local function findChestsByName(name)
    local chests = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower() == name:lower() then
            table.insert(chests, obj)
        end
    end
    return chests
end

local function findCandyChests()
    local chests = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("candycornchest", 1, true) then
            table.insert(chests, obj)
        end
    end
    return chests
end

-- ====== ТП ======
local function teleportTo(obj)
    local char = player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp or not obj then return false end
    local pp = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    if not pp then return false end
    hrp.CFrame = CFrame.new(pp.Position + TELEPORT_OFFSET)
    lookDown()
    return true
end

-- ====== ЭМУЛЯЦИЯ F ======
local function pressF()
    pcall(function()
        VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(0.2)
        VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end)
end

-- ====== КЛИК ======
local function clickAt(x, y, isSkip)
    pcall(function()
        VIM:SendMouseButtonEvent(x, y, 0, true, game, 1)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
    end)
    if not isSkip then
        print("эмулируется клик по " .. x .. "???. " .. y .. "???.")
    end
end

-- ====== СБОР СУНДУКА ======
local function collectChest(chest, useJump)
    local prompt
    for _, d in ipairs(chest:GetDescendants()) do
        if d:IsA("ProximityPrompt") then
            prompt = d
            break
        end
    end
    if not prompt then return false end
    disablePromptDelay(prompt)
    teleportTo(chest)
    task.wait(0.1)
    
    if useJump then
        pcall(function()
            local key = jump and Enum.KeyCode.Space or Enum.KeyCode.W
            VIM:SendKeyEvent(true, key, false, game)
            task.wait(0.25)
            VIM:SendKeyEvent(false, key, false, game)
        end)
    end
    
    pcall(function()
        prompt:InputHoldBegin()
        task.wait(0.05)
        prompt:InputHoldEnd()
        fireproximityprompt(prompt)
    end)
    pressF()
    local start = tick()
    while tick() - start < CHEST_PROMPT_WAIT do
        if not chest.Parent or not prompt.Enabled or not state.running then break end
        task.wait(0.1)
    end
    return true
end

-- ====== ОСНОВНАЯ ЛОГИКА ======
local function main()
    local startTime = tick()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    processAllPrompts()

    -- === Сбор CandyCorn и NuggetTip ===
    local items = findModels({"CandyCorn", "NuggetTip"})
    local total = #items
    local collected = 0
    
    for i, item in ipairs(items) do
        if not state.running then return end
        if item.Parent then
            teleportTo(item)
            collected = collected + 1
            
            if item.Name == "CandyCorn" then
                statusLabel.Text = "🍬Candy Corn: [" .. collected .. "/" .. total .. "]"
            elseif item.Name == "NuggetTip" then
                statusLabel.Text = "🪙Nugget Tip: [" .. collected .. "/" .. total .. "]\n(вероятно это ошибка, напишите разработчику (подробнее в note), приложив скриншот)."
            end
            task.wait(CANDY_INTERVAL)
        end
    end

    -- === Главные сундуки (CandyCornChest) ===
    local candyChests = findCandyChests()
    local totalCC = #candyChests
    local collectedCC = 0
    
    if totalCC > 0 then
        statusLabel.Text = "Главные сундуки:"
        task.wait(0.5)
    end
    for i, chest in ipairs(candyChests) do
        if not state.running then return end
        if chest.Parent then
            collectedCC = collectedCC + 1
            statusLabel.Text = "Главные сундуки:\nCandyCornChest: [" .. collectedCC .. "/" .. totalCC .. "]"
            
            local candies = findModels({"CandyCorn"})
            for _, c in ipairs(candies) do
                if c.Parent and state.running then
                    teleportTo(c)
                    task.wait(CANDY_INTERVAL)
                end
            end
            collectChest(chest, true)
            task.wait(0.5)
            local newCandies = findModels({"CandyCorn"})
            for _, c in ipairs(newCandies) do
                if c.Parent and state.running then
                    teleportTo(c)
                    task.wait(CANDY_INTERVAL)
                end
            end
        end
        task.wait(LOOP_DELAY)
    end

    state.skipActive = false

    -- === Остальные сундуки (БЕЗ medium и Ultra) ===
    if state.chestsEnabled then
        local extraNames = {"WoodChest", "weaponCrate"}
        local hasAnyExtra = false
        for _, name in ipairs(extraNames) do
            if #findChestsByName(name) > 0 then hasAnyExtra = true break end
        end
        
        if hasAnyExtra then
            statusLabel.Text = "Остальные сундуки:"
            task.wait(0.5)
        end

        for _, name in ipairs(extraNames) do
            if not state.running then return end
            local chests = findChestsByName(name)
            local totalC = #chests
            local collectedC = 0
            
            for i, chest in ipairs(chests) do
                if not state.running then return end
                if chest.Parent then
                    collectedC = collectedC + 1
                    statusLabel.Text = "Остальные сундуки:\n" .. name .. ": [" .. collectedC .. "/" .. totalC .. "]"
                    
                    teleportTo(chest)
                    pcall(function()
                        local key = jump and Enum.KeyCode.Space or Enum.KeyCode.W
                        VIM:SendKeyEvent(true, key, false, game)
                        task.wait(0.25)
                        VIM:SendKeyEvent(false, key, false, game)
                    end)
                    pressF()
                    task.wait(1)
                end
            end
        end
    end

    local elapsed = tick() - startTime

    if elapsed < MIN_FARM_TIME then
        statusLabel.Text = "вероятно вы в лобби. Перевод в лобби-режим!"
        state.running = false
        state.emulationActive = false
        state.promptActive = false
        
        -- 👇 ИСПРАВЛЕНИЕ: Лобби-цикл теперь всегда работает, пока не нажат Стоп
        task.spawn(function()
            while not state.stopClicked do
                task.wait(LOBBY_WAIT)
                if state.stopClicked then break end
                clickAt(LOBBY_X, LOBBY_Y, false)
                print("вы в лобби.")
            end
        end)
        return
    end

    statusLabel.Text = "кончились объекты. Перезапускаем цикл..."
    state.skipActive = false
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Health = 0
    end

    local function attemptExit()
        while not state.stopClicked do
            state.exitAttempts = state.exitAttempts + 1
            statusLabel.Text = "не удалось выйти: попытка " .. state.exitAttempts
            print("цикл завершён. Перезапуск.")
            task.wait(MATCH_WAIT_1)
            clickAt(MATCH_CLICK_1_X, MATCH_CLICK_1_Y, false)
            task.wait(MATCH_WAIT_2)
            clickAt(MATCH_CLICK_2_X, MATCH_CLICK_2_Y, false)
            print("вероятно ваши сокомандники слишком быстрые. Если цикл не перезапустился сделайте скриншот и отправьте разработчику (подробнее в note).")
            task.wait(MATCH_LOOP_WAIT)
        end
    end

    task.spawn(attemptExit)
end

-- ====== ТАЙМЕР ======
task.spawn(function()
    for i = TIMER_SECONDS, 1, -1 do
        timerLabel.Text = "Ready in: " .. i .. "s"
        task.wait(1)
    end
    timerLabel.Text = "farm is started..."
    statusLabel.Text = "enabling farm..."
    
    state.running = true
    state.emulationActive = true
    state.promptActive = true
    
    task.wait(0.3)
    main()
end)

updateChestsBtn()
print("скрипт загружен. Просьба отредактировать переменные-координаты (зайдите в Note - Вызовите Catcher по кнопке)")
print("Potassium.")