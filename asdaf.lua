--// =====================================================
--// UNIVERSAL CUSTOM ASSET + AUDIO + SKYBOX REPLACER
--// =====================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer

--// =====================================================
--// CONFIG
--// =====================================================

local ENABLED = true

--// HEADSHOT AUDIO
local HEADSHOT_ENABLED = true
local HEADSHOT_NEW_ID = "rbxassetid://92489634161019"

--// GUN AUDIO
local CUSTOM_SOUND_ID = "rbxassetid://136873378037145"

local ORIGINAL_SOUNDS = {
    ["121032345433162"] = true,
    ["105114819523908"] = true,
    ["118748227971004"] = true,
    ["101386695744508"] = true,
    ["83029822256067"] = true,
}

--// SPARKLES
local SPARKLES_ENABLED = true
local TARGET_SPARKLE_ID = "13725820497"

--// =====================================================
--// ASSET REPLACEMENTS
--// =====================================================

local ASSET_REPLACEMENTS = {

    -- Direct Roblox asset replacement
    ["5668123749"] = "rbxassetid://103637182693391", -- SKITS sound

    -- Custom local images
    ["115247438097572"] =
        "https://raw.githubusercontent.com/walx-x/FILEMANAGEMENT/refs/heads/main/sub.webp",

    ["78690555427970"] =
        "https://raw.githubusercontent.com/walx-x/FILEMANAGEMENT/refs/heads/main/ar15b.webp",
}

--// =====================================================
--// SKYBOX REPLACEMENTS
--// =====================================================

local SKYBOX_REPLACEMENTS = {

    -- BACK
    ["144933244"] = {
        property = "SkyboxBk",
        file = "backt_2.webp",
        url = "https://raw.githubusercontent.com/walx-x/FILEMANAGEMENT/refs/heads/main/backt_2.webp"
    },

    -- FRONT
    ["144933299"] = {
        property = "SkyboxFt",
        file = "front_2.webp",
        url = "https://raw.githubusercontent.com/walx-x/FILEMANAGEMENT/refs/heads/main/front_2.webp"
    },

    -- RIGHT
    ["144933262"] = {
        property = "SkyboxRt",
        file = "right_2.webp",
        url = "https://raw.githubusercontent.com/walx-x/FILEMANAGEMENT/refs/heads/main/right_2.webp"
    },

    -- LEFT
    ["144933338"] = {
        property = "SkyboxLf",
        file = "left_2.webp",
        url = "https://raw.githubusercontent.com/walx-x/FILEMANAGEMENT/refs/heads/main/left_2.webp"
    },

    -- BOTTOM
    ["144931530"] = {
        property = "SkyboxDn",
        file = "bottom_2.webp",
        url = "https://raw.githubusercontent.com/walx-x/FILEMANAGEMENT/refs/heads/main/bottom_2.webp"
    },

    -- TOP
    ["144931564"] = {
        property = "SkyboxUp",
        file = "top_2.webp",
        url = "https://raw.githubusercontent.com/walx-x/FILEMANAGEMENT/refs/heads/main/top_2.webp"
    },

    -- BACK 1
    ["600830446"] = {
        property = "SkyboxBk",
        file = "backt_2.webp",
        url = "https://raw.githubusercontent.com/walx-x/FILEMANAGEMENT/refs/heads/main/backt_2.webp"
    },

    -- FRONT 1
    ["600832720"] = {
        property = "SkyboxFt",
        file = "front_2.webp",
        url = "https://raw.githubusercontent.com/walx-x/FILEMANAGEMENT/refs/heads/main/front_2.webp"
    },

    -- RIGHT 1
    ["600833862"] = {
        property = "SkyboxRt",
        file = "right_2.webp",
        url = "https://raw.githubusercontent.com/walx-x/FILEMANAGEMENT/refs/heads/main/right_2.webp"
    },

    -- LEFT 1
    ["600886090"] = {
        property = "SkyboxLf",
        file = "left_2.webp",
        url = "https://raw.githubusercontent.com/walx-x/FILEMANAGEMENT/refs/heads/main/left_2.webp"
    },

    -- BOTTOM 1
    ["600831635"] = {
        property = "SkyboxDn",
        file = "bottom_2.webp",
        url = "https://raw.githubusercontent.com/walx-x/FILEMANAGEMENT/refs/heads/main/bottom_2.webp"
    },

    -- TOP 1
    ["600835177"] = {
        property = "SkyboxUp",
        file = "top_2.webp",
        url = "https://raw.githubusercontent.com/walx-x/FILEMANAGEMENT/refs/heads/main/top_2.webp"
    },
}

