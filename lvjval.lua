-- 防传送回家的原地复活脚本
-- 功能: 角色死亡后复活时回到死亡位置，防止被游戏强制传送回家

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- 存储死亡位置
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

-- 防止被传送回家的机制
local function SetupAntiTeleport()
    LocalPlayer.CharacterAdded:Connect(function(character)
        local rootPart = character:WaitForChild("HumanoidRootPart")
        
        -- 等待角色完全加载
        wait(1)
        
        -- 如果开启了原地复活且有记录的死亡位置
        if respawnAtDeathLocation and deathPosition then
            -- 传回死亡位置
            rootPart.CFrame = CFrame.new(deathPosition)
            
            -- 持续监控，防止被传送回家
            spawn(function()
                for i = 1, 10 do  -- 监控10秒
                    wait(1)
                    
                    -- 检查是否被传送到了远处（可能是重生点）
                    local currentPos = rootPart.Position
                    local distance = (currentPos - deathPosition).Magnitude
                    
                    if distance > 50 then  -- 如果被传送了超过50个单位
                        -- 再次传回死亡位置
                        rootPart.CFrame = CFrame.new(deathPosition)
                        ShowNotification("原地复活", "已返回死亡位置")
                    end
                end
            end)
            
            ShowNotification("原地复活", "已返回死亡位置")
        end
    end)
end

-- 监听角色死亡
local function SetupDeathListener()
    LocalPlayer.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        local rootPart = character:WaitForChild("HumanoidRootPart")
        
        -- 监听死亡事件
        humanoid.Died:Connect(function()
            -- 记录死亡位置
            deathPosition = rootPart.Position
            ShowNotification("死亡记录", "已记录死亡位置")
        end)
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
                ShowNotification("死亡记录", "已记录死亡位置")
            end)
        end
    end
end

-- 初始化
wait(1) -- 等待游戏加载

SetupAntiTeleport()
SetupDeathListener()
SetupExistingCharacter()

ShowNotification("原地复活", "脚本已加载\n默认开启原地复活功能")
print("原地复活脚本已加载 - 防传送回家版本")
