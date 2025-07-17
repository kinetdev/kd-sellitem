Config = {}

-- Thời gian update giá (phút)
Config.PriceUpdateInterval = 30

-- Mức dao động giá tối đa (%)
Config.MaxPriceFluctuation = 20

-- Các điểm bán hàng
Config.SellZones = {
    ["black-market"] = {
        name = "CHỢ ĐẦU MỐI",
        blip = {
            enable = true,
            sprite = 478,
            color = 5,
            scale = 0.8,
            name = "Chợ Đầu Mối"
        },
        marker = {
            type = 1,
            size = {x = 1.5, y = 1.5, z = 1.0},
            color = {r = 0, g = 180, b = 250, a = 100}
        },
        position = vector3(1236.4, -3003.3, 9.3),
        categories = {'thu', 'lam_san', 'nong_san', 'khoang_san'}
    },
    ["pawn-shop"] = {
        name = "Tiệm Cầm Đồ",
        blip = {
            enable = true,
            sprite = 272,
            color = 5,
            scale = 0.7,
            name = "Tiệm Cầm Đồ"
        },
        marker = {
            type = 1,
            size = {x = 1.5, y = 1.5, z = 1.0},
            color = {r = 255, g = 165, b = 0, a = 100}
        },
        position = vector3(177.4, -1630.3, 29.4),
        categories = {'nong_san', 'khoang_san'}
    }
}

-- Danh mục sản phẩm
Config.Categories = {
    ['all'] = 'Tất cả',
    ['nong_san'] = 'Nông Sản',
    ['khoang_san'] = 'Khoáng Sản',
    ['lam_san'] = 'Lâm Sản',
    ['thu'] = 'Thú'
}

-- Danh sách sản phẩm
Config.Items = {
    -- Nông sản
    {
        name = "rice",
        label = "Gạo",
        basePrice = 50,
        category = "nong_san",
        fluctuationEnabled = true,
        image = "https://i.imgur.com/fZ9SzQZ.jpeg"
    },
    {
        name = "corn",
        label = "Bắp",
        basePrice = 30,
        category = "nong_san",
        fluctuationEnabled = true,
        image = "https://i.imgur.com/3r6jUP1.jpeg"
    },
    {
        name = "potato",
        label = "Khoai tây",
        basePrice = 20,
        category = "nong_san",
        fluctuationEnabled = true,
        image = "https://i.imgur.com/wHKoSwu.jpeg"
    },
    {
        name = "carrot",
        label = "Cà rốt",
        basePrice = 15,
        category = "nong_san",
        fluctuationEnabled = true,
        image = "https://i.imgur.com/1PX1JnI.jpeg"
    },
    {
        name = "tomato",
        label = "Cà chua",
        basePrice = 25,
        category = "nong_san",
        fluctuationEnabled = true,
        image = "https://i.imgur.com/c8Qdu9L.jpeg"
    },
    
    -- Khoáng sản
    {
        name = "gold",
        label = "Vàng",
        basePrice = 1000,
        category = "khoang_san",
        fluctuationEnabled = true,
        image = "https://i.imgur.com/LBUXcB1.jpeg"
    },
    {
        name = "diamond",
        label = "Kim cương",
        basePrice = 1500,
        category = "khoang_san",
        fluctuationEnabled = true,
        image = "https://i.imgur.com/MH9dlCl.jpeg"
    },
    {
        name = "iron",
        label = "Sắt",
        basePrice = 100,
        category = "khoang_san",
        fluctuationEnabled = true,
        image = "https://i.imgur.com/NrgLtOL.jpeg"
    },
    {
        name = "copper",
        label = "Đồng",
        basePrice = 80,
        category = "khoang_san",
        fluctuationEnabled = true,
        image = "https://i.imgur.com/uR9g0X7.jpeg"
    },
    
    -- Lâm sản
    {
        name = "wood",
        label = "Gỗ",
        basePrice = 80,
        category = "lam_san",
        fluctuationEnabled = true,
        image = "https://i.imgur.com/kR3XKRM.jpeg"
    },
    {
        name = "rubber",
        label = "Cao su",
        basePrice = 120,
        category = "lam_san",
        fluctuationEnabled = true,
        image = "https://i.imgur.com/WnEIbhX.jpeg"
    },
    {
        name = "bamboo",
        label = "Tre",
        basePrice = 50,
        category = "lam_san",
        fluctuationEnabled = true,
        image = "https://i.imgur.com/ItBOZVh.jpeg"
    },
    
    -- Thú
    {
        name = "beef",
        label = "Thịt bò",
        basePrice = 300,
        category = "thu",
        fluctuationEnabled = true,
        image = "https://i.imgur.com/C7CcYfE.jpeg"
    },
    {
        name = "chicken",
        label = "Gà",
        basePrice = 150,
        category = "thu",
        fluctuationEnabled = true,
        image = "https://i.imgur.com/6mSPkM0.jpeg"
    },
    {
        name = "leather",
        label = "Da thuộc",
        basePrice = 250,
        category = "thu",
        fluctuationEnabled = true,
        image = "https://i.imgur.com/MrCv2X9.jpeg"
    }
} 