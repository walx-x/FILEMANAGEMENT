-- NEON HEADSHOT FIX ALL
-- Modifica tutti i suoni Headshot trovati

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
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

--// CONFIG
local CUSTOM_SOUND_ID = "rbxassetid://136873378037145" --// SHOOT SOUNDID
--// POOP                rbxassetid://129079209019042
--// BOMB TIC            rbxassetid://139692748155280
--// ERROR               rbxassetid://132281440773764
--// WARNING             rbxassetid://126915480503058
--// UWU                 rbxassetid://139219844119994
--// POP                 rbxassetid://127105730240202
local ENABLED = true

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


--// ==========================================
--// CUSTOM SPARKLES / PARTICLE TEXTURE REPLACER
--// ==========================================

local SPARKLES_ENABLED = true
local TARGET_SPARKLE_ID = "13725820497"
local CUSTOM_SPARKLE_URL = "https://raw.githubusercontent.com/walx-x/FILEMANAGEMENT/refs/heads/main/blue_sparks_1.webp"
local LOCAL_FILE_NAME = "blue_sparks_1.webp"

-- Scarica l'immagine e ottiene l'asset locale
local function loadCustomTexture(url, fileName)
    if writefile and getcustomasset then
        local success, err = pcall(function()
            if not isfile or not isfile(fileName) then
                local imgData = game:HttpGet(url)
                writefile(fileName, imgData)
            end
        end)
        if success then
            return getcustomasset(fileName)
        else
            warn("[CUSTOM SPARKLES] Errore download immagine:", err)
        end
    else
        warn("[CUSTOM SPARKLES] Il tuo executor non supporta getcustomasset/writefile.")
    end
    return nil
end

local CUSTOM_SPARKLE_ASSET = loadCustomTexture(CUSTOM_SPARKLE_URL, LOCAL_FILE_NAME)

if SPARKLES_ENABLED and CUSTOM_SPARKLE_ASSET then
    local hookedEffects = {}

    local function checkAndReplaceTexture(obj)
        if hookedEffects[obj] then return end

        -- Controlla ParticleEmitter, Beam e Trail (tutti usano la proprietà .Texture)
        if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") then
            hookedEffects[obj] = true

            local function update()
                if not SPARKLES_ENABLED then return end
                local currentId = tostring(obj.Texture):match("%d+")
                if currentId == TARGET_SPARKLE_ID then
                    obj.Texture = CUSTOM_SPARKLE_ASSET
                end
            end

            update()

            -- Se l'effetto cambia texture dinamicamente, la risostituisce
            obj:GetPropertyChangedSignal("Texture"):Connect(update)
        end
    end

    -- Scansiona tutto ciò che è già presente in Workspace e ReplicatedStorage
    for _, obj in ipairs(Workspace:GetDescendants()) do
        checkAndReplaceTexture(obj)
    end
    for _, obj in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        checkAndReplaceTexture(obj)
    end

    -- Monitora in tempo reale nuovi effetti generati (es. scintille di impatto o scie proiettili)
    Workspace.DescendantAdded:Connect(checkAndReplaceTexture)
    game:GetService("ReplicatedStorage").DescendantAdded:Connect(checkAndReplaceTexture)

    print("[CUSTOM SPARKLES] Loaded -> ID", TARGET_SPARKLE_ID, "sostituito con", LOCAL_FILE_NAME)
end
