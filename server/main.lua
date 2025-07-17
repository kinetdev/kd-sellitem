local ESX = exports['es_extended']:getSharedObject()

local currentPrices = {}
local lastPriceUpdate = 0
local priceUpdateInterval = 60 * 30 -- 30 phút (trong giây)
local nextPriceUpdate = 0

-- Sự kiện khởi động resource
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    print('^2[KD SELLITEM] Đã khởi động thành công^0')
    
    -- Khởi tạo giá ban đầu
    UpdatePrices()
    
    -- Đặt lịch cập nhật giá tiếp theo
    nextPriceUpdate = os.time() + priceUpdateInterval
end)

-- Cập nhật giá theo chu kỳ
CreateThread(function()
    while true do
        Wait(60000) -- Kiểm tra mỗi phút
        
        -- Cập nhật giá nếu đến thời gian
        if os.time() >= nextPriceUpdate then
            UpdatePrices()
            nextPriceUpdate = os.time() + priceUpdateInterval
        end
    end
end)

-- Hàm cập nhật giá
function UpdatePrices()
    local newPrices = {}
    
    for _, item in ipairs(Config.Items) do
        if item.fluctuationEnabled then
            local fluctuation = math.random(-Config.MaxPriceFluctuation, Config.MaxPriceFluctuation) / 100
            newPrices[item.name] = math.floor(item.basePrice * (1 + fluctuation))
        else
            newPrices[item.name] = item.basePrice
        end
    end
    
    currentPrices = newPrices
    lastPriceUpdate = os.time()
    
    -- Thông báo cho tất cả người chơi
    TriggerClientEvent('kd-sellitem:client:updatePrices', -1, currentPrices)
    
    -- Ghi log
    print('^2[KD SELLITEM] Đã cập nhật giá vật phẩm^0')
end

-- Xử lý sự kiện bán vật phẩm
RegisterServerEvent('kd-sellitem:server:sellItem')
AddEventHandler('kd-sellitem:server:sellItem', function(itemName, amount, expectedPrice)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then
        TriggerClientEvent('esx:showNotification', source, 'Lỗi: Không thể tìm thấy thông tin người chơi')
        return
    end
    
    local item = xPlayer.getInventoryItem(itemName)
    if not item or item.count < amount then
        TriggerClientEvent('esx:showNotification', source, 'Bạn không có đủ vật phẩm này')
        return
    end
    
    -- Kiểm tra giá
    local currentPrice = currentPrices[itemName] or GetItemBasePrice(itemName)
    local totalPrice = currentPrice * amount
    
    -- Kiểm tra xem giá có khớp với kỳ vọng
    if math.abs(totalPrice - expectedPrice) > 10 then -- Cho phép chênh lệch nhỏ do làm tròn
        TriggerClientEvent('esx:showNotification', source, 'Giá đã thay đổi, vui lòng thử lại')
        return
    end
    
    -- Xử lý giao dịch
    xPlayer.removeInventoryItem(itemName, amount)
    xPlayer.addMoney(totalPrice)
    
    -- Thông báo cho người chơi
    TriggerClientEvent('esx:showNotification', source, 'Đã bán ' .. amount .. ' ' .. GetItemLabel(itemName) .. ' với giá $' .. totalPrice)
    
    -- Ghi log
    print('^2[KD SELLITEM] ' .. GetPlayerName(source) .. ' đã bán ' .. amount .. 'x ' .. itemName .. ' với giá $' .. totalPrice)
end)

-- Hàm lấy giá cơ bản của vật phẩm
function GetItemBasePrice(itemName)
    for _, item in ipairs(Config.Items) do
        if item.name == itemName then
            return item.basePrice
        end
    end
    return 0
end

-- Hàm lấy nhãn của vật phẩm
function GetItemLabel(itemName)
    for _, item in ipairs(Config.Items) do
        if item.name == itemName then
            return item.label
        end
    end
    return itemName
end

-- API để lấy giá hiện tại
ESX.RegisterServerCallback('kd-sellitem:server:getCurrentPrices', function(source, cb)
    cb(currentPrices)
end)

-- API để lấy thời gian cập nhật giá gần nhất
ESX.RegisterServerCallback('kd-sellitem:server:getLastPriceUpdate', function(source, cb)
    cb(lastPriceUpdate)
end)

-- API để cập nhật giá (dành cho quản trị viên)
ESX.RegisterServerCallback('kd-sellitem:server:forceUpdatePrices', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() == 'admin' then
        UpdatePrices()
        cb(true)
    else
        cb(false)
    end
end)

-- Lệnh để mở giao diện bán hàng (để kiểm tra)
RegisterCommand('banvatpham', function(source, args)
    local src = source
    local zone = args[1] or "black-market"
    
    TriggerClientEvent('kd-sellitem:client:openUI', src, zone)
end)

-- Lệnh để cập nhật giá thị trường (chỉ dành cho admin)
RegisterCommand('capnhatgia', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() == 'admin' then
        UpdatePrices()
        TriggerClientEvent('esx:showNotification', source, 'Đã cập nhật giá thị trường')
    else
        TriggerClientEvent('esx:showNotification', source, 'Bạn không có quyền sử dụng lệnh này')
    end
end)

