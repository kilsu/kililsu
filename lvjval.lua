-- 原地复活脚本 - 修复按钮显示问题
-- 功能: 角色死亡后复活时回到死亡位置，带屏幕按钮

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- 存储死亡位置和开关状态
local deathPosition = nil
local respawnAtDeathLocation = true

-- 显示通知
local function ShowNotification(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 5,
    })
end

-- 创建屏幕按钮
local function CreateScreenButton()
    -- 删除现有按钮
    local existingGUI = CoreGui:FindFirstChild("RespawnButtonGUI")
    if existingGUI then
        existingGUI:Destroy()
    end
    
    -- 创建主GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RespawnButtonGUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true

    -- 创建按钮框架
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Size = UDim2.new(0, 150, 0, 50)
    ButtonFrame.Position = UDim2.new(0, 20, 0.5, -25)
    ButtonFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ButtonFrame.BackgroundTransparency = 0.3
    ButtonFrame.BorderSizePixel = 0
    ButtonFrame.Parent = ScreenGui
    
    -- 圆角
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = ButtonFrame
    
    -- 创建按钮
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.9, 0, 0.7, 0)
    Button.Position = UDim2.new(0.05, 0, 0.15, 0)
    Button.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
    Button.Text = "原地复活: 开启"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.GothamSemibold
    Button.Parent = ButtonFrame
    
    -- 按钮圆角
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = Button
    
    -- 按钮边框
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 2
    UIStroke.Color = Color3.fromRGB(255, 255, 255)
    UIStroke.Parent = Button
    
    -- 按钮点击事件
    Button.MouseButton1Click:Connect(function()
        respawnAtDeathLocation = not respawnAtDeathLocation
        
        if respawnAtDeathLocation then
            Button.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
            Button.Text = "原地复活: 开启"
            ShowNotification("原地复活", "功能已开启")
        else
            Button.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
            Button.Text = "原地复活: 关闭"
            ShowNotification("原地复活", "功能已关闭")
        end
    end)
    
    print("按钮创建成功")
    return ScreenGui
end

-- 监听角色死亡和复活
local function SetupRespawnListener()
    LocalPlayer.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        local rootPart = character:WaitForChild("HumanoidRootPart")
        
        -- 监听死亡事件
        humanoid.Died:Connect(function()
            -- 记录死亡位置
            deathPosition = roo
