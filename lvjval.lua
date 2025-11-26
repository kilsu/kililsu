-- 死亡留在原地脚本 - 自动执行版
-- 作者: 小皮
-- 功能: 角色死亡后自动留在原地不复活

if _G.DeathStayAutoLoaded then
    return
end
_G.DeathStayAutoLoaded = true

-- 服务引用
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- 主变量
local DeathStayEnabled = true
local GhostCharacter = nil

-- 通知函数
local function ShowNotification(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 5,
    })
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
    
    return marker
end

-- 设置防重生系统
local function SetupAntiRespawn()
    LocalPlayer.CharacterAdded:Connect(function(character)
        if not DeathStayEnabled then return end
        
        local humanoid = character:WaitForChild("Humanoid")
        local rootPart = character:WaitForChild("HumanoidRootPart")
        
        humanoid.Died:Connect(function()
            local deathPos = rootPart.Position
            CreateDeathMarker(deathPos)
            ShowNotification("死亡留在原地", "角色已保持在死亡位置")
            
            -- 阻止重生
            spawn(function()
                while DeathStayEnabled do
                    if LocalPlayer.Character then
                        LocalPlayer.Character = nil
                    end
                    wait(0.1)
                end
            end)
        end)
    end)
end

-- 为现有角色设置监听
local function SetupExistingCharacter()
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

-- 初始化
wait(1) -- 等待游戏加载

SetupAntiRespawn()
SetupExistingCharacter()

ShowNotification("死亡留在原地", "功能已启用\n死亡后将停留在原地")

print("死亡留在原地脚本已加载 - 自动执行模式")
print("作者: 小皮")

-- 清理函数
local function Cleanup()
    if GhostCharacter then
        GhostCharacter:Destroy()
        GhostCharacter = nil
    end
    _G.DeathStayAutoLoaded = false
end

-- 玩家离开时清理
Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        Cleanup()
    end
end)
