-- 死亡留在原地脚本 - 完整版
-- 作者: 小皮
-- GitHub: https://github.com/kilsu/kililsu

-- 防止重复加载
if _G.DeathStayScriptLoaded then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "死亡留在原地",
        Text = "脚本已经加载过了",
        Duration = 3,
    })
    return
end
_G.DeathStayScriptLoaded = true

print("=== 死亡留在原地脚本开始加载 ===")

-- 服务引用
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- 主变量
local DeathStayEnabled = true
local GhostCharacter = nil
local AntiRespawnConnection = nil

-- 通知函数
local function ShowNotification(title, text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 5,
        })
    end)
    print("[通知] " .. title .. ": " .. text)
end

-- 创建死亡标记
local function CreateDeathMarker(position)
    if GhostCharacter and GhostCharacter.Parent then
        GhostCharacter:Destroy()
    end
    
    local marker = Instance.new("Part")
    marker.Name = "DeathPositionMarker"
    marker.Size = Vector3.new(3, 3, 3)
    marker.Position = position
    marker.Anchored = true
    marker.CanCollide = false
    marker.Transparency = 0.3
    marker.BrickColor = BrickColor.new("Bright blue")
    marker.Material = Enum.Material.Neon
    
    -- 发光效果
    local light = Instance.new("PointLight")
    light.Brightness = 2
    light.Range = 12
    light.Color = Color3.fromRGB(0, 120, 255)
    light.Parent = marker
    
    marker.Parent = workspace
    GhostCharacter = marker
    
    print("创建死亡标记在位置: " .. tostring(position))
    return marker
end

-- 设置防重生系统
local function SetupAntiRespawn()
    if AntiRespawnConnection then
        AntiRespawnConnection:Disconnect()
    end
    
    AntiRespawnConnection = LocalPlayer.CharacterAdded:Connect(function(character)
        if not DeathStayEnabled then return end
        
        local humanoid = character:WaitForChild("Humanoid", 5)
        local rootPart = character:WaitForChild("HumanoidRootPart", 5)
        
        if humanoid and rootPart then
            humanoid.Died:Connect(function()
                print("角色死亡，开始阻止重生")
                local deathPos = rootPart.Position
                CreateDeathMarker(deathPos)
                ShowNotification("死亡留在原地", "角色已保持在死亡位置")
                
                -- 阻止重生
                spawn(function()
                    while DeathStayEnabled do
                        if LocalPlayer.Character then
                            LocalPlayer.Character = nil
                            print("阻止角色重生")
                        end
                        wait(0.1)
                    end
                end)
            end)
        end
    end)
    
    print("防重生系统已设置")
end

-- 重置功能
local function ResetRespawn()
    if GhostCharacter then
        GhostCharacter:Destroy()
        GhostCharacter = nil
    end
    
    if AntiRespawnConnection then
        AntiRespawnConnection:Disconnect()
        AntiRespawnConnection = nil
    end
    
    print("重置重生系统")
end

-- 创建UI界面
local function CreateUI()
    -- 移除现有UI
    local existingUI = CoreGui:FindFirstChild("DeathStayGUI")
    if existingUI then
        existingUI:Destroy()
    end
    
    -- 创建新UI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DeathStayGUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.Enabled = true

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 140)
    MainFrame.Position = UDim2.new(0.02, 0, 0.02, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame

    -- 标题
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Title.Text = "💀 死亡留在原地"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame

    -- 切换按钮
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0.8, 0, 0, 45)
    ToggleButton.Position = UDim2.new(0.1, 0, 0.3, 0)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
    ToggleButton.Text = "✅ 已启用"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 16
    ToggleButton.Font = Enum.Font.GothamSemibold
    ToggleButton.Parent = MainFrame

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = ToggleButton

    -- 状态标签
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, 0, 0, 30)
    StatusLabel.Position = UDim2.new(0, 0, 0.75, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "状态: 死亡后将停留在原地"
    StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    StatusLabel.TextSize = 14
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Parent = MainFrame

    -- 按钮点击事件
    ToggleButton.MouseButton1Click:Connect(function()
        DeathStayEnabled = not DeathStayEnabled
        
        if DeathStayEnabled then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
            ToggleButton.Text = "✅ 已启用"
            StatusLabel.Text = "状态: 死亡后将停留在原地"
            StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            SetupAntiRespawn()
            ShowNotification("死亡留在原地", "功能已启用")
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
            ToggleButton.Text = "❌ 已禁用"
            StatusLabel.Text = "状态: 正常重生"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            ResetRespawn()
            ShowNotification("死亡留在原地", "功能已禁用")
        end
    end)

    print("UI界面创建成功")
    return ScreenGui
end

-- 初始化函数
local function Initialize()
    print("开始初始化脚本...")
    
    -- 等待游戏完全加载
    wait(2)
    
    -- 创建UI
    local success, err = pcall(CreateUI)
    if not success then
        warn("创建UI失败: " .. tostring(err))
        ShowNotification("脚本错误", "UI创建失败")
        return
    end
    
    -- 设置防重生系统
    success, err = pcall(SetupAntiRespawn)
    if not success then
        warn("设置防重生系统失败: " .. tostring(err))
        ShowNotification("脚本错误", "防重生系统设置失败")
        return
    end
    
    -- 显示成功通知
    ShowNotification("死亡留在原地", "脚本加载成功！")
    
    print("=== 死亡留在原地脚本加载完成 ===")
    print("作者: 小皮")
    print("GitHub: https://github.com/kilsu/kililsu")
    
    -- 为现有角色设置监听（如果有）
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Died:Connect(function()
                if DeathStayEnabled then
                    local deathPos = LocalPlayer.Character.HumanoidRootPart.Position
                    CreateDeathMarker(deathPos)
                    ShowNotification("死亡留在原地", "角色已保持在死亡位置")
                end
            end)
        end
    end
end

-- 启动初始化
spawn(Initialize)

-- 清理函数
local function Cleanup()
    ResetRespawn()
    _G.DeathStayScriptLoaded = false
    print("脚本清理完成")
end

-- 玩家离开时清理
Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        Cleanup()
    end
end)

-- 游戏关闭时清理
game:BindToClose(function()
    Cleanup()
end)

print("脚本主程序设置完成")
