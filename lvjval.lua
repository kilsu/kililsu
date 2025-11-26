-- 永久死亡脚本 - 阻止重生倒计时
-- 功能: 将重生时间设置为极大值，阻止角色重生

if _G.InfiniteDeathLoaded then return end
_G.InfiniteDeathLoaded = true

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 设置极长的重生时间
local function SetInfiniteRespawnTime()
    -- 尝试修改玩家的重生时间
    pcall(function()
        -- 方法1: 尝试直接设置重生时间
        LocalPlayer.RespawnTime = 999999 -- 设置极长的重生时间（秒）
    end)
    
    -- 方法2: 监听重生时间变化并重置为极大值
    if LocalPlayer:GetPropertyChangedSignal then
        LocalPlayer:GetPropertyChangedSignal("RespawnTime"):Connect(function()
            pcall(function()
                LocalPlayer.RespawnTime = 999999
            end)
        end)
    end
    
    -- 方法3: 定期重置重生时间
    spawn(function()
        while wait(5) do
            pcall(function()
                LocalPlayer.RespawnTime = 999999
            end)
        end
    end)
end

-- 监听角色死亡
local function SetupDeathListener()
    LocalPlayer.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        
        humanoid.Died:Connect(function()
            -- 角色死亡时设置极长重生时间
            SetInfiniteRespawnTime()
            
            -- 防止角色被移除
            pcall(function()
                character:SetAttribute("PreventRemoval", true)
            end)
        end)
    end)
end

-- 初始化
SetInfiniteRespawnTime()
SetupDeathListener()

print("永久死亡模式已启用 - 重生时间设置为999999秒")
