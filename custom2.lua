--// =====================================================
--// SYSTEM AUDIO OVERRIDE (HEADSHOTS + GUNS)
--// =====================================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer

--// -----------------------------------------------------
--// CONFIGURAZIONE
--// -----------------------------------------------------
local ENABLED = true

-- Sound ID per gli Headshot
local HEADSHOT_SOUND_ID = "rbxassetid://139219844119994"

-- Sound ID per gli spari delle armi
local GUN_SHOOT_SOUND_ID = "rbxassetid://127105730240202"

-- ID suoni originali delle armi da sostituire
local ORIGINAL_GUN_SOUNDS = {
    ["121032345433162"] = true,
    ["105114819523908"] = true,
    ["118748227971004"] = true,
    ["101386695744508"] = true,
}

--// -----------------------------------------------------
--// FUNZIONI DI UTILITÀ SICURE
--// -----------------------------------------------------
local function extractAssetId(soundId)
    if type(soundId) ~= "string" and type(soundId) ~= "number" then return nil end
    return tostring(soundId):match("%d+")
end

-- Applica l'ID in modo sicuro sia a Sound che a ValueObject (StringValue)
local function safeSetSoundId(obj, newId)
    if not obj then return false end

    -- Se è un vero oggetto Sound
    if obj:IsA("Sound") then
        local ok = pcall(function()
            obj.SoundId = newId
        end)
        return ok
    end

    -- Se il gioco salva l'ID in un ValueObject (es. StringValue)
    if obj:IsA("StringValue") then
        local ok = pcall(function()
            obj.Value = newId
        end)
        return ok
    end

    -- Controllo fallback su proprietà SoundId generica
    local hasProperty = pcall(function() return obj.SoundId end)
    if hasProperty then
        return pcall(function() obj.SoundId = newId end)
    end

    return false
end

--// -----------------------------------------------------
--// 1. NEON HEADSHOT FIX (SICURO)
--// -----------------------------------------------------
task.spawn(function()
    local playerScripts = player:WaitForChild("PlayerScripts", 5)
    if not playerScripts then return end

    local weaponLocal = playerScripts:WaitForChild("Weapon_Local", 5)
    if not weaponLocal then return end

    local headshotFolder = weaponLocal:WaitForChild("Headshots", 5)
    if not headshotFolder then
        warn("[HEADSHOT FIX] Cartella 'Headshots' non trovata in Weapon_Local")
        return
    end

    local count = 0

    local function processHeadshotObject(obj)
        if safeSetSoundId(obj, HEADSHOT_SOUND_ID) then
            count += 1
            print("[HEADSHOT MODIFICATO]", obj.Name, "->", HEADSHOT_SOUND_ID)
        end
    end

    -- Scansiona oggetti esistenti
    for _, obj in ipairs(headshotFolder:GetDescendants()) do
        processHeadshotObject(obj)
    end

    -- Modifica automaticamente anche i suoni creati in seguito
    headshotFolder.DescendantAdded:Connect(processHeadshotObject)

    print("========== HEADSHOT FIX COMPLETATO ==========")
    print("Suoni/Valori Headshot modificati:", count)
end)

--// -----------------------------------------------------
--// 2. UNIVERSAL GUN AUDIO REPLACER
--// -----------------------------------------------------
local hookedSounds = {}
local originalIDs = {}

local function isTargetGunSound(sound)
    if not sound or not sound:IsA("Sound") then return false end

    local ok, soundId = pcall(function() return sound.SoundId end)
    if not ok or not soundId then return false end

    local id = extractAssetId(soundId)
    return id and ORIGINAL_GUN_SOUNDS[id] == true
end

local function applyGunSound(sound)
    if not isTargetGunSound(sound) then return end

    if originalIDs[sound] == nil then
        pcall(function()
            originalIDs[sound] = sound.SoundId
        end)
    end

    pcall(function()
        if ENABLED then
            sound.SoundId = GUN_SHOOT_SOUND_ID
        elseif originalIDs[sound] then
            sound.SoundId = originalIDs[sound]
        end
    end)
end

local function hookGunSound(sound)
    if not sound or hookedSounds[sound] then return end

    if sound:IsA("Sound") then
        hookedSounds[sound] = true

        applyGunSound(sound)

        sound:GetPropertyChangedSignal("SoundId"):Connect(function()
            if ENABLED then
                applyGunSound(sound)
            end
        end)
    end
end

local function scanTool(tool)
    if not tool:IsA("Tool") then return end

    for _, obj in ipairs(tool:GetDescendants()) do
        hookGunSound(obj)
    end

    tool.DescendantAdded:Connect(hookGunSound)
end

local function scanContainer(container)
    if not container then return end

    for _, obj in ipairs(container:GetChildren()) do
        scanTool(obj)
    end

    container.ChildAdded:Connect(scanTool)
end

-- Avvio scansione armi
task.spawn(function()
    local backpack = player:WaitForChild("Backpack", 5)
    if backpack then
        scanContainer(backpack)
    end

    local function onCharacter(character)
        scanContainer(character)
    end

    if player.Character then
        onCharacter(player.Character)
    end

    player.CharacterAdded:Connect(onCharacter)

    print("[CUSTOM GUN AUDIO] Caricato con successo")
end)
