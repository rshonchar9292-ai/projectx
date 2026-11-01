--// ============================================================
--// features/shahed.lua
--// Shahed-136 (Geran) - Full Edition (Fling + No Signal)
--// ============================================================

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    Speed = 55,
    Lifetime = 20,
    SpawnDistance = 15,
    Cooldown = 2,
}

local lastSpawnTime = 0
local isDroneActive = false

local function log(msg) print("[Shahed] " .. msg) end

--// ============================================================
--// ЕФЕКТ "NO SIGNAL"
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

    -- Чорний фон
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = Color3.new(0,0,0)
    bg.BackgroundTransparency = 1
    bg.Parent = gui

    -- Текст
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

    -- Процедурний шум (смуги)
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

    -- Анімація появи (0.1с)
    local tweenIn = TweenInfo.new(0.1)
    TweenService:Create(bg, tweenIn, {BackgroundTransparency = 0}):Play()
    TweenService:Create(txt, tweenIn, {TextTransparency = 0}):Play()

    -- Мерехтіння
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

    -- Зникнення через 2 секунди (0.4с)
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
--// ФУНКЦІЯ СТВОРЕННЯ МОДЕЛІ
--// ============================================================
local function createShahedModel()
    local model = Instance.new("Model")
    model.Name = "Shahed136"

    -- 1. ХІТБОКС
    local hitbox = Instance.new("Part")
    hitbox.Name = "Hitbox"
    hitbox.Size = Vector3.new(6, 2, 9)
    hitbox.Transparency = 1
    hitbox.CanCollide = false
    hitbox.Parent = model
    model.PrimaryPart = hitbox

    -- 2. ФЮЗЕЛЯЖ
    local body = Instance.new("Part")
    body.Size = Vector3.new(1.5, 1.5, 5)
    body.Color = Color3.fromRGB(70, 75, 65)
    body.Material = Enum.Material.Metal
    body.Parent = model

    -- 3. НІС
    local nose = Instance.new("Part")
    nose.Size = Vector3.new(1.5, 1.5, 2)
    nose.Color = Color3.fromRGB(40, 40, 40)
    nose.Material = Enum.Material.DiamondPlate
    nose.Parent = model

    -- 4. КРИЛА
    local wingLeft = Instance.new("WedgePart")
    wingLeft.Size = Vector3.new(6, 0.2, 3)
    wingLeft.Color = Color3.fromRGB(80, 85, 75)
    wingLeft.Material = Enum.Material.Metal
    wingLeft.Parent = model

    local wingRight = Instance.new("WedgePart")
    wingRight.Size = Vector3.new(6, 0.2, 3)
    wingRight.Color = Color3.fromRGB(80, 85, 75)
    wingRight.Material = Enum.Material.Metal
    wingRight.Parent = model

    -- 5. ХВІСТ
    local tailFin = Instance.new("Part")
    tailFin.Size = Vector3.new(0.2, 2, 1.5)
    tailFin.Color = Color3.fromRGB(60, 65, 55)
    tailFin.Material = Enum.Material.Metal
    tailFin.Parent = model

    -- 6. ДВИГУН
    local engine = Instance.new("Part")
    engine.Name = "Engine"
    engine.Shape = Enum.PartType.Cylinder
    engine.Size = Vector3.new(2, 1, 1)
    engine.Color = Color3.fromRGB(30, 30, 30)
    engine.Material = Enum.Material.Metal
    engine.Parent = model

    -- 7. ПРОПЕЛЕР
    local propellerHub = Instance.new("Part")
    propellerHub.Name = "PropellerHub"
    propellerHub.Shape = Enum.PartType.Cylinder
    propellerHub.Size = Vector3.new(0.5, 0.5, 0.5)
    propellerHub.Color = Color3.fromRGB(20, 20, 20)
    propellerHub.Material = Enum.Material.Metal
    propellerHub.Massless = true
    propellerHub.Parent = model

    local blade1 = Instance.new("Part")
    blade1.Size = Vector3.new(0.1, 3, 0.3)
    blade1.Color = Color3.fromRGB(40, 40, 40)
    blade1.Material = Enum.Material.Metal
    blade1.Massless = true
    blade1.Parent = model

    local blade2 = blade1:Clone()
    blade2.Massless = true
    blade2.Parent = model

    -- 8. СМУГА
    local warningStripe = Instance.new("Part")
    warningStripe.Size = Vector3.new(1.6, 0.1, 0.5)
    warningStripe.Color = Color3.fromRGB(200, 30, 30)
    warningStripe.Material = Enum.Material.Neon
    warningStripe.Parent = model

    -- ЗБІРКА
    body.CFrame = hitbox.CFrame
    nose.CFrame = hitbox.CFrame * CFrame.new(0, 0, -3.5)
    wingLeft.CFrame = hitbox.CFrame * CFrame.new(-2.5, 0, 0.5) * CFrame.Angles(0, math.rad(20), 0)
    wingRight.CFrame = hitbox.CFrame * CFrame.new(2.5, 0, 0.5) * CFrame.Angles(0, math.rad(-20), 0)
    tailFin.CFrame = hitbox.CFrame * CFrame.new(0, 0.8, 2.5)
    warningStripe.CFrame = hitbox.CFrame * CFrame.new(0, 0.8, -1.5)

    engine.CFrame = hitbox.CFrame * CFrame.new(0, 0, 2.5) * CFrame.Angles(0, math.rad(90), 0)
    propellerHub.CFrame = engine.CFrame * CFrame.new(1, 0, 0)
    blade1.CFrame = propellerHub.CFrame * CFrame.new(0, 1.5, 0)
    blade2.CFrame = propellerHub.CFrame * CFrame.new(0, -1.5, 0)

    -- ЗВАРЮВАННЯ
    local partsToWeld = {body, nose, wingLeft, wingRight, tailFin, engine, warningStripe}
    for _, part in ipairs(partsToWeld) do
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = hitbox
        weld.Part1 = part
        weld.Parent = part
    end

    local weldB1 = Instance.new("WeldConstraint")
    weldB1.Part0 = propellerHub
    weldB1.Part1 = blade1
    weldB1.Parent = blade1

    local weldB2 = Instance.new("WeldConstraint")
    weldB2.Part0 = propellerHub
    weldB2.Part1 = blade2
    weldB2.Parent = blade2

    -- ФІЗИЧНА ПЕТЛЯ (Hinge)
    local att0 = Instance.new("Attachment")
    att0.Parent = engine
    att0.Position = Vector3.new(1, 0, 0)
    att0.Axis = Vector3.new(1, 0, 0)

    local att1 = Instance.new("Attachment")
    att1.Parent = propellerHub
    att1.Position = Vector3.new(0, 0, 0)
    att1.Axis = Vector3.new(1, 0, 0)

    local hinge = Instance.new("HingeConstraint")
    hinge.Attachment0 = att0
    hinge.Attachment1 = att1
    hinge.Parent = engine
    hinge.ActuatorType = Enum.ActuatorType.Motor
    hinge.AngularVelocity = 500
    hinge.MotorMaxTorque = math.huge

    -- ЕФЕКТИ
    local smoke = Instance.new("ParticleEmitter")
    smoke.Texture = "rbxassetid://243098098"
    smoke.Color = ColorSequence.new(Color3.fromRGB(150, 150, 150), Color3.fromRGB(50, 50, 50))
    smoke.Size = NumberSequence.new(1, 5)
    smoke.Transparency = NumberSequence.new(0.5, 1)
    smoke.Lifetime = NumberRange.new(0.5, 1.5)
    smoke.Rate = 20
    smoke.Speed = NumberRange.new(5, 10)
    smoke.Parent = engine

    local fire = Instance.new("ParticleEmitter")
    fire.Texture = "rbxassetid://243098098"
    fire.Color = ColorSequence.new(Color3.fromRGB(255, 150, 0), Color3.fromRGB(255, 0, 0))
    fire.Size = NumberSequence.new(0.5, 0.1)
    fire.Transparency = NumberSequence.new(0.2, 1)
    fire.Lifetime = NumberRange.new(0.1, 0.3)
    fire.Rate = 50
    fire.Speed = NumberRange.new(1, 5)
    fire.Parent = engine

    return model
