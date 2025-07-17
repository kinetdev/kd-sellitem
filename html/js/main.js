$(function() {
    // Biến toàn cục
    let itemsData = [];
    let currentItem = null;
    let categories = ['all'];
    let selectedCategory = 'all';
    let currentPrices = {};
    let isVisible = false;
    
    console.log('KD Sell Item UI initialized');
    
    // Debug helper - Hiển thị UI trong trình duyệt (cho trường hợp test)
    if (window.location.hash === '#debug') {
        console.log('Debug mode activated');
        
        // Tạo dữ liệu mẫu
        const sampleItems = [
            {
                name: "rice",
                label: "Gạo",
                basePrice: 50,
                category: "nong_san",
                fluctuationEnabled: true,
                image: "https://i.imgur.com/fZ9SzQZ.jpeg"
            },
            {
                name: "gold",
                label: "Vàng",
                basePrice: 1000,
                category: "khoang_san",
                fluctuationEnabled: true,
                image: "https://i.imgur.com/LBUXcB1.jpeg"
            },
            {
                name: "wood",
                label: "Gỗ",
                basePrice: 80,
                category: "lam_san",
                fluctuationEnabled: true,
                image: "https://i.imgur.com/kR3XKRM.jpeg"
            }
        ];
        
        // Tự mở UI với dữ liệu mẫu
        itemsData = sampleItems;
        categories = ['all', 'nong_san', 'khoang_san', 'lam_san'];
        sampleItems.forEach(item => {
            currentPrices[item.name] = item.basePrice;
        });
        
        $('#zone-name').text('DEBUG MODE');
        populateCategories();
        filterItems();
        $('#main-container').css('display', 'flex');
        isVisible = true;
    }

    // Event listener để nhận dữ liệu từ client script
    window.addEventListener('message', function(event) {
        const data = event.data;
        
        console.log('Message received:', data.type);
        
        if (data.type === 'openUI') {
            console.log('Opening UI with data:', data);
            // Nhận dữ liệu
            itemsData = data.items || [];
            currentPrices = data.prices || {};
            categories = ['all'].concat(data.categories || []);
            
            console.log('Items:', itemsData.length);
            console.log('Categories:', categories);
            
            // Cập nhật tên khu vực
            $('#zone-name').text(data.zoneName || 'Bán Vật Phẩm');
            
            // Khởi tạo giao diện
            populateCategories();
            filterItems();
            
            // Hiển thị UI
            $('#main-container').css('display', 'flex');
            console.log('UI should be visible now');
            isVisible = true;
        } else if (data.type === 'closeUI') {
            console.log('Closing UI');
            // Đóng UI
            $('#main-container').hide();
            isVisible = false;
        } else if (data.type === 'updatePrices') {
            console.log('Updating prices');
            // Cập nhật giá
            currentPrices = data.prices || {};
            // Cập nhật lại UI nếu đang hiển thị
            if (isVisible) {
                filterItems();
            }
        }
    });

    // Xử lý đóng UI
    $('#close-btn').click(function() {
        console.log('Close button clicked');
        closeUI();
    });

    // Đóng UI và gửi thông báo đến client script
    function closeUI() {
        $('#main-container').hide();
        isVisible = false;
        console.log('Sending closeUI event to server');
        $.post('https://kd-sellitem/closeUI', JSON.stringify({}));
    }

    // Xử lý đóng modal
    $('#close-modal, #cancel-btn').click(function() {
        closeModal();
    });

    // Đóng modal bán vật phẩm
    function closeModal() {
        $('#sell-modal').hide();
    }

    // Xử lý nút xác nhận bán
    $('#confirm-btn').click(function() {
        if (!currentItem) return;
        
        const amount = parseInt($('#amount-input').val()) || 0;
        if (amount <= 0) return;
        
        const itemName = currentItem.name;
        const price = currentPrices[itemName] || currentItem.basePrice;
        
        // Gửi dữ liệu bán về client script
        $.post('https://kd-sellitem/sellItem', JSON.stringify({
            item: itemName,
            amount: amount,
            price: price,
            totalPrice: amount * price
        }));
        
        // Đóng modal
        closeModal();
    });

    // Xử lý nút tăng số lượng
    $('#increase-amount').click(function() {
        const currentAmount = parseInt($('#amount-input').val()) || 0;
        $('#amount-input').val(currentAmount + 1);
        updateTotalPrice();
    });

    // Xử lý nút giảm số lượng
    $('#decrease-amount').click(function() {
        const currentAmount = parseInt($('#amount-input').val()) || 0;
        if (currentAmount > 1) {
            $('#amount-input').val(currentAmount - 1);
            updateTotalPrice();
        }
    });

    // Xử lý thay đổi số lượng
    $('#amount-input').on('input', function() {
        updateTotalPrice();
    });

    // Cập nhật tổng giá
    function updateTotalPrice() {
        if (!currentItem) return;
        
        const amount = parseInt($('#amount-input').val()) || 0;
        const price = currentPrices[currentItem.name] || currentItem.basePrice;
        const total = amount * price;
        
        $('#modal-total-price').text(total);
    }

    // Hiển thị modal bán vật phẩm
    function openSellModal(itemName) {
        // Tìm thông tin vật phẩm
        currentItem = itemsData.find(item => item.name === itemName);
        
        if (!currentItem) return;
        
        // Lấy giá hiện tại
        const currentPrice = currentPrices[itemName] || currentItem.basePrice;
        
        // Tạo chỉ báo biến động giá
        let fluctuation = '';
        if (currentPrices[itemName] && currentItem.fluctuationEnabled) {
            const diff = currentPrices[itemName] - currentItem.basePrice;
            const percentChange = Math.floor((diff / currentItem.basePrice) * 100);
            
            if (percentChange > 0) {
                fluctuation = `<span class="item-fluctuation up">(↑${percentChange}%)</span>`;
            } else if (percentChange < 0) {
                fluctuation = `<span class="item-fluctuation down">(↓${Math.abs(percentChange)}%)</span>`;
            }
        }
        
        // Cập nhật nội dung modal
        $('#modal-item-name').text(currentItem.label);
        $('#modal-item-label').text(currentItem.label);
        $('#modal-item-price').text(currentPrice);
        $('#modal-item-fluctuation').html(fluctuation);
        $('#modal-item-image').attr('src', currentItem.image);
        $('#amount-input').val(1);
        updateTotalPrice();
        
        // Hiển thị modal
        $('#sell-modal').css('display', 'flex');
    }

    // Tạo các tab danh mục
    function populateCategories() {
        // Xóa các tab hiện tại trừ tab "Tất cả"
        $('#category-tabs').html('<button class="category-tab active" data-category="all"><span>Tất cả</span></button>');
        
        // Thêm các danh mục vào tab
        categories.forEach(category => {
            if (category !== 'all') {
                let categoryName = category;
                // Map danh mục sang tên tiếng Việt
                switch(category) {
                    case 'nong_san': categoryName = 'Nông Sản'; break;
                    case 'khoang_san': categoryName = 'Khoáng Sản'; break;
                    case 'lam_san': categoryName = 'Lâm Sản'; break;
                    case 'thu': categoryName = 'Thú'; break;
                }
                $('#category-tabs').append(`<button class="category-tab" data-category="${category}"><span>${categoryName}</span></button>`);
            }
        });
        
        // Xử lý sự kiện click cho các tab
        $('.category-tab').click(function() {
            $('.category-tab').removeClass('active');
            $(this).addClass('active');
            
            selectedCategory = $(this).data('category');
            filterItems();
        });
    }

    // Lọc vật phẩm theo danh mục
    function filterItems() {
        // Lọc theo danh mục đã chọn
        const filteredItems = itemsData.filter(item => {
            return selectedCategory === 'all' || item.category === selectedCategory;
        });
        
        // Cập nhật UI
        populateItems(filteredItems);
    }

    // Hiển thị danh sách vật phẩm
    function populateItems(items) {
        $('#items-container').empty();
        
        // Tạo 15 ô trống (lưới 5x3)
        for (let i = 0; i < 15; i++) {
            $('#items-container').append(`<div class="item-card" style="visibility: hidden;"></div>`);
        }
        
        // Thay thế các ô trống bằng vật phẩm thực
        items.forEach((item, index) => {
            if (index < 15) { // Chỉ hiển thị tối đa 15 vật phẩm
                // Lấy giá hiện tại cho vật phẩm
                const currentPrice = currentPrices[item.name] || item.basePrice;
                
                // Tạo chỉ báo biến động giá nếu có
                let fluctuation = '';
                if (currentPrices[item.name] && item.fluctuationEnabled) {
                    const diff = currentPrices[item.name] - item.basePrice;
                    const percentChange = Math.floor((diff / item.basePrice) * 100);
                    
                    if (percentChange > 0) {
                        fluctuation = `<span class="item-fluctuation up">(↑${percentChange}%)</span>`;
                    } else if (percentChange < 0) {
                        fluctuation = `<span class="item-fluctuation down">(↓${Math.abs(percentChange)}%)</span>`;
                    }
                }
                
                // Tạo HTML cho thẻ vật phẩm
                const itemCard = `
                    <div class="item-card" data-item="${item.name}">
                        <div class="item-image-container">
                            <img src="${item.image}" alt="${item.label}" class="item-image">
                        </div>
                        <div class="item-name">${item.label}</div>
                        <div class="item-price">$${currentPrice} ${fluctuation}</div>
                    </div>
                `;
                
                // Thay thế ô trống
                $('#items-container').children().eq(index).replaceWith(itemCard);
            }
        });
        
        // Thêm sự kiện click cho các vật phẩm
        $('.item-card').each(function() {
            if ($(this).attr('data-item')) {
                $(this).click(function() {
                    const itemName = $(this).data('item');
                    openSellModal(itemName);
                });
            }
        });
    }

    // Hỗ trợ bàn phím để tắt UI khi nhấn ESC
    document.addEventListener('keyup', function(event) {
        if (event.key === 'Escape') {
            if ($('#sell-modal').css('display') === 'flex') {
                closeModal();
            } else if (isVisible) {
                closeUI();
            }
        }
    });
});