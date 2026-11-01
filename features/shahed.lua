--// ============================================================
--// features/shahed.lua
--// Shahed Strike - Console Logs Edition
--// ============================================================

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    Speed = 45,
    Lifetime = 15,
    SpawnDistance = 12,
    Cooldown = 2,
}

local lastSpawnTime = 0
local activeDrones = {}

local function log(msg) print("[Shahed] " .. msg) end
local function logErr(msg) warn("[Shahed ERROR] " .. msg) end

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

    local tweenIn = TweenInfo.new(0.1)
    TweenService:Create(bg, tweenIn, {BackgroundTransparency = 0}):Play()
    TweenService:Create(txt, tweenIn, {TextTransparency = 0}):Play()

    task.delay(2, function()
        local tweenOut = TweenInfo.new(0.4)
        local tOut = TweenService:Create(bg, tweenOut, {BackgroundTransparency = 1})
        tOut:Play()
        TweenService:Create(txt, tweenOut, {TextTransparency = 1}):Play()
        tOut.Completed:Connect(function() gui:Destroy() end)
    end)
end

--// ============================================================
--// ВИБУХ ТА СПАВН
--// ============================================================
local function createExplosion(position)
    local explosion = Instance.new("Explosion")
    explosion.Position = position
    explosion.BlastRadius = 5
    explosion.BlastPressure = 0
    explosion.DestroyJointRadiusPercent = 0
    explosion.Parent = workspace
end

local function spawnShahed()
    if tick() - lastSpawnTime < CONFIG.Cooldown then
        log("⏳ Кулдаун! Зачекай.")
        return
    end
    lastSpawnTime = tick()

    local Camera = workspace.CurrentCamera
    if not Camera then
        logErr("Камера не знайдена!")
        return
    end

    local Char = LocalPlayer.Character
    if not Char then
        logErr("Персонаж гравця не знайдений!")
        return
    end
    
    local spawnCFrame = Camera.CFrame * CFrame.new(0, 0, -CONFIG.SpawnDistance)
    log("🚀 Спавн дрона о " .. tostring(spawnCFrame.Position))

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
    log("✅ Дрон успішно створено в Workspace.")

    local startTime = tick()
    local moveConn
    
    moveConn = RunService.Heartbeat:Connect(function()
        if not model.Parent then
            moveConn:Disconnect()
            return
        end
        if tick() - startTime > CONFIG.Lifetime then
            log("Час дрона вичерпано (15с). Знищено.")
            model:Destroy()
            moveConn:Disconnect()
            return
        end
        if hitbox then
            hitbox.AssemblyLinearVelocity = Camera.CFrame.LookVector * CONFIG.Speed
        end
    end)

    hitbox.Touched:Connect(function(hit)
        local char = hit:FindFirstAncestorOfClass("Model")
        
        if char and char ~= model and char ~= Char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                log("💥 Колізія з: " .. char.Name)
                
                local targetPlayer = Players:GetPlayerFromCharacter(char)

                if targetPlayer then
                    local FlingModule = _G.ProjectXFeatures and _G.ProjectXFeatures.Fling
                    if FlingModule and FlingModule.flingPlayer then
                        log("Виклик SkidFling для " .. targetPlayer.Name)
                        task.spawn(function()
                            pcall(function()
                                FlingModule:flingPlayer(targetPlayer, 1)
                            end)
                        end)
                    else
                        logErr("Fling модуль не знайдено! Використовую резервний метод.")
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.AssemblyLinearVelocity = Vector3.new(5000, 5000, 5000)
                        end
                    end
                end

                createExplosion(hitbox.Position)
                showNoSignal()
                model:Destroy()
                if moveConn then moveConn:Disconnect() end
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
        -- Перевіряємо, чи увімкнено тогл в меню
        if _G.ShahedEnabled == true then
            spawnShahed()
        else
            log("Клавіша G натиснута, але тогл в меню ВИМКНЕНО (_G.ShahedEnabled = false або nil).")
        end
    end
end)

local ShahedModule = {}
function ShahedModule:setEnabled(state)
    _G.ShahedEnabled = state
    log("Меню змінило статус на: " .. tostring(state))
end

log("Shahed Strike (Console Logs) завантажено.")
return ShahedModule
