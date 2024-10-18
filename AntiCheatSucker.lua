local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Variables to track teleportation and candy collection
local teleportEnabled = false
local isTeleporting = false
local maxCandiesBeforeReset = 20 -- Set the limit for candies before resetting
local collectedCandies = 0

-- Function to find the CoinContainer
local function findCoinContainer()
    for _, child in pairs(workspace:GetChildren()) do
        if child:FindFirstChild("CoinContainer") then
            return child.CoinContainer
        end
    end
    return nil
end

-- Function to find the nearest coin within a specified radius
local function findNearestCoin(radius)
    local coinContainer = findCoinContainer()
    if not coinContainer then return nil end

    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local nearestCoin, nearestDistance = nil, radius

    for _, coin in pairs(coinContainer:GetChildren()) do
        local distance = (coin.Position - humanoidRootPart.Position).Magnitude
        if distance < nearestDistance then
            nearestCoin, nearestDistance = coin, distance
        end
    end
    return nearestCoin
end

-- Function to teleport to a coin
local function teleportToCoin(coin)
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = coin.CFrame})
    tween:Play()
    return tween
end

-- Function to teleport to a nearby or random coin
local function teleportToNearbyOrRandomCoin()
    if not teleportEnabled or isTeleporting then return end
    isTeleporting = true

    local nearbyRadius = 50
    local nearbyCoin = findNearestCoin(nearbyRadius)

    if nearbyCoin then
        local tween = teleportToCoin(nearbyCoin)
        tween.Completed:Wait()
        collectedCandies = collectedCandies + 1
    else
        local coinContainer = findCoinContainer()
        if coinContainer and #coinContainer:GetChildren() > 0 then
            local randomCoin = coinContainer:GetChildren()[math.random(1, #coinContainer:GetChildren())]
            local tween = teleportToCoin(randomCoin)
            tween.Completed:Wait()
            collectedCandies = collectedCandies + 1
        end
    end

    -- Reset character if candy limit is reached to avoid detection
    if collectedCandies >= maxCandiesBeforeReset then
        character:BreakJoints() -- Forces character reset
        collectedCandies = 0
        wait(3) -- Allow time for respawn
    end

    isTeleporting = false
end

-- Improved GUI design
local function createGUI()
    local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
    ScreenGui.Name = "MM2CandyAutoFarmGUI"
    ScreenGui.ResetOnSpawn = false

    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Size = UDim2.new(0, 220, 0, 130)
    Frame.Position = UDim2.new(0.5, -110, 0.5, -65)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true
    Frame.BackgroundTransparency = 0.2

    local Title = Instance.new("TextLabel", Frame)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundTransparency = 1
    Title.Text = "MM2 Candy Auto Farm"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 20
    Title.Font = Enum.Font.GothamBold

    local ToggleButton = Instance.new("TextButton", Frame)
    ToggleButton.Size = UDim2.new(0.8, 0, 0, 40)
    ToggleButton.Position = UDim2.new(0.1, 0, 0.4, 0)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    ToggleButton.Text = "Teleport OFF"
    ToggleButton.TextColor3 = Color3.new(1, 1, 1)
    ToggleButton.TextSize = 16
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.AutoButtonColor = false

    local CandyCounter = Instance.new("TextLabel", Frame)
    CandyCounter.Size = UDim2.new(1, 0, 0, 20)
    CandyCounter.Position = UDim2.new(0, 0, 0.8, 0)
    CandyCounter.BackgroundTransparency = 1
    CandyCounter.Text = "Candies Collected: 0"
    CandyCounter.TextColor3 = Color3.fromRGB(255, 255, 255)
    CandyCounter.TextSize = 14
    CandyCounter.Font = Enum.Font.Gotham

    -- Function to update candy counter
    local function updateCandyCounter()
        CandyCounter.Text = "Candies Collected: " .. collectedCandies
    end

    -- Function to toggle teleportation
    ToggleButton.MouseButton1Click:Connect(function()
        teleportEnabled = not teleportEnabled
        ToggleButton.Text = teleportEnabled and "Teleport ON" or "Teleport OFF"
        ToggleButton.BackgroundColor3 = teleportEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    end)

    return ScreenGui, updateCandyCounter
end

-- Create or recreate the GUI when necessary
local function ensureGUI()
    if not player.PlayerGui:FindFirstChild("MM2CandyAutoFarmGUI") then
        local gui, updateCounter = createGUI()
        RunService.Heartbeat:Connect(function()
            if teleportEnabled then
                updateCounter()
            end
        end)
    end
end

-- Handle character spawning and recreate the GUI
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    ensureGUI()
end)

-- Initial GUI creation
ensureGUI()

-- Start the main loop for continuous teleportation
RunService.Heartbeat:Connect(function()
    if teleportEnabled and character and character:FindFirstChild("HumanoidRootPart") then
        teleportToNearbyOrRandomCoin()
    end
end)

print("Enhanced MM2 Candy Auto Farm script with better UI and optimized functionality loaded.")