end

--// ============================================================
--// ЛОГІКА ЗАПУСКУ
--// ============================================================
local function spawnShahed()
    if isDroneActive then return end
    if tick() - lastSpawnTime < CONFIG.Cooldown then return end
    lastSpawnTime = tick()
    isDroneActive = true

    local Camera = workspace.CurrentCamera
    local Char = LocalPlayer.Character
    if not Camera or not Char then 
        isDroneActive = false
        return 
    end
    
    local spawnCFrame = Camera.CFrame * CFrame.new(0, 0, -CONFIG.SpawnDistance)
    log("🚀 Запуск Shahed-136...")

    local model = createShahedModel()
    model:PivotTo(spawnCFrame)
    model.Parent = workspace

    local hitbox = model.PrimaryPart
    
    local gyro = Instance.new("BodyGyro")
    gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    gyro.P = 100000
    gyro.D = 5000
    gyro.CFrame = Camera.CFrame
    gyro.Parent = hitbox

    log("✅ Дрон у повітрі. Камера перемикається...")

    local originalSubject = Camera.CameraSubject
    Camera.CameraSubject = hitbox
    LocalPlayer.CameraMaxZoomDistance = 30

    local startTime = tick()
    local moveConn
    
    moveConn = RunService.Heartbeat:Connect(function()
        if not model.Parent then
            moveConn:Disconnect()
            return
        end
        if tick() - startTime > CONFIG.Lifetime then
            model:Destroy()
            return
        end
        
        if hitbox and Camera then
            local lookDir = Camera.CFrame.LookVector
            hitbox.AssemblyLinearVelocity = lookDir * CONFIG.Speed
            gyro.CFrame = Camera.CFrame
        end
    end)

    model.Destroying:Connect(function()
        if moveConn then moveConn:Disconnect() end
        if Camera then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                Camera.CameraSubject = LocalPlayer.Character.Humanoid
            else
                Camera.CameraSubject = originalSubject
            end
        end
        isDroneActive = false
        log("Камеру повернено гравцю.")
    end)

    -- КОЛІЗІЯ (ТУТ ВИКЛИКАЄТЬСЯ NO SIGNAL)
    hitbox.Touched:Connect(function(hit)
        local char = hit:FindFirstAncestorOfClass("Model")
        if char and char ~= model and char ~= Char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                log("💥 УРАЖЕННЯ: " .. char.Name)
                
                -- 1. Виклик флінгу
                local targetPlayer = Players:GetPlayerFromCharacter(char)
                if targetPlayer then
                    local FlingModule = _G.ProjectXFeatures and _G.ProjectXFeatures.Fling
                    if FlingModule and FlingModule.flingPlayer then
                        task.spawn(function()
                            pcall(function()
                                FlingModule:flingPlayer(targetPlayer, 1)
                            end)
                        end)
                    end
                end

                -- 2. Виклик ефекту NO SIGNAL
                showNoSignal()

                -- 3. Вибух
                local explosion = Instance.new("Explosion")
                explosion.Position = hitbox.Position
                explosion.BlastRadius = 8
                explosion.BlastPressure = 0
                explosion.DestroyJointRadiusPercent = 0
                explosion.Parent = workspace

                -- 4. Знищення дрона
                model:Destroy()
            end
        end
    end)
end

--// ============================================================
--// ІНТЕГРАЦІЯ
--// ============================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.G then
        if _G.ShahedEnabled == true then
            spawnShahed()
        end
    end
end)

local ShahedModule = {}
function ShahedModule:setEnabled(state)
    _G.ShahedEnabled = state
    log("Статус Shahed: " .. tostring(state))
end

log("Shahed-136 (Final Edition) завантажено.")
return ShahedModule
