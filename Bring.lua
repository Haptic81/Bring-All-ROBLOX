local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- List of part names or parent names to exclude from optimization
local excludedParts = {
    "SpawnLocation",   -- For spawn points that should retain their appearance
    "Checkpoint",      -- Any checkpoints or critical objects
    "UI",              -- Exclude UI parts from optimization
    "Water",           -- Retain water properties
}

-- Function to check if a part belongs to a player (to avoid modifying character models)
local function isPartOfPlayer(obj)
    for _, player in pairs(Players:GetPlayers()) do
        if obj:IsDescendantOf(player.Character) then
            return true
        end
    end
    return false
end

-- Function to check if a part or its parent should be excluded from optimization
local function shouldExcludePart(part)
    for _, excludedName in pairs(excludedParts) do
        if part.Name:find(excludedName) or (part.Parent and part.Parent.Name:find(excludedName)) then
            return true
        end
    end
    return false
end

-- Function to hide player usernames (removes BillboardGui elements that display names)
local function hideUsernames()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            for _, obj in pairs(player.Character:GetDescendants()) do
                if obj:IsA("BillboardGui") and obj.Name == "NameTag" then
                    obj:Destroy()  -- Remove the name tag
                end
            end
        end
    end

    -- Continuously monitor new players and hide their usernames when they spawn
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            for _, obj in pairs(character:GetDescendants()) do
                if obj:IsA("BillboardGui") and obj.Name == "NameTag" then
                    obj:Destroy()  -- Remove name tag for new players
                end
            end)
        end)
    end)
end

-- Function to remove or reduce particles in the game
local function optimizeParticles()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            obj.Rate = 0  -- Disable particle emission
            obj.Enabled = false  -- Turn off the effect
        end
    end
    
    -- Continuously monitor new particle effects and optimize them
    workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            obj.Rate = 0  -- Disable new particles
            obj.Enabled = false  -- Turn off the effect
        end
    end)
end

-- Function to apply potato graphics while keeping original colors
local function applyPotatoGraphics()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not isPartOfPlayer(obj) and not shouldExcludePart(obj) then
            obj.Material = Enum.Material.SmoothPlastic  -- Simplify material for performance
            obj.CastShadow = false  -- Turn off shadows to reduce rendering
            
            -- Keep the object's original color (do not change obj.Color)
            
            -- Remove textures or decals to minimize rendering
            for _, decal in pairs(obj:GetDescendants()) do
                if decal:IsA("Texture") or decal:IsA("Decal") then
                    decal:Destroy()  -- Remove decals to further optimize performance
                end
            end
        end
    end
    
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 -- Lock the game at lowest quality
    game:GetService("NetworkSettings").IncomingReplicationLag = 0 -- Reduce network lag
end

-- Function to reapply potato graphics every second to ensure they persist
local function maintainPotatoGraphics()
    while true do
        applyPotatoGraphics()  -- Apply potato graphics every second
        optimizeParticles()    -- Reapply particle optimizations
        wait(1)  -- Repeat every second to ensure settings remain
    end
end

-- Function to ensure the performance boost stays after respawn
local function onCharacterAdded(character)
    -- Reapply optimizations on respawn
    applyPotatoGraphics()
    optimizeParticles()
    
    -- Continuously monitor new parts being added to workspace and optimize them
    workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("BasePart") and not isPartOfPlayer(obj) and not shouldExcludePart(obj) then
            obj.Material = Enum.Material.SmoothPlastic
            obj.CastShadow = false
            
            -- Keep the object's original color (no changes to obj.Color)

            -- Remove decals or textures from newly added parts
            for _, decal in pairs(obj:GetDescendants()) do
                if decal:IsA("Texture") or decal:IsA("Decal") then
                    decal:Destroy()
                end
            end
        end
    end)
end

-- Apply the potato graphics when the script first runs
applyPotatoGraphics()
optimizeParticles()
hideUsernames()

-- Ensure the optimizations remain after player death/respawn
Players.LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- Start the loop to reapply potato graphics every second, forever
spawn(maintainPotatoGraphics)

-- Notify the player that the script is active
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "FPS Booster",
    Text = "Potato graphics with original colors applied!",
    Duration = 5
})
