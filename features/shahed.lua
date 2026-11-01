--// ============================================================
--// features/shahed.lua
--// Shahed Strike - Steerable Drone Edition (No Signal Disabled)
--// ============================================================

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    Speed = 50, -- Трохи збільшив швидкість для кращого відчуття польоту
    Lifetime = 15,
    SpawnDistance = 12,
    Cooldown = 2,
}

local lastSpawnTime = 0
local isDroneActive = false

local function log(msg) print("[Shahed] " .. msg) end
local function logErr(msg) warn("[Shahed ERROR] " .. msg) end

--// ============================================================
--// ЕФЕКТ "NO SIGNAL" (Тимчасово вимкнено)
--// ============================================================
local function showNoSignal()
    --[[ 
    ТУТ БУВ КОД NO SIGNAL. 
    Я його закоментував, щоб ти бачив флінг. 
    Коли закінчиш тести, просто розкоментуй його (прибери --[[ та ]]).
    ]]
end

local function createExplosion(position)
    local explosion = Instance.new("Explosion")
    explosion.Position = position
    explosion.BlastRadius = 5
    explosion.BlastPressure = 0
    explosion.DestroyJointRadiusPercent = 0
    explosion.Parent = workspace
end

--// ============================================================
--// ЛОГІКА ДРОНА
--// ============================================================
local function spawnShahed()
    if isDroneActive then
        log("Дрон вже в повітрі!")
        return
    end
    if tick() - lastSpawnTime < CONFIG.Cooldown then
        log("⏳ Кулдаун! Зачекай.")
        return
    end
    lastSpawnTime = tick()
    isDroneActive = true

    local Camera = workspace.CurrentCamera
    local Char = LocalPlayer.Character
    if not Camera or not Char then 
        isDroneActive = false
        return 
    end
    
    local spawnCFrame = Camera.CFrame * CFrame.new(0, 0, -CONFIG.SpawnDistance)
    log("🚀 Спавн дрона о " .. tostring(spawnCFrame.Position))

    local model = Instance.new("Model")
    model.Name = "ShahedDrone"

    -- Хітбокс
    local hitbox = Instance.new("Part")
    hitbox.Name = "Hitbox"
    hitbox.Size = Vector3.new(4, 2, 5)
    hitbox.Transparency = 1
    hitbox.CanCollide = false
    hitbox.Parent = model

    -- Корпус
    local body = Instance.new("Part")
    body.Size = Vector3.new(2, 1, 4)
    body.Color = Color3.fromRGB(80, 80, 80)
    body.Material = Enum.Material.Metal
    body.CanCollide = false
    body.Parent = model

    -- Крила
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

    -- Додаємо гіроскоп, щоб дрон повертався носом куди летить
    local gyro = Instance.new("BodyGyro")
    gyro.MaxTorque = Vector3.new(40000, 40000, 40000)
    gyro.P = 3000
    gyro.D = 500
    gyro.Parent = hitbox

    model.Parent = workspace
    log("✅ Дрон створено. Камера перемикається...")

    -- ПЕРЕМИКАННЯ КАМЕРИ НА ДРОНА
    local originalSubject = Camera.CameraSubject
    Camera.CameraSubject = hitbox
    -- Віддаляємо камеру трохи назад для кращого огляду
    LocalPlayer.CameraMaxZoomDistance = 25

    local startTime = tick()
    local moveConn
    
    moveConn = RunService.Heartbeat:Connect(function()
        if not model.Parent then
            moveConn:Disconnect()
            return
        end
        if tick() - startTime > CONFIG.Lifetime then
            log("Час дрона вичерпано (15с).")
            model:Destroy()
            return
        end
        
        if hitbox and Camera then
            -- Рухаємось туди, куди дивиться камера
            local lookDir = Camera.CFrame.LookVector
            hitbox.AssemblyLinearVelocity = lookDir * CONFIG.Speed
            
            -- Повертаємо дрон носом вперед
            gyro.CFrame = CFrame.lookAt(hitbox.Position, hitbox.Position + lookDir)
        end
    end)

    -- ВІДНОВЛЕННЯ КАМЕРИ (якщо дрон знищено будь-яким способом)
    model.Destroying:Connect(function()
        if moveConn then moveConn:Disconnect() end
        
        -- Повертаємо камеру назад гравцю
        if Camera then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                Camera.CameraSubject = LocalPlayer.Character.Humanoid
            else
                Camera.CameraSubject = originalSubject
            end
        end
        isDroneActive = false
        log("Дрон знищено. Камеру повернено.")
    end)

    -- ДЕТЕКЦІЯ КОЛІЗІЇ
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
                
                -- showNoSignal() -- УВІМКНЕШ ПОТІМ
                
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
        else
            log("Клавіша G натиснута, але тогл в меню ВИМКНЕНО.")
        end
    end
end)

local ShahedModule = {}
function ShahedModule:setEnabled(state)
    _G.ShahedEnabled = state
    log("Меню змінило статус на: " .. tostring(state))
end

log("Shahed Strike (Steerable Drone) завантажено.")
return ShahedModule
