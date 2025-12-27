-- 📱 手机专用：P2P 市场测试 (结果显示在屏幕上)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- 1. 创建手机端显示窗口
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileDebugUI"
if pcall(function() screenGui.Parent = CoreGui end) then else screenGui.Parent = Players.LocalPlayer.PlayerGui end

local frame = Instance.new("ScrollingFrame")
frame.Size = UDim2.new(0.8, 0, 0.6, 0) -- 占据屏幕大半
frame.Position = UDim2.new(0.1, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 3
frame.BorderColor3 = Color3.fromRGB(0, 255, 0)
frame.Parent = screenGui

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, 0, 0, 2000) -- 超长文本框
textLabel.Position = UDim2.new(0, 0, 0, 0)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.TextYAlignment = Enum.TextYAlignment.Top
textLabel.Font = Enum.Font.Code
textLabel.TextSize = 16
textLabel.Text = "⏳ 正在扫描 P2P 服务，请稍候..."
textLabel.Parent = frame

-- 辅助函数：更新屏幕文字
local function log(msg)
    textLabel.Text = textLabel.Text .. "\n" .. msg
    -- 同时也打印到官方控制台备用
    warn(msg) 
end

-- === 开始扫描 ===
log("🚀 脚本启动！寻找 P2PService...")

local Services = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.5.1"):WaitForChild("knit"):WaitForChild("Services")
local P2P = Services:WaitForChild("P2PService")
local RF = P2P:WaitForChild("RF")

log("✅ 找到 P2PService！正在测试函数...")

-- 尝试常见的函数名
local found = false
local targets = {"GetListings", "Get", "Fetch", "GetAll"}

for _, name in pairs(targets) do
    local func = RF:FindFirstChild(name)
    if func then
        log("🔎 发现函数: " .. name .. "，正在调用...")
        local success, result = pcall(function() return func:InvokeServer() end)
        
        if success then
            found = true
            log("✅ 调用成功！这是我们要找的！")
            log("📦 返回数据类型: " .. type(result))
            
            -- 打印出前几个商品看看
            if type(result) == "table" then
                log("📄 数据样本:")
                local count = 0
                for k, v in pairs(result) do
                    count = count + 1
                    if count <= 3 then -- 只显示前3个，防止刷屏
                         log("   ["..k.."] = " .. tostring(v))
                    end
                end
            end
            break -- 找到了就停止
        else
            log("❌ 调用失败: " .. name)
        end
    end
end

if not found then
    log("⚠️ 常用名都没找到，打印所有函数名：")
    for _, child in pairs(RF:GetChildren()) do
        log("   📄 " .. child.Name)
    end
end

log("🏁 扫描结束！请截图这个窗口！")
