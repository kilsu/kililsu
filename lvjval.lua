-- 超长重生时间脚本 - 简化版
-- 功能: 将重生时间设置为12小时

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 显示通知
local function ShowNotification(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 5,
    })
end

-- 设置重生时间
local function SetRespawnTime()
    -- 尝试多种方法设置重生时间
    local success = false
    
    -- 方法1: 直接设置RespawnTime属性
    pcall(function()
        if LocalPlayer.RespawnTime ~= nil then
            LocalPlayer.RespawnTime = 43200 -- 12小时
            print("通过RespawnTime属性设置成功")
            success = true
        end
    end)
    
    -- 方法2: 使用SetAttribute
    pcall(function()
        LocalPlayer:SetAttribute("RespawnTime", 43200)
        print("通过SetAttribute设置成功")
        success = true
    end)
    
    -- 方法3: 尝试通过PlayerScripts设置
    pcall(function()
        local playerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
        if playerScripts then
            playerScripts:SetAttribute("RespawnTime", 43200)
            print("通过PlayerScripts设置成功")
            success = true
        end
    end)
    
    -- 方法4: 尝试通过PlayerGui设置
    pcall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            playerGui:SetAttribute("RespawnTime", 43200)
            print("通过PlayerGui设置成功")
            success = true
        end
    end)
    
    return success
end

-- 主函数
local function Main()
    print("开始设置重生时间...")
    
    -- 立即设置一次
    local success = SetRespawnTime()
    
    -- 定期重置重生时间
    spawn(function()
        while wait(30) do -- 每30秒重置一次
            SetRespawnTime()
        end
    end)
    
    -- 监听角色死亡
    LocalPlayer.CharacterAdded:Connect(function(character)
        wait(1) -- 等待角色完全加载
        SetRespawnTime()
        ShowNotification("重生时间", "已设置为12小时")
    end)
    
    -- 如果已经有角色，也设置一次
    if LocalPlayer.Character then
        wait(1)
        SetRespawnTime()
    end
    
    if success then
        ShowNotification("重生时间", "已设置为12小时")
        print("重生时间设置成功")
    else
        ShowNotification("设置失败", "无法修改重生时间")
        print("所有设置方法都失败了")
    end
end

-- 启动脚本
Main()
