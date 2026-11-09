-- NEON HEADSHOT FIX ALL
-- Modifica tutti i suoni Headshot trovati

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local folder = player.PlayerScripts
    :WaitForChild("Weapon_Local")
    :WaitForChild("Headshots")

local NEW_ID = "rbxassetid://92489634161019" --// HEADSHOT SOUNDID

local count = 0

for _, sound in ipairs(folder:GetDescendants()) do
    if sound:IsA("Sound") then
        count += 1

        print("[HEADSHOT FOUND]", sound.Name, sound.SoundId)

        sound.SoundId = NEW_ID

        print("[HEADSHOT CHANGED]", sound.Name, sound.SoundId)
    end
end

print("========== COMPLETE ==========")
print("Total headshot sounds changed:", count)


--// UNIVERSAL CUSTOM GUN AUDIO
--// LocalScript - StarterPlayerScripts

local Players = game:GetService("Players")

local player = Players.LocalPlayer

--// CONFIG
local CUSTOM_SOUND_ID = "rbxassetid://136873378037145" --// SHOOT SOUNDID
--// POOP                rbxassetid://129079209019042
--// BOMB TIC            rbxassetid://139692748155280
--// ERROR               rbxassetid://132281440773764
--// WARNING             rbxassetid://126915480503058
--// UWU                 rbxassetid://139219844119994
--// POP                 rbxassetid://127105730240202
-- Se true, sostituisce tutti i suoni delle armi.
local ENABLED = true

--// Original Sound IDs (aggiungi qui quelli delle tue armi)
local ORIGINAL_SOUNDS = {
    ["121032345433162"] = true,
    ["105114819523908"] = true,
    ["118748227971004"] = true,
    ["101386695744508"] = true,
}

local hookedSounds = {}
local originalIDs = {}

local function getAssetId(soundId)
    return tostring(soundId):match("%d+")
end

local function isWeaponSound(sound)
    if not sound:IsA("Sound") then
        return false
    end

    local id = getAssetId(sound.SoundId)

    return id and ORIGINAL_SOUNDS[id] == true
end

local function applySound(sound)
    if not isWeaponSound(sound) then return end

    if originalIDs[sound] == nil then
        originalIDs[sound] = sound.SoundId
    end

    if ENABLED then
        sound.SoundId = CUSTOM_SOUND_ID
    else
        sound.SoundId = originalIDs[sound]
    end
end

local function hookSound(sound)
    if not sound:IsA("Sound") or hookedSounds[sound] then
        return
    end

    hookedSounds[sound] = true

    if isWeaponSound(sound) then
        applySound(sound)
    end

    sound:GetPropertyChangedSignal("SoundId"):Connect(function()
        if ENABLED and isWeaponSound(sound) then
            applySound(sound)
        end
    end)
end

local function scanTool(tool)
    if not tool:IsA("Tool") then return end

    for _, obj in ipairs(tool:GetDescendants()) do
        hookSound(obj)
    end

    tool.DescendantAdded:Connect(hookSound)
end

local function scanContainer(container)
    for _, obj in ipairs(container:GetChildren()) do
        scanTool(obj)
    end

    container.ChildAdded:Connect(scanTool)
end

local backpack = player:WaitForChild("Backpack")
scanContainer(backpack)

local function onCharacter(character)
    scanContainer(character)
end

if player.Character then
    onCharacter(player.Character)
end

player.CharacterAdded:Connect(onCharacter)

print("[CUSTOM AUDIO] Loaded")
