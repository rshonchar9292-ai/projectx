--// ============================================================
--// LOADER для TrustHub / ProjectX
--// Завантажує UI та всі модулі з папки features/
--// ============================================================

if _G.FotliMenuLoaded then
    warn("[FotliMenu] Вже завантажено!")
    return
end
_G.FotliMenuLoaded = true

--// Базовий URL твого репозиторію (перевір, що юзернейм 9292)
local BASE = "https://raw.githubusercontent.com/rshonchar9292-ai/fotli-hub/main/"

--// Універсальна функція завантаження
local function Load(path)
    local url = BASE .. path .. "?t=" .. tostring(os.time()) -- Обхід кешу
    local ok, code = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok then
        warn("[FotliMenu] HTTP-помилка (" .. path .. "):", code)
        return false
    end

    if not code or #code < 20 then
        warn("[FotliMenu] Порожня відповідь (" .. path .. ")")
        return false
    end

    --// Перевірка на 404
    if code:sub(1, 3) == "404" or code:find("^404:") then
        warn("[FotliMenu] Файл не знайдено (" .. path .. ")")
        return false
    end

    --// Компіляція
    local fn, err = loadstring(code)
    if not fn then
        warn("[FotliMenu] Помилка компіляції (" .. path .. "):", err)
        return false
    end

    --// Виконання
    local runOk, runErr = pcall(fn)
    if not runOk then
        warn("[FotliMenu] Помилка виконання (" .. path .. "):", runErr)
        return false
    end

    print("[FotliMenu] ✓ " .. path)
    return true
end

--// ============================================================
--// 1. Завантаження UI
--// ============================================================
print("[FotliMenu] Завантаження UI...")
Load("ui.lua")

--// ============================================================
--// 2. Очікування ініціалізації UI
--// ============================================================
local tries = 0
while (not _G.ModMenu or not _G.ModMenu.Elements) and tries < 30 do
    task.wait(0.1)
    tries = tries + 1
end

if not _G.ModMenu or not _G.ModMenu.Elements then
    warn("[FotliMenu] UI не ініціалізувався — модулі не запущено")
    return
end

print("[FotliMenu] UI готовий, завантаження модулів...")

--// ============================================================
--// 3. Завантаження модулів (Features)
--// ============================================================

--// Combat
Load("features/aimbot.lua")
Load("features/silentaim.lua")

--// Visuals
Load("features/esp.lua")
Load("features/orbitals.lua")

--// Movement
Load("features/fly.lua")
Load("features/bunnyhop.lua")
Load("features/fov.lua")

--// Rage / Fun
Load("features/antiaim.lua")
Load("features/shahed.lua")
Load("features/fling.lua")

--// ============================================================
--// 4. Готово
--// ============================================================
print("[FotliMenu] Готово! Меню запущено.")
print("[FotliMenu] Натисни F4 щоб відкрити меню.")
