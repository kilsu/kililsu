-- 原地复活脚本 - 皮脚本风格
-- 功能: 角色死亡后复活时回到死亡位置，带开关按钮

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

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

-- 创建皮脚本风格按钮
local function CreatePiScriptButton()
    -- 创建主GUI
    local MainGUI = Instance.new("ScreenGui")
    MainGUI.Name = "RespawnAtDeathGUI"
    MainGUI.Parent = game:GetService("CoreGui")
    MainGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- 创建拖拽框架
    local DragFrame = Instance.new("Frame")
    DragFrame.Size = UDim2.new(0, 200, 0, 40)
    DragFrame.Position = UDim2.new(0, 20, 0, 20)
    DragFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    DragFrame.BorderSizePixel = 0
    DragFrame.Parent = MainGUI
    DragFrame.Active = true
    DragFrame.Draggable = true

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = DragFrame

    -- 标题
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Title.Text = "原地复活"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.Parent = DragFrame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = Title

    -- 开关按钮
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0.9, 0, 0, 35)
    ToggleButton.Position = UDim2.new(0.05, 0, 0, 45)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
    ToggleButton.Text = "开启"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 14
    ToggleButton.Font = Enum.Font.GothamSemibold
    ToggleButton.Parent = DragFrame

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = ToggleButton

    -- 状态标签
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, 0, 0, 25)
    StatusLabel.Position = UDim2.new(0, 0, 0, 85)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "死亡后将返回原地"
    StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    StatusLabel.TextSize = 12
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Parent = DragFrame

    -- 切换功能
    ToggleButton.MouseButton1Click:Connect(function()
        respawnAtDeathLocation = not respawnAtDeathLocation
        
        if respawnAtDeathLocation then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
            ToggleButton.Text = "开启"
            StatusLabel.Text = "死亡后将返回原地"
            StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            ShowNotification("原地复活", "功能已开启")
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
            ToggleButton.Text = "关闭"
            StatusLabel.Text = "正常复活"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            ShowNotification("原地复活", "功能已关闭")
        end
    end)

    -- 最小化/最大化功能
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 30, 0, 20)
    MinimizeButton.Position = UDim2.new(1, -35, 0, 5)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    MinimizeButton.Text = "_"
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.TextSize = 14
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.Parent = Title

    local MinimizeCorner = Instance.new("UICorner")
    MinimizeCorner.CornerRadius = UDim.new(0, 4)
    MinimizeCorner.Parent = MinimizeButton

    local isMinimized = false
    MinimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            DragFrame.Size = UDim2.new(0, 200, 0, 40)
            ToggleButton.Visible = false
            StatusLabel.Visible = false
            MinimizeButton.Text = "+"
        else
            DragFrame.Size = UDim2.new(0, 200, 0, 115)
            ToggleButton.Visible = true
            StatusLabel.Visible = true
            MinimizeButton.Text = "_"
        end
    end)

    return MainGUI
end

-- 监听角色死亡和复活
local function SetupRespawnListener()
    LocalPlayer.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        local rootPart = character:WaitForChild("HumanoidRootPart")
        
        -- 监听死亡事件
        humanoid.Died:Connect(function()
            -- 记录死亡位置
            deathPosition = rootPart.Position
            print("记录死亡位置: " .. tostring(deathPosition))
            ShowNotification("死亡记录", "已记录死亡位置")
        end)
        
        -- 当角色复活时，如果功能开启且之前记录了死亡位置，则传送回去
        if respawnAtDeathLocation and deathPosition then
            wait(1) -- 等待角色完全加载
            rootPart.CFrame = CFrame.new(deathPosition)
            print("已传送回死亡位置")
            ShowNotification("原地复活", "已返回死亡位置")
        end
    end)
end

-- 如果已经有角色，也设置监听
local function SetupExistingCharacter()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and rootPart then
            humanoid.Died:Connect(function()
                deathPosition = rootPart.Position
                print("记录死亡位置: " .. tostring(deathPosition))
                ShowNotification("死亡记录", "已记录死亡位置")
            end)
        end
    end
end

-- 初始化
wait(1) -- 等待游戏加载
CreatePiScriptButt
