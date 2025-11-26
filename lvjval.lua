-- 超长重生时间脚本
-- 功能: 将重生时间设置为12小时，不强制角色死亡

if _G.LongRespawnLoaded then return end
_G.LongRespawnLoaded = true

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 设置12小时重生时间（43200秒）
local function SetLongRespawnTime()
    -- 尝试多种方法设置重生时间
    pcall(function()
        -- 方法1: 直接设置重生时间
        if LocalPlayer.RespawnTime ~= nil then
            LocalPlayer.RespawnTime = 43200 -- 12小时
        end
    end)
    
    pcall(function()
        -- 方法2: 尝试通过Player属性设置
        LocalPlayer:SetAttribute("RespawnTime", 43200)
    end)
    
    -- 方法3: 持续监控并重置重生时间
    spawn(function()
        while wait(10) do -- 每10秒检查一次
            pcall(function()
                if LocalPlayer.RespawnTime ~= nil and LocalPlayer.RespawnTime < 43200 then
                    LocalPlayer.RespawnTime = 43200
                    print("重生时间已重置为12小时")
                end
            end)
        end
    end)
end

-- 监听角色死亡
local function SetupDeathListener()
    LocalPlayer.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        
        humanoid.Died:Connect(function()
            -- 角色死亡时确保重生时间为12小时
            SetLongRespawnTime()
            print("角色死亡，重生时间设置为12小时")
        end)
    end)
end

-- 初始化
SetLongRespawnTime()
SetupDeathListener()

-- 如果已经有角色，也设置监听
if LocalPlayer.Character then
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.Died:Connect(function()
            SetLongRespawnTime()
            print("角色死亡，重生时间设置为12小时")
        end)
    end
end

print("超长重生时间已启用 - 设置为12小时")
