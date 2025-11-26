-- 永久死亡脚本 - 完全阻止重生
-- 作者: 小皮
-- 功能: 角色死亡后永远躺在地上，不重生

if _G.PermanentDeathLoaded then
    return
end
_G.PermanentDeathLoaded = true

-- 服务引用
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 阻止重生系统
local function BlockRespawnCompletely()
    -- 拦截重生请求
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- 阻止所有重生相关的方法
        if method == "RequestCharacterSpawn" or 
           method == "RequestCharacterRespawn" or
           method == "RespawnCharacter" or
           method == "SpawnCharacter" then
            warn("阻止重生请求: " .. method)
            return nil
        end
        
        return oldNamecall(self, ...)
    end)
    
    setreadonly(mt, true)
end

-- 保持死亡状态
local function KeepCharacterDead()
    LocalPlayer.CharacterAdded:Connect(function(character)
        -- 立即杀死新生成的角色
        wait(0.1)
        
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            -- 确保角色保持死亡状态
            humanoid.Health = 0
            humanoid.MaxHealth = 0
            
            -- 阻止任何复活尝试
            humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                if humanoid.Health > 0 then
                    humanoid.Health = 0
                end
            end)
        end
        
        -- 防止角色被移除
        character:SetAttribute("PreventRemoval", true)
    end)
end

-- 设置初始死亡
local function SetupInitialDeath()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and rootPart then
            -- 监听死亡事件
            humanoid.Died:Connect(function()
                -- 角色死亡后，阻止任何重生
                spawn(function()
                    while true do
                        -- 持续阻止角色生成
                        if LocalPlayer.Character then
                            -- 确保角色保持死亡状态
                            local currentHumanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                            if currentHumanoid and currentHumanoid.Health > 0 then
                                currentHumanoid.Health = 0
                            end
                        else
                            -- 没有角色时，阻止重生请求
                            BlockRespawnCompletely()
                        end
                        wait(0.5)
                    end
                end)
            end)
            
            -- 如果角色还活着，强制死亡
            if humanoid.Health > 0 then
                humanoid.Health = 0
            end
        end
    end
end

-- 通知函数
local function ShowNotification(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 10,
    })
end

-- 初始化
wait(1)

-- 启用所有阻止机制
BlockRespawnCompletely()
KeepCharacterDead()
SetupInitialDeath()

ShowNotification("永久死亡模式", "已启用完全死亡模式\n角色将永远保持死亡状态")

print("永久死亡脚本已加载")
print("角色将永远保持死亡状态，不会重生")

-- 监控状态
spawn(function()
    while wait(5) do
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                humanoid.Health = 0
                print("检测到角色复活，已强制死亡")
            end
        else
            print("无角色状态 - 阻止重生中")
        end
    end
end)
