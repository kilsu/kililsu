-- 强制阻止重生脚本
-- 功能: 直接阻止角色重生，无视游戏的重生机制

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- 显示通知
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "阻止重生",
    Text = "脚本已加载，将阻止角色重生",
    Duration = 5,
})

print("强制阻止重生脚本已加载")

-- 拦截重生机制的核心方法
local function BlockRespawnAtCore()
    -- 获取游戏元表
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- 拦截所有可能的重生相关方法
        if method == "RequestCharacterSpawn" or 
           method == "RequestCharacterRespawn" or
           method == "RespawnCharacter" or
           method == "SpawnCharacter" or
           method == "LoadCharacter" then
            print("拦截重生请求: " .. method)
            return nil
        end
        
        return oldNamecall(self, ...)
    end)
    
    setreadonly(mt, true)
end

-- 持续阻止角色生成
local function ContinuousBlockRespawn()
    spawn(function()
        while wait(0.5) do
            -- 当角色不存在时，阻止任何生成尝试
            if not LocalPlayer.Character then
                -- 尝试多种方法阻止重生
                pcall(function()
                    -- 方法1: 拦截重生请求
                    BlockRespawnAtCore()
                end)
                
                -- 方法2: 尝试设置重生时间为极大值
                pcall(function()
                    if LocalPlayer.RespawnTime ~= nil then
                        LocalPlayer.RespawnTime = 999999
                    end
                end)
                
                -- 方法3: 通过属性设置
                pcall(function()
                    LocalPlayer:SetAttribute("RespawnTime", 999999)
                end)
            end
        end
    end)
end

-- 监听角色死亡
local function SetupDeathListener()
    LocalPlayer.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        
        humanoid.Died:Connect(function()
            print("角色死亡，开始阻止重生")
            -- 角色死亡后立即开始阻止重生
            BlockRespawnAtCore()
            ContinuousBlockRespawn()
        end)
    end)
end

-- 初始化
BlockRespawnAtCore()
ContinuousBlockRespawn()
SetupDeathListener()

-- 如果已经有角色，也设置监听
if LocalPlayer.Character then
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.Died:Connect(function()
            print("角色死亡，开始阻止重生")
            BlockRespawnAtCore()
            ContinuousBlockRespawn()
        end)
    end
end

print("强制阻止重生系统已激活")
