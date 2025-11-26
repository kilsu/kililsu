-- 阻止死亡重生脚本
-- 功能: 阻止角色死亡后的倒计时重生，让角色永远躺在地上

if _G.NoRespawnLoaded then return end
_G.NoRespawnLoaded = true

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 拦截重生请求
local function BlockRespawnRequests()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        
        -- 阻止所有重生相关请求
        if method == "RequestCharacterSpawn" or 
           method == "RequestCharacterRespawn" then
            return nil -- 直接返回nil，阻止重生
        end
        
        return oldNamecall(self, ...)
    end)
    
    setreadonly(mt, true)
end

-- 监听角色死亡
local function SetupDeathListener()
    LocalPlayer.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        
        humanoid.Died:Connect(function()
            -- 角色死亡时阻止重生
            BlockRespawnRequests()
            
            -- 防止角色被自动移除
            character:SetAttribute("PreventRemoval", true)
        end)
    end)
end

-- 初始化
BlockRespawnRequests()
SetupDeathListener()

print("死亡重生阻止已启用 - 角色死亡后将永远躺在地上")
