--// ╔══════════════════════════════════════════════════════════════╗
--// ║  ProjectX Fling — SkidFling + Self Protection                ║
--// ╚══════════════════════════════════════════════════════════════╝

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

--// ============================================================
--//  STATE
--// ============================================================
local flingActive = false

--// ============================================================
--//  LOG / NOTIFY
--// ============================================================
local function log(msg) print("[Fling] " .. msg) end

local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title, Text = text, Duration = duration or 2,
        })
    end)
end

--// ============================================================
--//  ROLE DETECTION (для UI списку)
--// ============================================================
local function getRole(player)
    if not player then return "Dead" end
    local char = player.Character
    if not char then return "Dead" end

    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local n = tool.Name:lower()
            if n:find("knife") or n:find("blade") or n:find("murder") 
               or n:find("dagger") or n:find("sword") then
                return "Murderer"
            end
        end
    end

    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local n = tool.Name:lower()
            if n:find("gun") or n:find("pistol") or n:find("sheriff") then
                return "Sheriff"
            end
        end
    end

    local bp = player:FindFirstChild("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") then
                local n = tool.Name:lower()
                if n:find("gun") or n:find("pistol") or n:find("sheriff") then
                    return "Sheriff"
                end
                if n:find("knife") or n:find("blade") or n:find("murder") then
                    return "Murderer"
                end
            end
        end
    end

    return "Innocent"
end

local function getRoleColor(role)
    if role == "Murderer" then return Color3.fromRGB(255, 50, 50)
    elseif role == "Sheriff" then return Color3.fromRGB(50, 150, 255)
    elseif role == "Innocent" then return Color3.fromRGB(50, 220, 100)
    else return Color3.fromRGB(150, 150, 150) end
end

local function isAlive(plr)
    if not plr or not plr.Character then return false end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

--// ============================================================
--//  SELF PROTECTION (щоб тебе самого не флипнуло)
--// ============================================================
local selfProtectionConn = nil
local selfProtectionActive = false

local function enableSelfProtection()
    if selfProtectionActive then return end
    selfProtectionActive = true

    selfProtectionConn = RunService.Heartbeat:Connect(function()
        if not selfProtectionActive then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- Обмежуємо швидкість
        local v = hrp.AssemblyLinearVelocity
        if v.Magnitude > 100 then
            hrp.AssemblyLinearVelocity = v.Unit * 100
        end
        if hrp.AssemblyAngularVelocity.Magnitude > 30 then
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end)
end

local function disableSelfProtection()
    selfProtectionActive = false
    if selfProtectionConn then
        selfProtectionConn:Disconnect()
        selfProtectionConn = nil
    end
end

