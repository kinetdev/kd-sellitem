local ESX = exports['es_extended']:getSharedObject()
local display = false
local currentZone = nil

local currentPrices = {}
local currentBlips = {}
local priceUpdateTime = 0

-- Khởi tạo giá ban đầu
CreateThread(function()
    -- Đặt giá trị ban đầu cho priceUpdateTime
    priceUpdateTime = GetGameTimer() 
    
    -- Lấy giá từ server
    ESX.TriggerServerCallback('kd-sellitem:server:getCurrentPrices', function(prices)
        if prices then
            currentPrices = prices
            print("^2[DEBUG] Đã nhận giá từ server^0")
        else
            print("^1[DEBUG] Không nhận được giá từ server^0")
        end
    end)
end)

-- Create markers and blips
CreateThread(function()
    print("^2[DEBUG] Đang tạo blips và markers^0")
    -- Kiểm tra Config
    if not Config or not Config.SellZones then
        print("^1[DEBUG] Lỗi: Không tìm thấy Config.SellZones^0")
        return
    end
    
    print("^2[DEBUG] Số điểm bán: " .. #Config.SellZones .. "^0")
    
    for zoneId, zone in pairs(Config.SellZones) do
        print("^2[DEBUG] Đang xử lý zone: " .. zoneId .. "^0")
        if zone.blip and zone.blip.enable then
            local blip = AddBlipForCoord(zone.position.x, zone.position.y, zone.position.z)
            SetBlipSprite(blip, zone.blip.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, zone.blip.scale)
            SetBlipColour(blip, zone.blip.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(zone.blip.name)
            EndTextCommandSetBlipName(blip)
            table.insert(currentBlips, blip)
            print("^2[DEBUG] Đã tạo blip cho zone: " .. zoneId .. "^0")
        end
    end
    
    -- Wait for resource to be loaded
    while not priceUpdateTime do
        Wait(100)
    end
    
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local sleep = 1000
        
        for zoneId, zone in pairs(Config.SellZones) do
            local distance = #(playerCoords - zone.position)
            
            if distance < 10.0 then
                sleep = 0
                if distance < 1.5 then
                    currentZone = zoneId
                    print("^2[DEBUG] Người chơi trong zone: " .. zoneId .. "^0")
                    
                    BeginTextCommandDisplayHelp('STRING')
                    AddTextComponentSubstringPlayerName('Nhấn ~INPUT_CONTEXT~ để bán vật phẩm')
                    EndTextCommandDisplayHelp(0, false, true, -1)
                    
                    if IsControlJustReleased(0, 38) then -- E key
                        print("^2[DEBUG] Mở UI bán vật phẩm^0")
                        SetDisplay(true)
                    end
                end
                
                if zone.marker then
                    DrawMarker(
                        zone.marker.type, 
                        zone.position.x, zone.position.y, zone.position.z - 0.95, 
                        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                        zone.marker.size.x, zone.marker.size.y, zone.marker.size.z, 
                        zone.marker.color.r, zone.marker.color.g, zone.marker.color.b, zone.marker.color.a, 
                        false, true, 2, false, nil, nil, false
                    )
                end
            end
        end
        
        Wait(sleep)
    end
end)

function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    print("^2[DEBUG] SetDisplay: " .. tostring(bool) .. "^0")
    
    if bool then
        DisableControlAction(0, 1, true) -- LookLeftRight
        DisableControlAction(0, 2, true) -- LookUpDown
        DisableControlAction(0, 142, true) -- MeleeAttackAlternate
        DisableControlAction(0, 18, true) -- Enter
        DisableControlAction(0, 322, true) -- ESC
        DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
    else
        EnableAllControlActions(0)
    end
    
    if bool then
        local itemsData = GetItemsForCurrentZone()
        local prices = GetCurrentPrices()
        
        print("^2[DEBUG] Số vật phẩm: " .. #itemsData .. "^0")
        print("^2[DEBUG] Tên khu vực: " .. GetZoneName() .. "^0")
        
        SendNUIMessage({
            type = "openUI",
            zoneName = GetZoneName(),
            items = itemsData,
            prices = prices,
            categories = GetCategoriesForZone()
        })
        print("^2[DEBUG] Đã gửi message openUI^0")
    else
        SendNUIMessage({
            type = "closeUI"
        })
        print("^2[DEBUG] Đã gửi message closeUI^0")
    end
end

function GetZoneName()
    if currentZone == "black-market" then
        return "CHỢ ĐẦU MỐI"
    elseif currentZone == "pawn-shop" then
        return "Tiệm Cầm Đồ"
    else
        return "Bán Vật Phẩm"
    end
end

function GetCategoriesForZone()
    if currentZone and Config.SellZones[currentZone] then
        return Config.SellZones[currentZone].categories
    else
        return {}
    end
end

function GetItemsForCurrentZone()
    local items = {}
    
    if not currentZone or not Config.SellZones[currentZone] then
        return items
    end
    
    local zoneCategories = Config.SellZones[currentZone].categories
    
    for _, item in ipairs(Config.Items) do
        for _, category in ipairs(zoneCategories) do
            if item.category == category then
                table.insert(items, item)
                break
            end
        end
    end
    
    return items
end

function GetCurrentPrices()
    local prices = {}
    local items = GetItemsForCurrentZone()
    
    for _, item in ipairs(items) do
        if item.fluctuationEnabled then
            local fluctuation = math.random(-20, 20) / 100
            prices[item.name] = math.floor(item.basePrice * (1 + fluctuation))
        else
            prices[item.name] = item.basePrice
        end
    end
    
    return prices
end

RegisterNUICallback('closeUI', function(data, cb)
    SetDisplay(false)
    cb('ok')
end)

RegisterNUICallback('sellItem', function(data, cb)
    local itemName = data.item
    local amount = data.amount
    local totalPrice = data.totalPrice
    
    TriggerServerEvent('kd-sellitem:server:sellItem', itemName, amount, totalPrice)
    
    cb('ok')
end)

RegisterNetEvent('kd-sellitem:client:openUI')
AddEventHandler('kd-sellitem:client:openUI', function(zone)
    currentZone = zone
    SetDisplay(true)
end)

RegisterNetEvent('kd-sellitem:client:updatePrices')
AddEventHandler('kd-sellitem:client:updatePrices', function(newPrices)
    if display then
        SendNUIMessage({
            type = "updatePrices",
            prices = newPrices
        })
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        -- Remove blips
        for _, blip in ipairs(currentBlips) do
            RemoveBlip(blip)
        end
        
        if display then
            SetDisplay(false)
        end
    end
end)

-- Thêm event handler cho thông báo từ server
RegisterNetEvent('kd-sellitem:client:notification')
AddEventHandler('kd-sellitem:client:notification', function(message, type)
    ESX.ShowNotification(message)
end)

-- Thêm lệnh để kiểm tra UI
RegisterCommand('kdtestui', function()
    print("^2[DEBUG] Mở UI bán vật phẩm qua lệnh TEST^0")
    currentZone = "black-market" -- Gán giá trị mặc định
    SetDisplay(true)
end, false)

-- Lệnh kiểm tra tài nguyên
RegisterCommand('kdcheckpath', function()
    print("^2[DEBUG] Kiểm tra resource: " .. GetCurrentResourceName() .. "^0")
    
    -- Kiểm tra hiện trạng NUI
    if display then
        print("^2[DEBUG] UI đang hiển thị^0")
    else
        print("^2[DEBUG] UI đang ẩn^0")
    end
    
    -- Kiểm tra Config
    if Config and Config.SellZones then
        print("^2[DEBUG] Config.SellZones có " .. #Config.SellZones .. " zones^0")
        for zoneId, _ in pairs(Config.SellZones) do
            print("^2[DEBUG] Zone: " .. zoneId .. "^0")
        end
    else
        print("^1[DEBUG] Config.SellZones không tồn tại^0")
    end
    
    -- Kiểm tra Blips
    print("^2[DEBUG] Số lượng blips: " .. #currentBlips .. "^0")
end, false) 