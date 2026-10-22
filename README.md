# Power Control

Power Control là ứng dụng Flutter dành cho Nubia Neo 3 (Z2461). Ứng dụng có
hai nút Shutdown và Restart; cả hai yêu cầu Android mở menu nguồn để người
dùng tự chọn và xác nhận thao tác.

## Công nghệ

- Flutter và Dart cho giao diện.
- Kotlin, Flutter `MethodChannel` và Android `AccessibilityService` cho phần
  tích hợp hệ thống.
- Logo launcher Android lấy từ `assets/user_app_icon.webp`; thay ảnh này rồi
  chạy `dart run flutter_launcher_icons` để tạo lại bộ icon.
- Ứng dụng hoạt động offline, không có tài khoản, server, API hay thu thập dữ
  liệu.

## Yêu cầu phát triển

- Flutter stable và Dart tương thích với ràng buộc SDK trong `pubspec.yaml`.
- Android Studio/Android SDK và Android SDK licenses đã được chấp nhận.
- JDK tương thích với Gradle/Android Gradle Plugin của dự án.
- Nubia Neo 3 Z2461 dùng Android 64-bit ARM; cấu hình APK chỉ đóng gói ABI
  `arm64-v8a` để tránh mang theo mã native cho emulator/thiết bị khác.

Mở thư mục `Restart` bằng Android Studio hoặc VS Code, sau đó chạy:

```sh
flutter pub get
flutter analyze
flutter test
```

## Build APK

```sh
flutter build apk --debug
flutter build apk --release --target-platform android-arm64
```

APK được tạo tại:

- `build/app/outputs/flutter-apk/app-debug.apk`
- `build/app/outputs/flutter-apk/app-release.apk`

APK release bật R8 và resource shrinking. Chỉ cần cài APK release trên Z2461;
APK debug lớn hơn đáng kể và chỉ dành cho phát triển. APK chỉ hỗ trợ thiết bị
Android ARM64, không cài được trên thiết bị 32-bit hoặc emulator x86.

Release hiện dùng debug signing. Trước khi phân phối rộng rãi hoặc đưa lên cửa
hàng, hãy cấu hình keystore phát hành riêng và bảo vệ khóa ký.

## Cài đặt trên Nubia Neo 3

1. Build APK, rồi chuyển file APK sang điện thoại bằng cách phù hợp, chẳng hạn
   tải qua cáp hoặc lưu vào bộ nhớ thiết bị. Không cần kết nối máy tính sau khi
   đã cài ứng dụng.
2. Mở APK trên điện thoại và cho phép cài ứng dụng từ nguồn tương ứng nếu
   Android yêu cầu.
3. Mở **Power Control**. Khi dịch vụ chưa được bật, chạm **Bật quyền Trợ năng**.
4. Trong Cài đặt Android, tìm **Power Control** trong danh sách dịch vụ Trợ năng,
   bật dịch vụ và xác nhận cảnh báo do Android hiển thị.
5. Quay lại ứng dụng. Trạng thái sẽ được kiểm tra lại khi ứng dụng hoạt động
   trở lại.
6. Nhấn **Shutdown** hoặc **Restart**. Khi menu nguồn xuất hiện, tự chọn
   **Power off** hoặc **Restart** (tên có thể khác tùy ngôn ngữ/firmware) và
   xác nhận trên điện thoại.

Ứng dụng không tự nhấn lựa chọn trong menu hệ thống. Hai nút cùng mở một menu
nguồn Android; chúng không trực tiếp tắt hoặc khởi động lại thiết bị.

## Quyền và giới hạn Android

Ứng dụng không root và không yêu cầu quyền `REBOOT`, Device Administrator,
danh bạ, vị trí, SMS, micro hoặc camera. Android không cho ứng dụng thông
thường tự tắt hoặc khởi động lại thiết bị. Accessibility Service chỉ được dùng
để gọi `GLOBAL_ACTION_POWER_DIALOG` sau khi người dùng tự bật quyền trong Cài
đặt Android. Dịch vụ không truy xuất nội dung cửa sổ và không tự điều khiển menu.

Nubia có thể tùy biến Android/firmware hoặc giới hạn hành động Trợ năng. Nếu
dịch vụ không kết nối hoặc firmware từ chối mở menu, ứng dụng sẽ báo lỗi thay
vì báo thành công giả. Khả năng tương thích cụ thể với Android trên Nubia Neo 3
cần được xác nhận trên thiết bị thật; dự án không giả định trước phiên bản
Android.

## Kiểm thử và khắc phục lỗi

- `flutter analyze`: kiểm tra lỗi và cảnh báo Dart.
- `flutter test`: kiểm thử trạng thái, hai nút, hướng dẫn bật quyền, lỗi native
  và chống gửi thao tác lặp.
- Sau khi cài APK, kiểm tra trong **Cài đặt > Trợ năng** rằng dịch vụ
  **Power Control** đã được bật. Tên/đường dẫn mục cài đặt có thể khác theo
  phiên bản Android.
- Nếu ứng dụng báo dịch vụ chưa kết nối, tắt rồi bật lại dịch vụ Trợ năng và mở
  lại ứng dụng.
- Nếu `flutter build apk` báo thiếu license, chạy `flutter doctor
  --android-licenses`, chấp nhận các license cần thiết, rồi thử build lại.
- Kiểm thử hành vi menu nguồn trên Nubia Neo 3 thực tế. Emulator chỉ xác nhận
  được build và logic ứng dụng, không chứng minh hành vi của firmware Nubia.
