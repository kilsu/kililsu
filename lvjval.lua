local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RainbowWalkUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 360)
frame.Position = UDim2.new(0.5, 100, 0.5, -180)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local border = Instance.new("UIStroke")
border.Color = Color3.new(1, 1, 1)
border.Thickness = 2
border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
border.Parent = frame

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 40)
title.Position = UDim2.new(0, 10, 0, 10)
title.BackgroundTransparency = 1
title.Text = "大司马偷走脑红"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local dragging
local dragInput
local dragStart
local startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateInput(input)
    end
end)

local walkToggle = Instance.new("TextButton")
walkToggle.Size = UDim2.new(0.9, 0, 0, 40)
walkToggle.Position = UDim2.new(0.05, 0, 0, 60)
walkToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
walkToggle.Text = "踏空行走: 关闭"
walkToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
walkToggle.Font = Enum.Font.Gotham
walkToggle.TextSize = 16
walkToggle.Parent = frame

local walkCorner = Instance.new("UICorner")
walkCorner.CornerRadius = UDim.new(0, 8)
walkCorner.Parent = walkToggle

local walkWarning = Instance.new("TextLabel")
walkWarning.Size = UDim2.new(0.9, 0, 0, 30)
walkWarning.Position = UDim2.new(0.05, 0, 0, 105)
walkWarning.BackgroundTransparency = 1
walkWarning.Text = "开启时请尽快走到高处关功能，要不然会被拉回"
walkWarning.TextColor3 = Color3.fromRGB(255, 200, 0)
walkWarning.Font = Enum.Font.Gotham
walkWarning.TextSize = 12
walkWarning.TextWrapped = true
walkWarning.Visible = false
walkWarning.Parent = frame

local espToggle = Instance.new("TextButton")
espToggle.Size = UDim2.new(0.9, 0, 0, 40)
espToggle.Position = UDim2.new(0.05, 0, 0, 140)
espToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
espToggle.Text = "玩家透视: 关闭"
espToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
espToggle.Font = Enum.Font.Gotham
espToggle.TextSize = 16
espToggle.Parent = frame

local espCorner = Instance.new("UICorner")
espCorner.CornerRadius = UDim.new(0, 8)
espCorner.Parent = espToggle

local instantToggle = Instance.new("TextButton")
instantToggle.Size = UDim2.new(0.9, 0, 0, 40)
instantToggle.Position = UDim2.new(0.05, 0, 0, 190)
instantToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
instantToggle.Text = "秒互动: 关闭[不建议使用]"
instantToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
instantToggle.Font = Enum.Font.Gotham
instantToggle.TextSize = 16
instantToggle.Parent = frame

local instantCorner = Instance.new("UICorner")
instantCorner.CornerRadius = UDim.new(0, 8)
instantCorner.Parent = instantToggle

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -35, 0, 5)
minimizeButton.BackgroundTransparency = 1
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 20
minimizeButton.Parent = frame

local minimized = false
minimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        frame.Size = UDim2.new(0, 40, 0, 40)
        minimizeButton.Text = "+"
        minimizeButton.Position = UDim2.new(0, 5, 0, 5)
        title.Visible = false
        walkToggle.Visible = false
        walkWarning.Visible = false
        espToggle.Visible = false
        instantToggle.Visible = false
    else
        frame.Size = UDim2.new(0, 220, 0, 360)
        minimizeButton.Text = "-"
        minimizeButton.Position = UDim2.new(1, -35, 0, 5)
        title.Visible = true
        walkToggle.Visible = true
        espToggle.Visible = true
        instantToggle.Visible = true
    end
end)

local rainbowBlocks = {}
local walkEnabled = false
local lastPosition = nil
local rainbowColors = {
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(255, 127, 0),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 0, 255),
    Color3.fromRGB(75, 0, 130),
    Color3.fromRGB(148, 0, 211)
}

local function createRainbowBlock(position, colorIndex)
    local block = Instance.new("Part")
    block.Size = Vector3.new(4, 0.5, 4)
    block.Position = position
    block.Anchored = true
    block.CanCollide = true
    block.Material = Enum.Material.Neon
    block.Color = rainbowColors[colorIndex]
    block.Transparency = 0.3
    
    local selectionBox = Instance.new("SelectionBox")
    selectionBox.Adornee = block
    selectionBox.Color3 = block.Color
    selectionBox.Transparency = 0.5
    selectionBox.Parent = block
    
    block.Parent = workspace
    
    task.delay(5, function()
        if block and block.Parent then
            local tween = TweenService:Create(block, TweenInfo.new(0.5), {Transparency = 1})
            tween:Play()
            tween.Completed:Wait()
            block:Destroy()
        end
    end)
    
    return block
