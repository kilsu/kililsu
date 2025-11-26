-- 原地复活脚本 - 屏幕按钮版本
-- 功能: 角色死亡后复活时回到死亡位置，带屏幕按钮

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

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
    -- 如果已有按钮，先删除
    local existingGUI = game:GetService("CoreGui"):FindFirstChild("RespawnButtonGUI")
    if existingGUI then
        existingGUI:Destroy()
    end
    
    -- 创建主GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RespawnButtonGUI"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- 创建按钮
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 120, 0, 40)
    Button.Position = UDim2.new(0, 20, 0.5, -20)
    Button.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
    Button.Text = "原地复活: 开"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.GothamSemibold
    Button.Parent = ScreenGui
    
    -- 圆角
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = Button
    
    -- 边框
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 2
    UIStroke.Color = Color3.fromRGB(255, 255, 255)
    UIStroke.Parent = Button
    
    -- 按钮点击事件
    Button.MouseButton1Click:Connect(function()
        respawnAtDeathLocation = not respawnAtDeathLocation
        
        if respawnAtDeathLocation then
            Button.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
            Button.Text = "原地复活: 开"
            ShowNotification("原地复活", "功能已开启")
        else
            Button.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
            Button.Text = "原地复活: 关"
            ShowNotification("原地复活", "功能已关闭")
        end
    end)
    
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
CreateScreenButton()
SetupRespawnListener()
SetupExistingCharacter()

ShowNotification("原地复活", "脚本已加载\n默认开启原地复活功能")
print("原地复活脚本已加载 - 屏幕按钮版本")