--// ============================================================
--//  SKIDFLING (working method + захист)
--// ============================================================
local function SkidFling(TargetPlayer, duration)
    if not TargetPlayer or TargetPlayer == LocalPlayer then return false end
    if not TargetPlayer.Character then return false end

    local Character = LocalPlayer.Character
    if not Character then return false end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    if not Humanoid or not RootPart then return false end

    local TCharacter = TargetPlayer.Character
    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = THumanoid and THumanoid.RootPart
    local THead = TCharacter:FindFirstChild("Head")
    if not (THumanoid and TRootPart) then return false end

    -- ⚡ ЗБЕРІГАЄМО СВОЮ ПОЗИЦІЮ
    local myOldPos = RootPart.CFrame
    local myOldVelocity = RootPart.AssemblyLinearVelocity

    -- ⚡ ВМИКАЄМО SELF-PROTECTION
    enableSelfProtection()

    local FPos = function(BasePart, Pos, Ang)
        RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
        pcall(function()
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
        end)
        RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
        RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
    end

    local function SFBasePart(BasePart)
        local TimeToWait = duration or 2
        local Time = tick()
        local Angle = 0
        repeat
            if not RootPart or not THumanoid then break end

            -- ⚡ ПЕРІОДИЧНО ПОВЕРТАЄМО СЕБЕ НАЗАД
            if tick() - Time > 0.05 then
                RootPart.CFrame = myOldPos
                myOldPos = RootPart.CFrame
            end

            if BasePart.Velocity.Magnitude < 50 then
                Angle = Angle + 100
                FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                task.wait()
                FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                task.wait()
                FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                task.wait()
                FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                task.wait()
            else
                FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                task.wait()
                FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                task.wait()
                FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                task.wait()
                FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                task.wait()
            end
        until BasePart.Velocity.Magnitude > 500 
           or BasePart.Parent ~= TargetPlayer.Character 
           or tick() > Time + TimeToWait
    end

    local prevDestroy = workspace.FallenPartsDestroyHeight
    workspace.FallenPartsDestroyHeight = 0/0

    local BV = Instance.new("BodyVelocity")
    BV.Name = "ProjectXFling"
    BV.Parent = RootPart
    BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
    BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)

    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

    if TRootPart and THead then
        if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then
            SFBasePart(THead)
        else
            SFBasePart(TRootPart)
        end
    elseif TRootPart then
        SFBasePart(TRootPart)
    elseif THead then
        SFBasePart(THead)
    end

    BV:Destroy()
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)

    -- ⚡ ПОВЕРТАЄМО СЕБЕ
    task.wait(0.1)
    if RootPart then
        pcall(function()
            RootPart.CFrame = myOldPos
            RootPart.AssemblyLinearVelocity = myOldVelocity
            RootPart.AssemblyAngularVelocity = Vector3.zero
        end)
    end

    -- ⚡ ВИМИКАЄМО SELF-PROTECTION
    task.wait(0.3)
    disableSelfProtection()

    workspace.FallenPartsDestroyHeight = prevDestroy
    return true
end

--// ============================================================
--//  FLING PLAYER (публічне API)
--// ============================================================
local function flingPlayer(target)
    if not target or target == LocalPlayer then return false end
    if not isAlive(target) then return false end
    if flingActive then return false end

    flingActive = true

    log("Flinging: " .. target.Name .. " (" .. getRole(target) .. ")")

    task.spawn(function()
        local ok, err = pcall(SkidFling, target, 1.5)
        if ok then
            log("✓ Fling done: " .. target.Name)
            notify("💥 Fling", "Flinged: " .. target.Name, 2)
        else
            warn("[Fling] Error: " .. tostring(err))
        end
        flingActive = false
    end)

    return true
end

--// ============================================================
--//  GET PLAYERS WITH ROLES (для UI)
--// ============================================================
local function getPlayersWithRoles()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local role = getRole(plr)
            table.insert(list, {
                player = plr,
                role = role,
                color = getRoleColor(role),
            })
        end
    end
    table.sort(list, function(a, b)
        local order = { Murderer = 1, Sheriff = 2, Innocent = 3, Dead = 4 }
        return (order[a.role] or 99) < (order[b.role] or 99)
    end)
    return list
end

--// ============================================================
--//  MODULE
--// ============================================================
local Fling = {}
Fling.__index = Fling

function Fling.new()
    return setmetatable({}, Fling)
end

-- Публічне API (для UI)
function Fling:flingPlayer(plr) return flingPlayer(plr) end
function Fling:getPlayersWithRoles() return getPlayersWithRoles() end
function Fling:getRole(plr) return getRole(plr) end
function Fling:getRoleColor(role) return getRoleColor(role) end
function Fling:isFlinging() return flingActive end

-- Stubs
function Fling:flingSheriff() return 0 end
function Fling:flingMurderer() return 0 end
function Fling:setEnabled() end
function Fling:setRange() end
function Fling:setPower() end
function Fling:setVelocity() end
function Fling:setOnlyEnemies() end
function Fling:setTouchFling() end
function Fling:setAutoRetry() end

log("═══════════════════════════════")
log("ProjectX Fling loaded (Self-Protected)")
log("═══════════════════════════════")

return Fling.new()
