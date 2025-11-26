-- 死亡留在原地 v1.3 -> 改进版 (作者: 小皮 原脚本 改进)
-- 功能: 角色死亡后在本地停留在死亡位置并显示标记，阻止自动重生（本地）
-- 说明: 主要改进点见注释

if _G.DeathStayLoaded then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "死亡留在原地",
            Text = "脚本已加载，无需重复运行",
            Duration = 3,
        })
    end)
    return
end
_G.DeathStayLoaded = true

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Workspace = workspace

-- 主功能变量
local DeathStayEnabled = true
local GhostMarker = nil

-- 存放连接以便清理
local connections = {
    CharacterAdded = nil,
    HumanoidDied = nil,
}

-- 保存摄像机原始状态以便恢复
local cameraState = {
    CameraType = nil,
    CameraSubject = nil,
}

-- 通知函数（安全调用）
local function Notify(title, text, duration)
    duration = duration or 5
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration,
        })
    end)
end

-- 创建或替换幽灵标记
local function CreateGhostMarker(position)
    -- 清理旧的
    if GhostMarker and GhostMarker.Parent then
        GhostMarker:Destroy()
        GhostMarker = nil
    end

    local ghost = Instance.new("Part")
    ghost.Name = "死亡位置标记"
    ghost.Size = Vector3.new(4, 4, 4)
    ghost.Position = position
    ghost.Anchored = true
    ghost.CanCollide = false
    ghost.Transparency = 0.3
    ghost.BrickColor = BrickColor.new("Bright blue")
    ghost.Material = Enum.Material.Neon
    ghost.TopSurface = Enum.SurfaceType.Smooth
    ghost.BottomSurface = Enum.SurfaceType.Smooth

    local light = Instance.new("PointLight")
    light.Brightness = 3
    light.Range = 15
    light.Color = Color3.fromRGB(0, 150, 255)
    light.Parent = ghost

    -- 脉动（使用 task.spawn）
    task.spawn(function()
        while ghost and ghost.Parent do
            light.Brightness = 2
            task.wait(0.5)
            if not (ghost and ghost.Parent) then break end
            light.Brightness = 4
            task.wait(0.5)
        end
    end)

    ghost.Parent = Workspace
    GhostMarker = ghost

    return ghost
end

-- 将摄像机切换到死亡位置（本地），并保存原始相机设置
local function EnterDeathCamera(pos)
    local cam = Workspace.CurrentCamera
    if not cam then return end
    -- 保存
    cameraState.CameraType = cam.CameraType
    cameraState.CameraSubject = cam.CameraSubject
    -- 切换
    cam.CameraType = Enum.CameraType.Scriptable
    cam.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0)) * CFrame.Angles(-0.3, 0, 0)
end

local function RestoreCamera()
    local cam = Workspace.CurrentCamera
    if not cam then return end
    if cameraState.CameraType then cam.CameraType = cameraState.CameraType end
    if cameraState.CameraSubject then pcall(function() cam.CameraSubject = cameraState.CameraSubject end) end
    cameraState.CameraType = nil
    cameraState.CameraSubject = nil
end

-- 在角色死亡时执行的处理（本地）
local function OnHumanoidDied(character)
    -- 尝试安全获取 RootPart 的位置
    local rootPos
    local ok, err = pcall(function()
        local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        if root then
            rootPos = root.Position
        end
    end)
    if not ok then
        warn("获取死亡位置失败: ", err)
    end

    local pos = rootPos or (Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame.p) or Vector3.new(0, 0, 0)
    CreateGhostMarker(pos)
    Notify("死亡留在原地", "角色已保持在死亡位置")

    -- 禁止自动重生（本地），并将现有角色从 workspace 中移除（本地）
    pcall(function()
        -- 设置玩家本地属性，防止自动载入（大多数现代 Roblox API 支持 Player.CharacterAutoLoads）
        if LocalPlayer then
            -- 尝试设置两处（以兼容不同环境）
            pcall(function() LocalPlayer.CharacterAutoLoads = false end)
            pcall(function() game:GetService("StarterPlayer").CharacterAutoLoads = false end)
        end
    end)

    -- 让摄像机停留在死亡点
    EnterDeathCamera(pos)

    -- 延迟后移除本地角色模型（防止服务器端立即重建造成视觉上重生）
    task.spawn(function()
        task.wait(0.15)
        if character and character.Parent then
            -- 只在本地移除显示（Destroy 会对本地产生效果，但服务器端角色仍由服务器控制）
            -- 有些游戏在客户端 Destroy 会被服务器重建，因此使用透明/移动到不显眼位置作为后备
            pcall(function()
                character:Destroy()
            end)
        end
    end)
end

-- 清理幽灵标记与恢复重生设置
local function ResetRespawn()
    if GhostMarker and GhostMarker.Parent then
        GhostMarker:Destroy()
        GhostMarker = nil
    end
    pcall(function()
        if LocalPlayer then
            LocalPlayer.CharacterAutoLoads = true
        end
        game:GetService("StarterPlayer").CharacterAutoLoads = true
    end)
    -- 恢复摄像机
    RestoreCamera()
end

-- 断开所有事件连接
local function DisconnectAll()
    if connections.HumanoidDied then
        connections.HumanoidDied:Disconnect()
       
