local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- 路径之前已经确认过是正确的
local knitPath = ReplicatedStorage.Packages._Index["sleitnick_knit@1.5.1"]
local P2P_Get = knitPath.knit.Services.P2PService.RF.Get

print(">>> 正在尝试调用 Get 获取列表...")

-- 安全调用 Get 功能
local success, result = pcall(function()
    -- 尝试发送空参数，绝大多数 Get 功能不需要参数
    return P2P_Get:InvokeServer()
end)

if success then
    print(">>> 调用成功！正在分析数据...")
    
    -- 检查返回的是不是一个列表
    if type(result) == "table" then
        -- 获取第一个商品的数据来看看长什么样
        local firstItem = nil
        for k, v in pairs(result) do
            firstItem = v
            break -- 只需要看第一个就够了
        end
        
        if firstItem then
            print(">>> 成功抓取到商品数据结构！")
            
            -- 把这个商品的所有属性打印出来
            local info = ""
            for key, value in pairs(firstItem) do
                info = info .. key .. ": " .. tostring(value) .. "\n"
            end
            
            print(info) -- 在控制台打印详细信息
            
            -- 弹窗提示关键信息
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "数据抓取成功！";
                Text = "请查看控制台(F9)或截图发给Gemini";
                Duration = 10;
            })
            
            -- 如果你能看到屏幕上的字，把下面这段显示的 Key 名字记下来告诉我
            -- 比如看到 "ListingID: 5aab..." 或者 "Price: 100"
            
        else
            warn("列表是空的，可能当前没人卖东西？")
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "列表为空";
                Text = "当前市场上好像没有商品？";
                Duration = 5;
            })
        end
    else
        warn("返回的不是表格，是：" .. tostring(result))
    end
else
    warn("调用失败，错误信息：" .. tostring(result))
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "调用出错";
        Text = "请查看控制台错误信息";
        Duration = 5;
    })
end