--// =====================================================
--// CUSTOM TEXTURE LOADER
--// =====================================================

local loadedAssets = {}

local function loadCustomTexture(url, fileName)

    if loadedAssets[fileName] then
        return loadedAssets[fileName]
    end

    if not writefile or not getcustomasset then
        warn("[ASSETS] Executor does not support writefile/getcustomasset")
        return nil
    end

    local success, result = pcall(function()

        if not isfile or not isfile(fileName) then
            local data = game:HttpGet(url)
            writefile(fileName, data)
        end

        return getcustomasset(fileName)
    end)

    if success and result then
        loadedAssets[fileName] = result
        print("[ASSETS] Loaded:", fileName)
        return result
    end

    warn("[ASSETS] Failed:", fileName, result)
    return nil
end

--// =====================================================
--// LOAD CUSTOM ASSETS
--// =====================================================

local CUSTOM_ASSETS = {}

for originalId, replacement in pairs(ASSET_REPLACEMENTS) do

    if replacement:find("^https://") then

        local fileName = originalId .. "_custom.webp"

        CUSTOM_ASSETS[originalId] =
            loadCustomTexture(replacement, fileName)

    else

        CUSTOM_ASSETS[originalId] = replacement

    end
end

--// LOAD SKYBOX IMAGES

local SKY_ASSETS = {}

for id, data in pairs(SKYBOX_REPLACEMENTS) do

    SKY_ASSETS[id] =
        loadCustomTexture(data.url, data.file)

end

--// =====================================================
--// ASSET REPLACEMENT ENGINE
--// =====================================================

local hookedAssets = {}

local function getAssetId(value)
    return tostring(value):match("%d+")
end

local function replaceProperty(obj, property)

    local success, currentValue = pcall(function()
        return obj[property]
    end)

    if not success or type(currentValue) ~= "string" then
        return
    end

    local id = getAssetId(currentValue)

    if not id then return end

    -- Normal asset replacements
    local replacement = CUSTOM_ASSETS[id]

    if replacement then

        pcall(function()
            obj[property] = replacement
        end)

        print("[ASSET REPLACED]", id, "->", replacement)
        return
    end

    -- Skybox replacements
    local skyData = SKYBOX_REPLACEMENTS[id]

    if skyData and obj:IsA("Sky") then

        if property == skyData.property then

            local customAsset = SKY_ASSETS[id]

            if customAsset then

                pcall(function()
                    obj[property] = customAsset
                end)

                print("[SKYBOX REPLACED]", id, "->", skyData.file)

            end
        end
    end
end

local ASSET_PROPERTIES = {
    "Texture",
    "TextureID",
    "Image",
}

local SKY_PROPERTIES = {
    "SkyboxBk",
    "SkyboxFt",
    "SkyboxRt",
    "SkyboxLf",
    "SkyboxDn",
    "SkyboxUp",
}

local function hookAssetObject(obj)

    if hookedAssets[obj] then return end
    hookedAssets[obj] = true

    for _, property in ipairs(ASSET_PROPERTIES) do

        pcall(function()

            replaceProperty(obj, property)

            obj:GetPropertyChangedSignal(property):Connect(function()
                replaceProperty(obj, property)
            end)

        end)
    end

    if obj:IsA("Sky") then

        for _, property in ipairs(SKY_PROPERTIES) do

            pcall(function()

                replaceProperty(obj, property)

                obj:GetPropertyChangedSignal(property):Connect(function()
                    replaceProperty(obj, property)
                end)

            end)
        end
    end
