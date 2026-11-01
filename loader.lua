--// ============================================================
--// LOADER для ProjectX
--// ============================================================

if _G.ProjectXLoaded then
    warn("[ProjectX] Вже завантажено!")
    return
end
_G.ProjectXLoaded = true

--// УВАГА: ТУТ ЗМІНЕНО ПОСИЛАННЯ НА projectx
local BASE = "https://raw.githubusercontent.com/rshonchar9292-ai/projectx/main/"

local function Load(path)
    local url = BASE .. path .. "?t=" .. tostring(os.time())
    local ok, code = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok then
        warn("[ProjectX] HTTP-помилка (" .. path .. "):", code)
        return false
    end

    if not code or #code < 20 then
        warn("[ProjectX] Порожня відповідь (" .. path .. ")")
        return false
    end

    if code:sub(1, 3) == "404" or code:find("^404:") then
        warn("[ProjectX] Файл не знайдено (" .. path .. ")")
        return false
    end

    local fn, err = loadstring(code)
    if not fn then
        warn("[ProjectX] Помилка компіляції (" .. path .. "):", err)
        return false
    end

    local runOk, runErr = pcall(fn)
    if not runOk then
        warn("[ProjectX] Помилка виконання (" .. path .. "):", runErr)
        return false
    end

    print("[ProjectX] ✓ " .. path)
    return true
end

--// 1. UI
print("[ProjectX] Завантаження UI...")
Load("ui.lua")

--// 2. Невелика пауза для ініціалізації
task.wait(1)

--// 3. Модулі
print("[ProjectX] UI готовий, завантаження модулів...")

Load("features/aimbot.lua")
Load("features/silentaim.lua")
Load("features/esp.lua")
Load("features/orbitals.lua")
Load("features/fly.lua")
Load("features/bunnyhop.lua")
Load("features/fov.lua")
Load("features/antiaim.lua")
Load("features/shahed.lua")
Load("features/fling.lua")

print("[ProjectX] Готово! Меню запущено.")
print("[ProjectX] Натисни F4 щоб відкрити меню.")
