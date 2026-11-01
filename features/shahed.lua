--// ============================================================
--// features/shahed.lua
--// Функція "Shahed Strike" з інтеграцією FotliFling
--// ============================================================

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    Speed = 40,
    Lifetime = 15,
    SpawnDistance = 12,
}

local activeDrones = {}

--// ============================================================
--// NO SIGNAL GUI
--// ============================================================
local function showNoSignal()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end

    local oldGui = playerGui:FindFirstChild("ShahedNoSignal")
    if oldGui then oldGui:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "ShahedNoSignal"
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999
    gui.Parent = playerGui

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = Color3.new(0,0,0)
    bg.BackgroundTransparency = 1
    bg.Parent = gui

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1,0,0.2,0)
    txt.Position = UDim2.new(0,0,0.4,0)
    txt.BackgroundTransparency = 1
    txt.Text = "NO SIGNAL"
    txt.TextColor3 = Color3.new(1,1,1)
    txt.TextScaled = true
    txt.Font = Enum.Font.Code
    txt.TextTransparency = 1
    txt.Parent = bg

    local noiseFrames = {}
    for i = 1, 15 do
        local noise = Instance.new("Frame")
        noise.Size = UDim2.new(1, 0, math.random(5, 20)/100, 0)
        noise.Position = UDim2.new(0, 0, math.random(), 0)
        noise.BackgroundColor3 = Color3.new(1,1,1)
        noise.BackgroundTransparency = 0.95
        noise.Parent = bg
        table.insert(noiseFrames, noise)
    end

    local tweenIn = TweenInfo.new(0.1)
    TweenService:Create(bg, tweenIn, {BackgroundTransparency = 0}):Play()
    TweenService:Create(txt, tweenIn, {TextTransparency = 0}):Play()

    local flickerConn
    flickerConn = RunService.Heartbeat:Connect(function()
        if not gui.Parent then
            if flickerConn then flickerConn:Disconnect() end
            return
        end
        txt.TextTransparency = (math.random() > 0.7) and 1 or 0
        for _, f in ipairs(noiseFrames) do
            f.Position = UDim2.new(0, 0, math.random(), 0)
            f.BackgroundTransparency = math.random(90, 100) / 100
        end
    end)

    task.delay(2, function()
        if flickerConn then flickerConn:Disconnect() end
        local tweenOut = TweenInfo.new(0.4)
        local tOut = TweenService:Create(bg, tweenOut, {BackgroundTransparency = 1})
        tOut:Play()
        TweenService:Create(txt, tweenOut, {TextTransparency = 1}):Play()
        tOut.Completed:Connect(function() gui:Destroy() end)
    end)
end

--// ============================================================
--// СПАВН ТА РУХ ДРОНА
--// ============================================================
local function spawnShahed()
    local Camera = workspace.CurrentCamera
    if not Camera or not LocalPlayer.Character then return end
    
    local spawnCFrame = Camera.CFrame * CFrame.new(0, 0, -CONFIG.SpawnDistance)

    local model = Instance.new("Model")
    model.Name = "ShahedDrone"

    local hitbox = Instance.new("Part")
    hitbox.Name = "Hitbox"
    hitbox.Size = Vector3.new(4, 2, 5)
    hitbox.Transparency = 1
    hitbox.CanCollide = false
    hitbox.Parent = model

    local body = Instance.new("Part")
    body.Size = Vector3.new(2, 1, 4)
    body.Color = Color3.fromRGB(80, 80, 80)
    body.Material = Enum.Material.Metal
    body.CanCollide = false
    body.Parent = model

    local wingL = Instance.new("Part")
    wingL.Size = Vector3.new(4, 0.2, 1)
    wingL.Color = Color3.fromRGB(60, 60, 60)
    wingL.Material = Enum.Material.Metal
    wingL.CanCollide = false
    wingL.Parent = model

    local wingR = wingL:Clone()
    wingR.Parent = model

    model.PrimaryPart = hitbox
    model:PivotTo(spawnCFrame)

    body.CFrame = hitbox.CFrame
    wingL.CFrame = hitbox.CFrame * CFrame.new(-2, 0, 0)
    wingR.CFrame = hitbox.CFrame * CFrame.new(2, 0, 0)

    local w1 = Instance.new("WeldConstraint", hitbox)
    w1.Part0, w1.Part1 = hitbox, body
    local w2 = Instance.new("WeldConstraint", hitbox)
    w2.Part0, w2.Part1 = hitbox, wingL
    local w3 = Instance.new("WeldConstraint", hitbox)
    w3.Part0, w3.Part1 = hitbox, wingR

    model.Parent = workspace
    table.insert(activeDrones, model)

    local startTime = tick()
    local moveConn
    
    moveConn = RunService.Heartbeat:Connect(function()
        if not model.Parent then
            moveConn:Disconnect()
            return
        end
        if tick() - startTime > CONFIG.Lifetime then
            model:Destroy()
            moveConn:Disconnect()
            return
        end
        if hitbox then
            hitbox.AssemblyLinearVelocity = Camera.CFrame.LookVector * CONFIG.Speed
        end
    end)

    --// ДЕТЕКЦІЯ КОЛІЗІЇ ТА ВИКЛИК FLING
    hitbox.Touched:Connect(function(hit)
        local char = hit:FindFirstAncestorOfClass("Model")
        
        if char and char ~= model and char ~= LocalPlayer.Character then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                
                -- Знаходимо гравця за його моделлю
                local targetPlayer = Players:GetPlayerFromCharacter(char)

                -- Викликаємо наш новий FotliFling (якщо він є)
                if targetPlayer and _G.FotliFling then
                    task.spawn(function()
                        pcall(function()
                            -- Метод 1 = SkidFling (найпотужніший)
                            _G.FotliFling:flingPlayer(targetPlayer, 1)
                        end)
                    end)
                else
                    -- Резервний варіант, якщо це NPC або fling.lua не завантажився
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.AssemblyLinearVelocity = Vector3.new(5000, 5000, 5000)
                    end
                end

                -- Показуємо ефект
                showNoSignal()
                
                -- Знищуємо дрон
                model:Destroy()
                if moveConn then moveConn:Disconnect() end
            end
        end
    end)
end

--// ============================================================
--// ІНТЕГРАЦІЯ (Клавіша G)
--// ============================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.G and _G.ShahedEnabled then
        spawnShahed()
    end
end)

print("[FotliMenu] Shahed Strike (Fling Integrated) loaded.")
