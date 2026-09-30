--// ╔══════════════════════════════════════════════════════════════╗
--// ║  ProjectX Movement — Fly + Speed + Noclip                    ║
--// ╚══════════════════════════════════════════════════════════════╝

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui       = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

--// ============================================================
--//  CONFIG
--// ============================================================
local Config = {
    -- Fly
    FlyEnabled     = false,
    FlySpeed       = 60,

    -- Speed
    SpeedEnabled   = false,
    SpeedValue     = 32,

    -- Noclip
    NoclipEnabled  = false,

    LogEnabled     = true,
}

--// ============================================================
--//  STATE
--// ============================================================
local flyConn = nil
local flyBV = nil
local flyBG = nil

local speedConn = nil

local noclipConn = nil

--// ============================================================
--//  LOG
--// ============================================================
local function log(msg)
    if Config.LogEnabled then print("[Movement] " .. msg) end
end

local function getChar()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return nil end
    if hum.Health <= 0 then return nil end
    return char, hum, hrp
end

local function isTyping()
    return UserInputService:GetFocusedTextBox() ~= nil
end

--// ============================================================
--//  FLY
--// ============================================================
local function getMoveDirection()
    local cam = Camera
    if not cam then return Vector3.zero end
    local cf = cam.CFrame
    local dir = Vector3.zero

    if not isTyping() then
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end
    end

    if dir.Magnitude < 1e-4 then return Vector3.zero end
    return dir.Unit
end

local function startFly()
    local char, hum, hrp = getChar()
    if not hrp then return false end

    -- PlatformStand
    pcall(function()
        hum.PlatformStand = true
    end)

    -- Очищуємо старі
    if flyBV then flyBV:Destroy() end
    if flyBG then flyBG:Destroy() end

    -- BodyVelocity
    flyBV = Instance.new("BodyVelocity")
    flyBV.Name = "ProjectXFly"
    flyBV.MaxForce = Vector3.one * 1e6
    flyBV.Velocity = Vector3.zero
    flyBV.P = 1250
    flyBV.Parent = hrp

    -- BodyGyro (тримає вертикально)
    flyBG = Instance.new("BodyGyro")
    flyBG.Name = "ProjectXFlyGyro"
    flyBG.MaxTorque = Vector3.one * 4e5
    flyBG.P = 1e4
    flyBG.D = 500
    flyBG.CFrame = Camera.CFrame
    flyBG.Parent = hrp

    -- Loop
    flyConn = RunService.Heartbeat:Connect(function()
        if not Config.FlyEnabled then return end
        local c, h, root = getChar()
        if not root or not flyBV or not flyBG then return end
        flyBV.Velocity = getMoveDirection() * Config.FlySpeed
        flyBG.CFrame = Camera.CFrame
    end)

    log("Fly started (Speed: " .. Config.FlySpeed .. ")")
    return true
end

local function stopFly()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if flyBV then flyBV:Destroy(); flyBV = nil end
    if flyBG then flyBG:Destroy(); flyBG = nil end

    local char, hum = getChar()
    if hum then
        pcall(function()
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)
    end

    log("Fly stopped")
end

--// ============================================================
--//  SPEED
--// ============================================================
local function startSpeed()
    if speedConn then speedConn:Disconnect() end

    speedConn = RunService.Heartbeat:Connect(function()
        if not Config.SpeedEnabled then return end
        local char, hum = getChar()
        if not hum then return end
        if hum.WalkSpeed ~= Config.SpeedValue then
            hum.WalkSpeed = Config.SpeedValue
        end
    end)

    log("Speed started (Value: " .. Config.SpeedValue .. ")")
end

local function stopSpeed()
    if speedConn then speedConn:Disconnect(); speedConn = nil end

    local char, hum = getChar()
    if hum then
        pcall(function() hum.WalkSpeed = 16 end)
    end

    log("Speed stopped")
end

--// ============================================================
--//  NOCLIP
--// ============================================================
local function startNoclip()
    if noclipConn then noclipConn:Disconnect() end

    noclipConn = RunService.Stepped:Connect(function()
        if not Config.NoclipEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)

    log("Noclip started")
end

local function stopNoclip()
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end

    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end

    log("Noclip stopped")
end

--// ============================================================
--//  CHARACTER RESPAWN
--// ============================================================
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1.5)
    if Config.FlyEnabled then
        stopFly()
        task.wait(0.2)
        startFly()
    end
    if Config.SpeedEnabled then
        startSpeed()
    end
    if Config.NoclipEnabled then
        stopNoclip()
        task.wait(0.2)
        startNoclip()
    end
end)

--// ============================================================
--//  MODULE
--// ============================================================
local Movement = {}
Movement.__index = Movement

function Movement.new()
    return setmetatable({}, Movement)
end

--// FLY
function Movement:setFly(state)
    Config.FlyEnabled = state
    if state then
        startFly()
    else
        stopFly()
    end
end

function Movement:setFlySpeed(value)
    Config.FlySpeed = value
    log("FlySpeed: " .. value)
end

--// SPEED
function Movement:setSpeed(state)
    Config.SpeedEnabled = state
    if state then
        startSpeed()
    else
        stopSpeed()
    end
end

function Movement:setSpeedValue(value)
    Config.SpeedValue = value
    log("SpeedValue: " .. value)
end

--// NOCLIP
function Movement:setNoclip(state)
    Config.NoclipEnabled = state
    if state then
        startNoclip()
    else
        stopNoclip()
    end
end

-- Stubs
function Movement:setEnabled() end

log("═══════════════════════════════")
log("ProjectX Movement loaded")
log("Fly • Speed • Noclip")
log("═══════════════════════════════")

return Movement.new()
