-- 原地复活脚本 - 带开关按钮
-- 功能: 角色死亡后复活时回到死亡位置，可随时开关

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- 存储死亡位置和开关状态
local deathPosition = nil
local respawnAtDeathLocation = true

-- 创建UI界面
local function CreateUI()
    -- 移除现有UI
    local existingUI = CoreGui:FindFirstChild("RespawnAtDeathGUI")
    if existingUI then
        existingUI:Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RespawnAtDeathGUI"
    ScreenGui.Parent = CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 250, 0, 100)
    MainFrame.Position = UDim2.new(0.02, 0, 0.02, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Title.Text = "原地复活开关"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0.8, 0, 0, 35)
    ToggleButton.Position = UDim2.new(0.1, 0, 0.35, 0)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
    ToggleButton.Text = "✅ 已开启"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 14
    ToggleButton.Font = Enum.Font.Gotham
    ToggleButton.Parent = MainFrame

    local UICorner2 = Instance.new("UICorner")
    UICorner2.CornerRadius = UDim.new(0, 6)
    UICorner2.Parent = ToggleButton

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, 0, 0, 25)
    StatusLabel.Position = UDim2.new(0, 0, 0.75, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "状态: 死亡后将返回原地"
    StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    StatusLabel.TextSize = 12
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Parent = MainFrame

    -- 切换功能
    ToggleButton.MouseButton1Click:Connect(function()
        respawnAtDeathLocation = not respawnAtDeathLocation
        
        if respawnAtDeathLocation then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
            ToggleButton.Text = "✅ 已开启"
            StatusLabel.Text = "状态: 死亡后将返回原地"
            StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            ShowNotification("原地复活", "功能已开启")
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
            ToggleButton.Text = "❌ 已关闭"
            StatusLabel.Text = "状态: 正常复活"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            ShowNotification("原地复活", "功能已关闭")
        end
    end)

    return ScreenGui
end

-- 显示通知
local function ShowNotification(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 5,
    })
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
CreateUI()
SetupRespawnListener()
SetupExistingCharacter()

ShowNotification("原地复活", "脚本已加载\n默认开启原地复活功能")
print("原地复活脚本已加载 - 带开关按钮版本")
