# Common Widget Library

Thư viện widgets dùng chung cho các dự án Flutter, hỗ trợ tự động đồng bộ code vào dự án đích.

## Cấu trúc

- `bin/common_widget.dart`: Script xử lý việc đồng bộ code và đổi tên package dynamic.
- `lib/`: Chứa toàn bộ các widgets dùng chung.

## Cách sử dụng trong dự án mới

1. Thêm package vào `pubspec.yaml`:

```yaml
dependencies:
  common_widget:
    git:
      url: https://github.com/tuan-urani/common_widget
      ref: main
```

2. Chạy lệnh đồng bộ:

```bash
flutter pub get
dart run common_widget
```

- ## Nguyên tắc đồng bộ

- Toàn bộ nội dung trong `common_widget/lib/`  
  → được copy vào `Project/lib/src/ui/widgets/`

## Lưu ý cho người phát triển

- Khi trong lib này bạn muốn thêm mới 1 common component nào đó thì những chỗ import project bạn hãy dùng prefix `package:link_home/` thay thế cho dự án hiện tại trước khi push nó lên repository. Vì mọi import trong thư mục `lib/` nên sử dụng prefix `package:link_home/` để script có thể nhận diện và thay thế tự động khi đồng bộ sang dự án khác.

## Tạo Bottom Bar

Chạy tại thư mục gốc của dự án Flutter (nơi có `pubspec.yaml`):

```bash
dart run common_widget:common_bottom_bar --type standard --tabs home,user,settings
```

### Tham số

- `--type`:
  - `standard`: dạng không có nút ở giữa (không có Positioned button).
  - `top-notch`: dạng có nút ở giữa (có Positioned button).
- `--tabs`: danh sách tab, phân tách bằng dấu phẩy. Ví dụ: `home,user,settings`.

### Output

- `bottom_navigation_page.dart` → `Project/lib/src/enums/`
- Thư mục `main` (UI của bottom bar) → `Project/lib/src/ui/`
- Thư mục `routing` → `Project/lib/src/ui/`
