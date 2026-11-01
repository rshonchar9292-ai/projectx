--// features/rocket.lua
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local CONFIG = { Speed = 120, Lifetime = 15, SpawnDistance = 15, Cooldown = 2 }
local lastSpawnTime = 0
local isRocketActive = false
local function log(msg) print("[Rocket] " .. msg) end

-- ЕФЕКТ NO SIGNAL (Той самий)
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

-- СТВОРЕННЯ МОДЕЛІ РАКЕТИ
local function createRocketModel()
    local model = Instance.new("Model")
    model.Name = "Rocket"

    local hitbox = Instance.new("Part")
    hitbox.Name = "Hitbox"
    hitbox.Size = Vector3.new(2, 2, 8)
    hitbox.Transparency = 1
    hitbox.CanCollide = false
    hitbox.Parent = model
    model.PrimaryPart = hitbox

    local body = Instance.new("Part")
    body.Shape = Enum.PartType.Cylinder
    body.Size = Vector3.new(6, 1.5, 1.5)
    body.CFrame = hitbox.CFrame * CFrame.Angles(0, math.rad(90), 0)
    body.Color = Color3.fromRGB(220, 220, 220)
    body.Material = Enum.Material.Metal
    body.Parent = model

    local nose = Instance.new("Part")
    nose.Shape = Enum.PartType.Ball
    nose.Size = Vector3.new(1.5, 1.5, 1.5)
    nose.CFrame = hitbox.CFrame * CFrame.new(0, 0, -3.75)
    nose.Color = Color3.fromRGB(200, 30, 30)
    nose.Material = Enum.Material.Metal
    nose.Parent = model

    local engine = Instance.new("Part")
    engine.Shape = Enum.PartType.Cylinder
    engine.Size = Vector3.new(1, 1.2, 1.2)
    engine.CFrame = hitbox.CFrame * CFrame.new(0, 0, 3.5) * CFrame.Angles(0, math.rad(90), 0)
    engine.Color = Color3.fromRGB(50, 50, 50)
    engine.Material = Enum.Material.Metal
    engine.Parent = model

    -- Плавники
    for i = 1, 4 do
        local fin = Instance.new("WedgePart")
        fin.Size = Vector3.new(0.2, 1.5, 2)
        fin.CFrame = hitbox.CFrame * CFrame.new(0, 0, 2.5) * CFrame.Angles(0, 0, math.rad(i * 90))
        fin.Color = Color3.fromRGB(180, 180, 180)
        fin.Material = Enum.Material.Metal
        fin.Parent = model
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = hitbox
        weld.Part1 = fin
        weld.Parent = fin
    end

    local partsToWeld = {body, nose, engine}
    for _, part in ipairs(partsToWeld) do
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = hitbox
        weld.Part1 = part
        weld.Parent = part
    end

    local fire = Instance.new("ParticleEmitter")
    fire.Texture = "rbxassetid://243098098"
    fire.Color = ColorSequence.new(Color3.fromRGB(255, 200, 0), Color3.fromRGB(255, 0, 0))
    fire.Size = NumberSequence.new(1, 3)
    fire.Transparency = NumberSequence.new(0.1, 1)
    fire.Lifetime = NumberRange.new(0.2, 0.5)
    fire.Rate = 100
    fire.Speed = NumberRange.new(10, 20)
    fire.Parent = engine

    return model
end

local function spawnRocket()
    if isRocketActive then return end
    if tick() - lastSpawnTime < CONFIG.Cooldown then return end
    lastSpawnTime = tick()
    isRocketActive = true

    local Camera = workspace.CurrentCamera
    local Char = LocalPlayer.Character
    if not Camera or not Char then isRocketActive = false return end
    
    local spawnCFrame = Camera.CFrame * CFrame.new(0, 0, -CONFIG.SpawnDistance)
    local model = createRocketModel()
    model:PivotTo(spawnCFrame)
    model.Parent = workspace

    local hitbox = model.PrimaryPart
    local gyro = Instance.new("BodyGyro")
    gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    gyro.P = 100000
    gyro.D = 5000
    gyro.CFrame = Camera.CFrame
    gyro.Parent = hitbox

    local originalSubject = Camera.CameraSubject
    Camera.CameraSubject = hitbox
    LocalPlayer.CameraMaxZoomDistance = 30

    local startTime = tick()
    local moveConn
    
    moveConn = RunService.Heartbeat:Connect(function()
        if not model.Parent then moveConn:Disconnect() return end
        if tick() - startTime > CONFIG.Lifetime then model:Destroy() return end
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
        isRocketActive = false
    end)

    hitbox.Touched:Connect(function(hit)
        local char = hit:FindFirstAncestorOfClass("Model")
        if char and char ~= model and char ~= Char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                showNoSignal()
                local targetPlayer = Players:GetPlayerFromCharacter(char)
                if targetPlayer then
                    local FlingModule = _G.ProjectXFeatures and _G.ProjectXFeatures.Fling
                    if FlingModule and FlingModule.flingPlayer then
                        task.spawn(function() pcall(function() FlingModule:flingPlayer(targetPlayer, 1) end) end)
                    end
                end
                local explosion = Instance.new("Explosion")
                explosion.Position = hitbox.Position
                explosion.BlastRadius = 10
                explosion.BlastPressure = 0
                explosion.DestroyJointRadiusPercent = 0
                explosion.Parent = workspace
                model:Destroy()
            end
        end
    end)
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.H and _G.RocketEnabled then
        spawnRocket()
    end
end)

local RocketModule = {}
function RocketModule:setEnabled(state) _G.RocketEnabled = state end
log("Rocket loaded.")
return RocketModule