end

walkToggle.MouseButton1Click:Connect(function()
    walkEnabled = not walkEnabled
    if walkEnabled then
        walkToggle.Text = "踏空走: 开启"
        walkToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        walkWarning.Visible = true
        lastPosition = humanoidRootPart.Position
    else
        walkToggle.Text = "踏空走: 关闭"
        walkToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        walkWarning.Visible = false
    end
end)

local espEnabled = false
local espHandles = {}
local rainbowEspColors = {
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(255, 165, 0),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 0, 255),
    Color3.fromRGB(75, 0, 130),
    Color3.fromRGB(238, 130, 238)
}

local function createEsp(player)
    local character = player.Character
    if not character then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerHighlight"
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = character
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerNameTag"
    billboard.Adornee = character:WaitForChild("Head")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = character
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 18
    nameLabel.Parent = billboard
    
    espHandles[player] = {highlight, billboard}
    
    coroutine.wrap(function()
        while espEnabled and character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 do
            for i = 1, #rainbowEspColors do
                if not espEnabled or not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then break end
                highlight.FillColor = rainbowEspColors[i]
                highlight.OutlineColor = rainbowEspColors[i]
                nameLabel.TextColor3 = rainbowEspColors[i]
                task.wait(0.5)
            end
        end
    end)()
end

local function removeEsp(player)
    if espHandles[player] then
        for _, handle in ipairs(espHandles[player]) do
            handle:Destroy()
        end
        espHandles[player] = nil
    end
end

espToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        espToggle.Text = "玩家透视: 开启"
        espToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= player then
                if otherPlayer.Character then
                    createEsp(otherPlayer)
                end
                otherPlayer.CharacterAdded:Connect(function(character)
                    if espEnabled then
                        createEsp(otherPlayer)
                    end
                end)
            end
        end
        
        Players.PlayerAdded:Connect(function(newPlayer)
            if espEnabled then
                newPlayer.CharacterAdded:Connect(function(character)
                    createEsp(newPlayer)
                end)
            end
        end)
    else
        espToggle.Text = "玩家透视: 关闭"
        espToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        
        for otherPlayer, _ in pairs(espHandles) do
            removeEsp(otherPlayer)
        end
    end
end)

local instantEnabled = false

instantToggle.MouseButton1Click:Connect(function()
    instantEnabled = not instantEnabled
    if instantEnabled then
        instantToggle.Text = "秒互动: 开启"
        instantToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        
        local function modifyPrompt(prompt)
            prompt.HoldDuration = 0
        end
        
        local function isTargetPrompt(prompt)
            local parent = prompt.Parent
            while parent do
                if parent == workspace or parent == workspace:FindFirstChild("BankRobbery") and parent:FindFirstChild("VaultDoor") then
                    return true
                end
                parent = parent.Parent
            end
            return false
        end
        
        for _, prompt in ipairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and isTargetPrompt(prompt) then
                modifyPrompt(prompt)
            end
        end
        
        workspace.DescendantAdded:Connect(function(instance)
            if instance:IsA("ProximityPrompt") and isTargetPrompt(instance) then
                modifyPrompt(instance)
            end
        end)
    else
        instantToggle.Text = "秒互动: 关闭[不建议使用]"
        instantToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
end)

local colorIndex = 1
RunService.Heartbeat:Connect(function()
    if walkEnabled and character and humanoidRootPart then
        local currentPosition = humanoidRootPart.Position
        local distance = lastPosition and (currentPosition - lastPosition).Magnitude or 0
        
        if distance >= 1 then
            local blockPosition = Vector3.new(
                currentPosition.X,
                currentPosition.Y - 3,
                currentPosition.Z
            )
            
            createRainbowBlock(blockPosition, colorIndex)
            colorIndex = colorIndex % #rainbowColors + 1
            lastPosition = currentPosition
        end
    end
    
    if espEnabled then
        for otherPlayer, handles in pairs(espHandles) do
            if otherPlayer.Character and otherPlayer.Character:FindFirstChild("Humanoid") then
                local humanoid = otherPlayer.Character.Humanoid
                if humanoid.Health <= 0 then
                    removeEsp(otherPlayer)
                end
            else
                removeEsp(otherPlayer)
            end
        end
    end
end)

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
    lastPosition = humanoidRootPart.Position
end)