end

--// =====================================================
--// HEADSHOT AUDIO REPLACER
--// =====================================================

local function setupHeadshots()

    if not HEADSHOT_ENABLED then return end

    local success, folder = pcall(function()

        return player:WaitForChild("PlayerScripts")
            :WaitForChild("Weapon_Local")
            :WaitForChild("Headshots")

    end)

    if not success then
        warn("[HEADSHOT] Folder not found")
        return
    end

    local function replaceHeadshot(sound)

        if not sound:IsA("Sound") then return end

        sound.SoundId = HEADSHOT_NEW_ID

        print("[HEADSHOT CHANGED]", sound.Name)
    end

    local count = 0

    for _, sound in ipairs(folder:GetDescendants()) do

        if sound:IsA("Sound") then
            replaceHeadshot(sound)
            count += 1
        end
    end

    folder.DescendantAdded:Connect(replaceHeadshot)

    print("[HEADSHOT] Total changed:", count)
end

task.spawn(setupHeadshots)

--// =====================================================
--// UNIVERSAL CUSTOM GUN AUDIO
--// =====================================================

local hookedSounds = {}
local originalIDs = {}

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

    applySound(sound)

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

    tool.DescendantAdded:Connect(function(obj)
        hookSound(obj)
    end)
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

--// =====================================================
--// CUSTOM SPARKLES / PARTICLES
--// =====================================================

local SPARKLE_URL =
    "https://raw.githubusercontent.com/walx-x/FILEMANAGEMENT/refs/heads/main/blue_sparks_1.webp"

local CUSTOM_SPARKLE_ASSET =
    loadCustomTexture(SPARKLE_URL, "blue_sparks_1.webp")

local hookedEffects = {}

local function checkAndReplaceTexture(obj)

    if not SPARKLES_ENABLED or not CUSTOM_SPARKLE_ASSET then
        return
    end

    if hookedEffects[obj] then return end

    if obj:IsA("ParticleEmitter")
        or obj:IsA("Beam")
        or obj:IsA("Trail") then

        hookedEffects[obj] = true

        local function update()

            if not SPARKLES_ENABLED then return end

            local currentId = getAssetId(obj.Texture)

            if currentId == TARGET_SPARKLE_ID then

                obj.Texture = CUSTOM_SPARKLE_ASSET

                print("[SPARKLES] Replaced:", obj.Name)

            end
        end

        update()

        obj:GetPropertyChangedSignal("Texture"):Connect(update)

    end
end

--// =====================================================
--// INITIAL SCAN
--// =====================================================

local function scanAll()

    local count = 0

    for _, obj in ipairs(game:GetDescendants()) do

        hookAssetObject(obj)
        checkAndReplaceTexture(obj)

        if obj:IsA("Sound") then
            hookSound(obj)
        end

        count += 1
    end

    print("[ASSETS] Scanned objects:", count)
end

scanAll()

--// =====================================================
--// REAL-TIME MONITOR
--// =====================================================

game.DescendantAdded:Connect(function(obj)

    task.defer(function()

        hookAssetObject(obj)
        checkAndReplaceTexture(obj)

        if obj:IsA("Sound") then
            hookSound(obj)
        end

    end)

end)

--// =====================================================
--// COMPLETE
--// =====================================================

print("========================================")
print("[CUSTOM AUDIO] Loaded")
print("[HEADSHOT] Loaded")
print("[SPARKLES] Loaded")
print("[ASSET REPLACER] Loaded")
print("[SKYBOX REPLACER] Loaded")
print("[UNIVERSAL REPLACER] COMPLETE")
print("========================================")
