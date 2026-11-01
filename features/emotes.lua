--// features/emotes.lua
local Emotes = {}
local LocalPlayer = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

local currentTrack = nil
local freezeConnection = nil
_G.FreezeEmoteEnabled = false

--// ВЕЛИКА БАЗА ЕМОЦІЙ (взята з Eazvy)
local EmoteDatabase = {
	['Fashion'] = 3333331310, ["Baby Dance"] = 4265725525, ["Cha-Cha"] = 6862001787, 
	['Monkey'] = 3333499508, ['Shuffle'] = 4349242221, ["Top Rock"] = 3361276673, 
	["Around Town"] = 3303391864, ["Fancy Feet"] = 3333432454, ["Hype Dance"] = 3695333486, 
	['Bodybuilder'] = 3333387824, ['Idol'] = 4101966434, ['Curtsy'] = 4555816777, 
	['Happy'] = 4841405708, ["Quiet Waves"] = 7465981288, ['Sleep'] = 4686925579, 
	["Floss Dance"] = 5917459365, ['Shy'] = 3337978742, ['Godlike'] = 3337994105, 
	["Hero Landing"] = 5104344710, ["High Wave"] = 5915690960, ['Cower'] = 4940563117, 
	['Bored'] = 5230599789, ['Celebrate'] = 3338097973, ['Dash'] = 582855105, 
	['Beckon'] = 5230598276, ['Haha'] = 3337966527, ["Line Dance"] = 4049037604, 
	['Shrug'] = 3334392772, ['Stadium'] = 3338055167, ['Confused'] = 4940561610, 
	['Side to Side'] = 3333136415, ['Hello'] = 3344650532, ['Dolphin Dance'] = 5918726674, 
	['Samba'] = 6869766175, ['Break Dance'] = 5915648917, ['Greatest'] = 3338042785, 
	['Sad'] = 4841407203, ['Flowing Breeze'] = 7465946930, ['Twirl'] = 3334968680, 
	['Jumping Wave'] = 4940564896, ['Dizzy'] = 3361426436, ['Fashionable'] = 3333331310, 
	['Fast Hands'] = 4265701731, ['Tree'] = 4049551434, ['Agree'] = 4841397952, 
	['Power Blast'] = 4841403964, ['Swoosh'] = 3361481910, ['Jumping Cheer'] = 5895324424, 
	['Disagree'] = 4841401869, ['Rock On'] = 5915714366, ['Dorky Dance'] = 4212455378, 
	['Zombie'] = 4210116953, ['T'] = 3338010159, ['Fishing'] = 3334832150, 
	['Robot'] = 3338025566, ['Keeping Time'] = 4555808220, ['Air Dance'] = 4555782893, 
	['Swan Dance'] = 7465997989, ['Louder'] = 3338083565, ['Sneaky'] = 3334424322, 
	['Heisman Pose'] = 3695263073, ['Jacks'] = 3338066331, ['Superhero Reveal'] = 3695373233, 
	['Air Guitar'] = 3695300085, ['Salute'] = 3333474484, ['Applaud'] = 5915693819, 
	['Bunny Hop'] = 4641985101, ['Sandwich Dance'] = 4406555273, ['Tantrum'] = 5104341999, 
	['Tilt'] = 3334538554, ['Chicken Dance'] = 4841399916, ['Super Charge'] = 10478338114, 
	['Swag Walk'] = 10478341260, ['Arm Twist'] = 10713968716, ['Rock n Roll'] = 15505458452, 
	['Victory Dance'] = 15505456446, ['Flex Walk'] = 15505459811, ['Festive Dance'] = 15679621440,
	-- Звідси можна додати ще сотні, але для тесту цього вистачить
}

function Emotes:getDatabase()
    return EmoteDatabase
end

function Emotes:searchEmotes(query)
    local results = {}
    query = string.lower(query)
    
    if query == "" then
        -- Якщо пошук порожній, показуємо перші 50 емоцій (щоб не лагало)
        local count = 0
        for name, id in pairs(EmoteDatabase) do
            table.insert(results, {name = name, id = id})
            count = count + 1
            if count >= 50 then break end
        end
    else
        for name, id in pairs(EmoteDatabase) do
            if string.find(string.lower(name), query) then
                table.insert(results, {name = name, id = id})
            end
        end
    end
    
    table.sort(results, function(a, b) return a.name < b.name end)
    return results
end

function Emotes:stopEmote()
    if currentTrack then
        currentTrack:Stop()
        currentTrack = nil
    end
    if freezeConnection then
        freezeConnection:Disconnect()
        freezeConnection = nil
    end
end

function Emotes:setFreeze(state)
    _G.FreezeEmoteEnabled = state
    if not state then
        self:stopEmote()
    end
end

function Emotes:playEmote(emoteName, assetId)
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    if not animator then return end

    self:stopEmote()

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. tostring(assetId)

    local success, track = pcall(function()
        return animator:LoadAnimation(anim)
    end)

    if success and track then
        track.Looped = true
        track.Priority = Enum.AnimationPriority.Action
        track:Play()
        currentTrack = track

        -- Freeze Emote Logic
        if not _G.FreezeEmoteEnabled then
            freezeConnection = RunService.Heartbeat:Connect(function()
                if hum.MoveDirection.Magnitude > 0 then
                    self:stopEmote()
                end
            end)
        end
    end
end

print("[ProjectX] Emotes Module (with Search) loaded.")
return Emotes