-- Lệnh kiểm tra đường dẫn resource (server-side)
RegisterCommand('kdcheckserver', function(source)
    local resourcePath = GetResourcePath(GetCurrentResourceName())
    
    -- Kiểm tra các thư mục quan trọng
    local htmlPath = resourcePath .. "/html"
    local cssPath = resourcePath .. "/html/css"
    local jsPath = resourcePath .. "/html/js"
    local imgPath = resourcePath .. "/html/img"
    
    -- Log thông tin vào console
    print("^2[KD SELLITEM] Resource path: " .. resourcePath .. "^0")
    print("^2[KD SELLITEM] HTML path: " .. htmlPath .. "^0")
    print("^2[KD SELLITEM] CSS path: " .. cssPath .. "^0")
    print("^2[KD SELLITEM] JS path: " .. jsPath .. "^0")
    print("^2[KD SELLITEM] IMG path: " .. imgPath .. "^0")
    
    -- Kiểm tra CSS file
    local cssFile = io.open(cssPath .. "/style.css", "r")
    if cssFile then
        print("^2[KD SELLITEM] style.css tồn tại và có thể đọc^0")
        cssFile:close()
    else
        print("^1[KD SELLITEM] style.css không tồn tại hoặc không thể đọc^0")
    end
    
    -- Kiểm tra JS file
    local jsFile = io.open(jsPath .. "/main.js", "r")
    if jsFile then
        print("^2[KD SELLITEM] main.js tồn tại và có thể đọc^0")
        jsFile:close()
    else
        print("^1[KD SELLITEM] main.js không tồn tại hoặc không thể đọc^0")
    end
    
    -- Thông báo cho người chơi
    if source > 0 then
        TriggerClientEvent('esx:showNotification', source, 'Đã kiểm tra đường dẫn resource. Xem F8 console để biết chi tiết.')
    end
end, true)

-- Lệnh để tạo file test HTML
RegisterCommand('kdcreatedebug', function(source)
    local resourcePath = GetResourcePath(GetCurrentResourceName())
    local htmlPath = resourcePath .. "/html"
    
    -- Tạo file debug.html
    local debugFile = io.open(htmlPath .. "/debug.html", "w")
    
    if debugFile then
        local content = [[
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KD Bán Vật Phẩm (Debug)</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://kit.fontawesome.com/a076d05399.js" crossorigin="anonymous"></script>
    <link rel="stylesheet" href="css/style.css">
    <style>
        /* CSS dự phòng nếu file style.css không hoạt động */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Arial, sans-serif;
            color: white;
        }
        
        body {
            width: 100vw;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            background-color: rgba(0, 0, 0, 0.5);
            overflow: hidden;
        }
        
        .container {
            width: 800px;
            background-color: rgba(10, 15, 25, 0.95);
            display: flex;
            flex-direction: column;
            color: #fff;
            border: 1px solid #00b4fa;
            box-shadow: 0 0 10px rgba(0, 180, 250, 0.5);
        }
    </style>
</head>
<body>
    <div class="container" id="main-container">
        <div class="header">
            <h1 id="zone-name">Bán Vật Phẩm (Debug)</h1>
            <div class="close-btn" id="close-btn">
                <i class="fas fa-times"></i>
            </div>
        </div>
        
        <div class="category-tabs" id="category-tabs">
            <!-- Categories will be added dynamically via JS -->
            <button class="category-tab active" data-category="all"><span>Tất cả</span></button>
        </div>
        
        <div class="items-container" id="items-container">
            <!-- Items will be added dynamically via JS -->
        </div>
    </div>
    
    <!-- Sell modal -->
    <div class="modal" id="sell-modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2><span id="modal-item-name">Vật phẩm</span></h2>
                <div class="close-modal" id="close-modal">
                    <i class="fas fa-times"></i>
                </div>
            </div>
            <div class="modal-body">
                <div class="modal-item-details">
                    <div class="modal-item-image-container">
                        <img id="modal-item-image" class="modal-item-image" src="" alt="Item Image">
                    </div>
                    <div class="modal-item-info">
                        <div class="modal-item-label" id="modal-item-label">Tên vật phẩm</div>
                        <div class="modal-item-price">Giá: $<span id="modal-item-price">0</span></div>
                        <div class="modal-item-price">Biến động: <span id="modal-item-fluctuation"></span>
                        </div>
                    </div>
                </div>
                
                <div class="amount-selector">
                    <button class="amount-btn" id="decrease-amount">-</button>
                    <input type="number" id="amount-input" min="1" value="1">
                    <button class="amount-btn" id="increase-amount">+</button>
                </div>
                
                <div class="total-price-container">
                    <div class="total-price-label">Tổng tiền :</div>
                    <div class="total-price-value"><span id="modal-total-price">0</span></div>
                </div>
            </div>
            <div class="modal-footer">
                <button id="cancel-btn">Hủy bỏ</button>
                <button id="confirm-btn">Xác nhận bán</button>
            </div>
        </div>
    </div>
    
    <script src="js/main.js"></script>
    <script>
        // Thêm hash để kích hoạt chế độ debug
        window.location.hash = 'debug';
    </script>
</body>
</html>
]]
        
        debugFile:write(content)
        debugFile:close()
        
        print("^2[KD SELLITEM] Đã tạo file debug.html tại " .. htmlPath .. "/debug.html" .. "^0")
        print("^2[KD SELLITEM] Mở file này trong trình duyệt để xem UI ngoài game^0")
        
        if source > 0 then
            TriggerClientEvent('esx:showNotification', source, 'Đã tạo file debug.html. Xem F8 console để biết chi tiết.')
        end
    else
        print("^1[KD SELLITEM] Không thể tạo file debug.html^0")
        
        if source > 0 then
            TriggerClientEvent('esx:showNotification', source, 'Không thể tạo file debug.html.')
        end
    end
end, true) 