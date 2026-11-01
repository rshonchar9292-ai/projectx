--// ╔══════════════════════════════════════════════════════════════╗
--// ║  ProjectX - Loader v1.2                                      ║
--// ╚══════════════════════════════════════════════════════════════╝

local BASE_URL = "https://raw.githubusercontent.com/rshonchar9292-ai/projectx/main/"

local function log(msg) print("[ProjectX] " .. tostring(msg)) end
local function logErr(msg) warn("[ProjectX ERROR] " .. tostring(msg)) end

local function loadModule(path)
    local urlPath = path:gsub("%.", "/")
    local url = BASE_URL .. urlPath .. ".lua?t=" .. tostring(os.time())

    local ok, code = pcall(function() return game:HttpGet(url) end)
    if not ok then logErr("HTTP FAIL: " .. urlPath) return nil end
    if not code or #code < 10 then logErr("ПУСТИЙ КОД: " .. urlPath) return nil end
    if code:find("404: Not Found") then logErr("404: " .. urlPath) return nil end

    local fn, err = loadstring(code)
    if not fn then logErr("COMPILE FAIL: " .. urlPath .. "\n" .. tostring(err)) return nil end

    local ok2, result = pcall(fn)
    if not ok2 then logErr("RUN FAIL: " .. urlPath .. "\n" .. tostring(result)) return nil end

    log("✅ OK: " .. urlPath)
    return result
end

local UI = loadModule("ui")
if not UI then logErr("❌ UI НЕ ЗАВАНТАЖЕНО") return end

local Features = {
    Movement  = loadModule("features.movement"),
    Fling     = loadModule("features.fling"),
    Animation = loadModule("features.animation"),
    Shahed    = loadModule("features.shahed"),
    Rocket    = loadModule("features.rocket"), -- ДОДАНО РАКЕТУ
}

_G.ProjectXFeatures = Features

local ok, err = pcall(function() UI:init(Features) end)
if not ok then logErr("UI INIT FAIL: " .. tostring(err)) return end
log("=== ГОТОВО ===")
