-- 💎 暴力可视版：全自动秒杀脚本 (类似你的视频界面)
-- 无需点击按钮，运行后直接看屏幕日志

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- ⚙️ 设置：最高价格 (钻石)
local MAX_PRICE = 5 

-- 1. 获取核心服务
local Services = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.5.1"):WaitForChild("knit"):WaitForChild("Services")
local P2P = Services:WaitForChild("P2PService")
local BuyFunc = P2P:WaitForChild("RF"):WaitForChild("Buy")

-- 2. 创建大屏日志 UI (类似你的视频)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoBuyLogUI"
if pcall(function() screenGui.Parent = CoreGui end) then else screenGui.Parent = player.PlayerGui end

local frame = Instance.new("ScrollingFrame")
frame.Name = "LogWindow"
frame.Size = UDim2.new(0.9, 0, 0.4, 0) -- 占据屏幕下方 40%
frame.Position = UDim2.new(0.05, 0, 0.55, 0) -- 放在下半部分
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.3
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(0, 255, 0)
frame.Parent = screenGui

local logLabel = Instance.new("TextLabel")
logLabel.Size = UDim2.new(1, -10, 0, 5000) -- 超长文本
logLabel.Position = UDim2.new(0, 5, 0, 0)
logLabel.BackgroundTransparency = 1
logLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- 绿色黑客风文字
logLabel.TextSize = 14
logLabel.Font = Enum.Font.Code
logLabel.TextXAlignment = Enum.TextXAlignment.Left
logLabel.TextYAlignment = Enum.TextYAlignment.Top
logLabel.Text = "🚀 脚本已启动！请打开任意商店界面..."
logLabel.Parent = frame

-- 日志函数 (自动滚动)
local function log(msg)
    local timeStr = os.date("%H:%M:%S")
    logLabel.Text = "[" .. timeStr .. "] " .. msg .. "\n" .. logLabel.Text
    -- 保持只显示最近的 50 行，防止卡顿
    if #logLabel.Text > 5000 then
        logLabel.Text = string.sub(logLabel.Text, 1, 5000)
    end
end

-- 3. 核心功能：找卖家 & 找商品

-- 寻找卖家 (自动匹配全服玩家)
local function findSeller(uiTitle)
    if not uiTitle then return nil end
    local cleanTitle = string.lower(uiTitle)
    for _, p in pairs(Players:GetPlayers()) do
        -- 只要标题里包含了这个人的名字，就认为是他在卖
        if string.find(cleanTitle, string.lower(p.Name)) or string.find(cleanTitle, string.lower(p.DisplayName)) then
            return p
        end
    end
    return nil
end

-- 提取 UUID
local function getUUID(item)
    for a, v in pairs(item:GetAttributes()) do
        if type(v) == "string" and #v == 36 then return v end
    end
    local tooltip = item:GetAttribute("TooltipData")
    if tooltip then
        local s, d = pcall(function() return HttpService:JSONDecode(tooltip) end)
        if s and d then return d.id or d.uuid or d.UniqueId end
    end
    return nil
end

-- 提取价格
local function getPrice(item)
    local p = item:GetAttribute("Price") or item:GetAttribute("Cost")
    if p then return tonumber(p) end
    local tooltip = item:GetAttribute("TooltipData")
    if tooltip then
        local s, d = pcall(function() return HttpService:JSONDecode(tooltip) end)
        if s and d and d.Price then return tonumber(d.Price) end
    end
    for _, v in pairs(item:GetDescendants()) do
        if v:IsA("TextLabel") and tonumber(v.Text) then return tonumber(v.Text) end
    end
    return 999999
end

-- 4. 主循环 (每秒执行)
task.spawn(function()
    while true do
        wait(0.5) -- 0.5秒刷新一次
        
        local pGui = player:FindFirstChild("PlayerGui")
        -- 尝试寻找商店界面 (MarketplaceBuy)
        local shopUI = pGui and pGui:FindFirstChild("MarketplaceBuy")
        
        if shopUI and shopUI.Enabled then
            -- A. 尝试获取卖家
            local frame = shopUI:FindFirstChild("Frame")
            local titleObj = frame and frame:FindFirstChild("Title")
            
            if not titleObj then
                log("⚠️ 警告：找不到标题 (Title)，无法识别卖家！")
            else
                local seller = findSeller(titleObj.Text)
                if not seller then
                    log("⚠️ 无法识别卖家: " .. titleObj.Text)
                else
                    -- B. 卖家确认，开始扫货
                    -- 只在状态变化时打印，防止刷屏
                    -- log("正在扫描 " .. seller.Name .. " 的商店...") 
                    
                    local container = frame and frame:FindFirstChild("Container")
                    local listings = container and container:FindFirstChild("Listings")
                    
                    if listings then
                        local foundCheap = false
                        for _, item in pairs(listings:GetChildren()) do
                            if item:IsA("Frame") or item:IsA("ImageButton") then
                                local price = getPrice(item)
                                local uuid = getUUID(item)
                                
                                -- ⚡ 发现便宜货
                                if price and price <= MAX_PRICE and price > 0 and uuid then
                                    log("🤑 发现目标！价格: " .. price)
                                    log("⚡ 正在向 " .. seller.Name .. " 购买...")
                                    
                                    -- 发送购买指令
                                    BuyFunc:InvokeServer(seller, uuid)
                                    foundCheap = true
                                end
                            end
                        end
                        
                        if not foundCheap then
                            -- 没货时，偶尔提示一下证明脚本活着
                            if math.random(1, 10) == 1 then
                                log("🔎 扫描中... 暂无 < " .. MAX_PRICE .. " 钻物品")
                            end
                        end
                    else
                        log("❌ 找不到商品列表 (Listings)")
                    end
                end
            end
        else
            -- 没打开商店时
            -- log("💤 等待打开商店界面...") 
        end
    end
end)
