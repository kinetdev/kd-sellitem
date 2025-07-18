# kd-sellitem - Bán Vật Phẩm

Resource đẹp và tương thích với ESX và QBCore cho phép người chơi bán các vật phẩm tại các điểm bán hàng trên bản đồ.

## Tính năng

- **Giao diện người dùng đẹp mắt** với hiệu ứng futuristic, viền sáng và animation
- **Hệ thống danh mục** giúp phân loại các vật phẩm
- **Dao động giá tự động** theo thời gian để tạo nền kinh tế năng động
- **Hỗ trợ cả ESX và QBCore**
- **Marker và Blip** được cấu hình dễ dàng
- **Tùy chỉnh đầy đủ** thông qua config.lua

## Cài đặt

1. Tải xuống và giải nén resource
2. Đặt thư mục `kd-sellitem` vào thư mục `resources` của server
3. Thêm `ensure kd-sellitem` vào server.cfg
4. Tùy chỉnh `config.lua` theo ý muốn
5. Khởi động lại server hoặc sử dụng lệnh `restart kd-sellitem`

## Cấu hình

Bạn có thể tùy chỉnh các thiết lập trong file `config.lua`:

- **Thời gian cập nhật giá** - Thời gian giữa các lần cập nhật giá (phút)
- **Biên độ dao động giá** - Mức dao động giá tối đa (%)
- **Các điểm bán hàng** - Thiết lập vị trí, blip, marker và danh mục cho phép
- **Danh mục** - Tên hiển thị cho các danh mục
- **Sản phẩm** - Danh sách sản phẩm với giá cơ bản và cài đặt dao động giá

## Command

- `/updateprices` - Cập nhật giá ngay lập tức (chỉ dành cho Admin)

## Ảnh chụp màn hình

![Giao diện bán vật phẩm](https://media.discordapp.net/attachments/1352180436381601872/1365200615734644827/image.png?ex=68793566&is=6877e3e6&hm=0ab7ba0990593ef8711d819d804d0945a6a0f501be5e6127799a4e240dd45745&=&format=webp&quality=lossless&width=1522&height=856)

## Hỗ trợ và Phát triển

Resource này được phát triển bởi KD Scripts. Nếu bạn gặp vấn đề, vui lòng tạo issue trên GitHub hoặc liên hệ qua Discord của chúng tôi.

Thông tin hỗ trợ và các resource khác có thể được tìm thấy trên website hoặc Discord của chúng tôi.

Discord https://discord.gg/UgGdpFz2hF

## License

MIT License - © KinetDev Scripts 
