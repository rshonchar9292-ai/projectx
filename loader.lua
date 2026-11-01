--// ╔══════════════════════════════════════════════════════════════╗
--// ║  ProjectX - Loader v1.0                                      ║
--// ╚══════════════════════════════════════════════════════════════╝

local BASE_URL = "https://raw.githubusercontent.com/rshonchar9292-ai/projectx/main/"

--// ============================================================
--//  LOG HELPERS
--// ============================================================
local function log(msg)
    print("[ProjectX] " .. tostring(msg))
end

local function notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 5,
        })
    end)
end

--// ============================================================
--//  MODULE LOADER (крапки → слеші)
--// ============================================================
local function loadModule(path)
    local urlPath = path:gsub("%.", "/")
    local url = BASE_URL .. urlPath .. ".lua"

    log("Завантажую: " .. urlPath)

    local ok, code = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok then
        log("❌ HTTP FAIL: " .. urlPath)
        return nil
    end

    if not code or #code < 10 then
        log("❌ ПУСТИЙ КОД: " .. urlPath)
        return nil
    end

    if code:find("404: Not Found") then
        log("❌ 404: " .. urlPath)
        return nil
    end

    local fn, err = loadstring(code)
    if not fn then
        log("❌ COMPILE FAIL: " .. urlPath .. " → " .. tostring(err))
        return nil
    end

    local ok2, result = pcall(fn)
    if not ok2 then
        log("❌ RUN FAIL: " .. urlPath .. " → " .. tostring(result))
        return nil
    end

    log("✅ OK: " .. urlPath .. " → " .. type(result))
    return result
end

--// ============================================================
--//  LOAD UI
--// ============================================================
log("=== СТАРТ ===")

local UI = loadModule("ui")
if not UI then
    log("❌ UI НЕ ЗАВАНТАЖЕНО — стоп")
    notify("ProjectX", "UI не завантажено. Перевір консоль.", 10)
    return
end
log("✅ UI OK")

--// ============================================================
--//  LOAD ALL FEATURES
--// ============================================================
local Features = {
    Movement  = loadModule("features.movement"),
    Fling     = loadModule("features.fling"),
    Animation = loadModule("features.animation"),
}

--// ============================================================
--//  LOG FEATURES STATUS
--// ============================================================
log("─────────────────────────────")
log("Movement: "  .. type(Features.Movement))
log("Fling: "     .. type(Features.Fling))
log("Animation: " .. type(Features.Animation))
log("─────────────────────────────")

_G.ProjectXFeatures = Features

--// ============================================================
--//  INIT UI
--// ============================================================
local ok, err = pcall(function()
    UI:init(Features)
end)

if not ok then
    log("❌ UI INIT FAIL: " .. tostring(err))
    notify("ProjectX Error", "UI init: " .. tostring(err), 15)
    return
end

log("✅ UI INIT OK")
log("=== ГОТОВО ===")
notify("ProjectX", "Завантажено! F4 — меню", 5)
