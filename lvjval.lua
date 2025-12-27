-- 🕵️ UI 结构解剖器 (找出 UUID 藏在界面的哪里)
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- 创建屏幕显示
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.CoreGui
local frame = Instance.new("ScrollingFrame")
frame.Size = UDim2.new(0.9, 0, 0.6, 0)
frame.Position = UDim2.new(0.05, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.Parent = screenGui
local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, 0, 0, 3000)
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.TextYAlignment = Enum.TextYAlignment.Top
textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
textLabel.Text = "⏳ 正在扫描 UI，请打开商店界面..."
textLabel.Parent = frame

local function log(msg) textLabel.Text = textLabel.Text .. "\n" .. msg end

-- 扫描逻辑
wait(2) -- 等你打开商店
log("🚀 开始扫描 PlayerGui...")

local pGui = player:FindFirstChild("PlayerGui")
if pGui then
    -- 遍历所有界面
    for _, gui in pairs(pGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            -- 寻找看起来像商品格子的东西 (通常包含 Price 或 Buy 按钮)
            for _, v in pairs(gui:GetDescendants()) do
                -- 特征1: 有个按钮叫 "Buy" 或者 "Purchase"
                if (v:IsA("TextButton") or v:IsA("ImageButton")) and (v.Name == "Buy" or v.Name == "Purchase") then
                    log("--------------------------------")
                    log("🔎 发现购买按钮所属界面: " .. gui.Name)
                    local itemFrame = v.Parent -- 按钮的父级通常是商品格子
                    log("📦 格子名字: " .. itemFrame.Name)
                    
                    -- 看看属性里有没有藏 UUID
                    local attrs = itemFrame:GetAttributes()
                    for attrName, attrValue in pairs(attrs) do
                        log("   🏷️ 属性: " .. attrName .. " = " .. tostring(attrValue))
                    end
                    
                    -- 看看子物体有没有 UUID
                    for _, child in pairs(itemFrame:GetChildren()) do
                         if child:IsA("StringValue") then
                             log("   📄 StringValue: " .. child.Name .. " = " .. child.Value)
                         end
                    end
                end
            end
        end
    end
else
    log("❌ 找不到 PlayerGui")
end
log("🏁 扫描结束，请截图！")
