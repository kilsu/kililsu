-- 死亡后原地复活脚本
-- 功能: 角色死亡后复活时回到死亡位置

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- 存储死亡位置
local deathPosition = nil

-- 显示通知
local function ShowNotification(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 5,
    })
end

-- 监听角色死亡
LocalPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    humanoid.Died:Connect(function()
        -- 记录死亡位置
        deathPosition = rootPart.Position
        print("记录死亡位置: " .. tostring(deathPosition))
        ShowNotification("死亡记录", "已记录死亡位置")
    end)
    
    -- 当角色复活时，如果之前记录了死亡位置，则传送回去
    if deathPosition then
        wait(1) -- 等待角色完全加载
        rootPart.CFrame = CFrame.new(deathPosition)
        print("已传送回死亡位置")
        ShowNotification("原地复活", "已返回死亡位置")
    end
end)

-- 如果已经有角色，也设置监听
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

ShowNotification("原地复活", "脚本已加载\n死亡后将返回原地")
print("原地复活脚本已加载")
