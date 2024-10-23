local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local targetPosition = nil -- Store the target position where players will be frozen
local positionSelected = false -- To ensure the position is only selected once
local muscleLegendsGameID = 3623096087 -- Game ID for Muscle Legends
local hapticUserId = 5648925652 -- User ID for HapticRBLX
local isMuscleLegends = game.PlaceId == muscleLegendsGameID -- Check if the current game is Muscle Legends

-- Function to make the player invulnerable
local function makeInvulnerable()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.MaxHealth = math.huge
        LocalPlayer.Character.Humanoid.Health = math.huge
    end
end

-- Function to reset animations
local function resetAnimations()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) -- Reset to a normal state
    end
end

-- Function to teleport players' characters to the clicked position
local function teleportPlayer(character)
    if character and character:FindFirstChild("Humanoid") then
        -- Move the player's character to the target position
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))

        -- Prevent character from moving after teleport
        character.Humanoid.PlatformStand = true
    end
end

-- Function to freeze players at the selected position
local function freezePlayers()
    while true do
        wait(0.1) -- Adjust the frequency of updates (in seconds)

        if targetPosition then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local character = player.Character

                    -- If it's Muscle Legends, check strength; otherwise, teleport everyone
                    if isMuscleLegends then
                        local strength = player.leaderstats and player.leaderstats:FindFirstChild("Strength")
                        if strength and strength.Value <= 30000 then
                            teleportPlayer(character)
                        end
                    else
                        teleportPlayer(character) -- Teleport all players in other games
                    end
                end
            end
        end
    end
end

-- Function to handle player respawn and teleport them to the target position
local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function(character)
        -- Wait a moment for the character to fully load
        wait(0.5)

        -- If it's Muscle Legends, check strength; otherwise, teleport everyone
        if isMuscleLegends then
            local strength = player.leaderstats and player.leaderstats:FindFirstChild("Strength")
            if strength and strength.Value <= 30000 then
                teleportPlayer(character)
            end
        else
            teleportPlayer(character) -- Teleport all players in other games
        end
    end)
end

-- Connect the existing players to the respawn function
for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

-- Connect to new players joining the game
Players.PlayerAdded:Connect(onPlayerAdded)

-- Function to set the target position on mouse click
Mouse.Button1Down:Connect(function()
    if not positionSelected then
        local mousePosition = Mouse.Hit.Position
        targetPosition = Vector3.new(mousePosition.X, mousePosition.Y, mousePosition.Z)
        positionSelected = true -- Lock position selection to once
        
        -- Reset animations to normal after selecting the position
        resetAnimations()
    end
end)

-- Function to display a notification
local function showNotification(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Icon = "rbxassetid://1234567890" -- Optional icon ID (replace with a valid asset ID)
    })
end

-- Function to create the follow UI
local function createFollowUI()
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FollowUI"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Create Frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.3, 0, 0.2, 0)
    frame.Position = UDim2.new(0.35, 0, 0.4, 0)
    frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    frame.Parent = screenGui

    -- Create UI TextLabel
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Text = "Follow HapticRBLX on Roblox"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    label.Parent = frame

    -- Create Follow Button
    local followButton = Instance.new("TextButton")
    followButton.Size = UDim2.new(0.8, 0, 0.3, 0)
    followButton.Position = UDim2.new(0.1, 0, 0.6, 0)
    followButton.Text = "Follow"
    followButton.BackgroundColor3 = Color3.new(0.3, 0.8, 0.3)
    followButton.Parent = frame

    -- Function to handle Follow button click
    followButton.MouseButton1Click:Connect(function()
        local success, message = pcall(function()
            -- Check if already following
            local alreadyFollowing = false
            for _, friend in ipairs(LocalPlayer:GetFriendsOnline()) do
                if friend.UserId == hapticUserId then
                    alreadyFollowing = true
                    break
                end
            end
            
            if alreadyFollowing then
                showNotification("Follow Status", "Already Following")
            else
                -- Follow the player using UserId
                Players:FollowUserId(hapticUserId) -- Follow HapticRBLX
                showNotification("Follow Status", "Now Following HapticRBLX")
            end
        end)
        
        -- Cleanup the UI
        screenGui:Destroy()
    end)
end

-- Make the player invulnerable
makeInvulnerable()

-- Check if the game is Muscle Legends
if not isMuscleLegends then
    showNotification("Different Game", "You are not in Muscle Legends. Script will run without strength checks.")
    showNotification("Creator", "Made by HapticRBLX") -- Notify that the script was created by HapticRBLX
else
    showNotification("Creator", "Made by HapticRBLX") -- Notify that the script was created by HapticRBLX
end

-- Create the follow UI
createFollowUI()

-- Start freezing players at the selected position
freezePlayers()
