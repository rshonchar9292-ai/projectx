--// ╔══════════════════════════════════════════════════════════════╗
--// ║  ProjectX - Loader v1.3 (Shahed + Rocket Edition)            ║
--// ╚══════════════════════════════════════════════════════════════╝

local BASE_URL = "https://raw.githubusercontent.com/rshonchar9292-ai/projectx/main/"

--// ============================================================
--//  LOG HELPERS
--// ============================================================
local function log(msg) print("[ProjectX] " .. tostring(msg)) end
local function logErr(msg) warn("[ProjectX ERROR] " .. tostring(msg)) end

--// ============================================================
--//  MODULE LOADER (крапки → слеші + Anti-Cache)
--// ============================================================
local function loadModule(path)
    local urlPath = path:gsub("%.", "/")
    -- Додано ?t= для обходу кешу
    local url = BASE_URL .. urlPath .. ".lua?t=" .. tostring(os.time())

    log("Завантажую: " .. urlPath)

    local ok, code = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok then
        logErr("HTTP FAIL: " .. urlPath)
        return nil
    end

    if not code or #code < 10 then
        logErr("ПУСТИЙ КОД: " .. urlPath)
        return nil
    end

    if code:find("404: Not Found") then
        logErr("404: " .. urlPath)
        return nil
    end

    local fn, err = loadstring(code)
    if not fn then
        logErr("COMPILE FAIL: " .. urlPath .. "\nПричина: " .. tostring(err))
        return nil
    end

    -- Використовуємо xpcall для отримання детального стеку помилок
    local ok2, result = xpcall(fn, function(err2)
        return err2 .. "\n" .. debug.traceback()
    end)

    if not ok2 then
        logErr("RUN FAIL: " .. urlPath .. "\nПричина: " .. tostring(result))
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
    logErr("❌ UI НЕ ЗАВАНТАЖЕНО — модулі не будуть запущені")
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
    Shahed    = loadModule("features.shahed"),
    Rocket    = loadModule("features.rocket"), -- ДОДАНО РАКЕТУ
}

--// ============================================================
--//  LOG FEATURES STATUS
--// ============================================================
log("─────────────────────────────")
log("Movement: "  .. type(Features.Movement))
log("Fling: "     .. type(Features.Fling))
log("Animation: " .. type(Features.Animation))
log("Shahed: "    .. type(Features.Shahed))
log("Rocket: "    .. type(Features.Rocket))
log("─────────────────────────────")

if type(Features.Shahed) ~= "table" then
    logErr("⚠️ УВАГА: Shahed не завантажився як модуль (отримано " .. type(Features.Shahed) .. ")")
end
if type(Features.Rocket) ~= "table" then
    logErr("⚠️ УВАГА: Rocket не завантажився як модуль (отримано " .. type(Features.Rocket) .. ")")
end

_G.ProjectXFeatures = Features

--// ============================================================
--//  INIT UI
--// ============================================================
log("Ініціалізація UI...")
local ok, err = xpcall(function()
    UI:init(Features)
end, function(err2)
    return err2 .. "\n" .. debug.traceback()
end)

if not ok then
    logErr("UI INIT FAIL:\n" .. tostring(err))
    return
end

log("✅ UI INIT OK")
log("=== ГОТОВО ===")
