# Tính năng đăng tài liệu

## Cấu trúc

`lib/features/post` dùng các lớp theo luồng auth hiện có:

```text
presentation/screens + widgets → Bloc → use case → repository
                                              → remote datasource → PostServices → Supabase
```

`PostBloc` quản lý form đăng bài. `PostsBloc` nằm trong app shell, quản lý danh sách
bài đăng trên trang chủ. Repository được tạo theo tài khoản đăng nhập và được thay
khi tài khoản thay đổi, để bản nháp không chuyển sang người dùng khác.

Tất cả lỗi dùng `Failure` từ `lib/core/error/failure.dart`; không có lớp Failure
riêng trong feature. Thuộc tính `code` tùy chọn giúp phân biệt trường hợp chưa
xác định được kết quả gửi bài với lỗi đã xác định, để giữ UUID khi cần thử lại.
Các luồng auth/profile vẫn dùng `Failure(message)` như trước.

## Thiết lập Supabase

1. Các bảng `sinh_vien`, `tai_lieu`, `tin_dang` phải có sẵn theo schema của dự án.
   `tailieu_id`, `tindang_id` cần giá trị tự sinh. `tin_dang` cần có
   `nguoi_dang_id` tham chiếu `sinh_vien.sinhvien_id` và `ho_ten_nguoi_dang`.
   `trang_thai_tin` mặc định `DangHienThi`, `ngay_tao` mặc định thời điểm hiện tại.
2. Chạy **một lần** nội dung
   `supabase/migrations/20260928010000_post_feature.sql` trong SQL Editor của
   Supabase. File này bổ sung RPC, receipt chống đăng trùng, RLS và bucket public
   `documents`. Không chạy fixture trong `test/sql` trên dự án Supabase thật.
   Migration cũ `20260928000000_create_profiles.sql` thuộc luồng hồ sơ cũ, không
   phải bước cài đặt tính năng đăng bài vào các bảng hiện có.
3. URL trong SQL đang trỏ tới project được cấu hình ở `AppConfig`. Nếu đổi project,
   sửa cả hai chuỗi origin trong SQL để khớp `AppConfig.supabaseURL`.
4. Người dùng đăng nhập phải đọc được bản ghi `sinh_vien` của chính mình qua RLS
   hiện có. Mã sinh viên phải duy nhất, gồm chữ/số, và hồ sơ cần họ tên.
   Kiểm tra các policy cũ của hai bảng và `storage.objects`: migration giữ chúng;
   một policy cũ cho phép ghi rộng có thể mở quyền ngoài các policy mới.
5. Nếu bucket đã có giới hạn dung lượng/MIME, migration giữ nguyên các giới hạn đó.
   Chọn định dạng ảnh phù hợp với cấu hình bucket khi thử trên thiết bị.

Danh mục, độ mới, độ dài tên/ghi chú, độ chính xác giá bán và các trường bắt buộc
được lấy từ schema thật qua `get_post_options`, không dùng danh sách enum giả định.
Form kiểm tra tiêu đề tối đa 255 ký tự, địa chỉ tối đa 50 ký tự, năm xuất bản hợp
lệ và giá không âm. Giá nhập với dấu phẩy được chuyển thành dấu chấm trước khi gửi.

## Lưu bài và ảnh

- Một bài dùng một ảnh chụp bằng camera hoặc chọn từ thư viện. Có xem trước và bỏ ảnh.
- Ảnh được lưu ở `documents/<mã sinh viên>/<UUID>.<đuôi ảnh>`; không đánh số hoặc
  sắp xếp ảnh. `tin_dang.hinh_anh` nhận public URL của ảnh đã upload.
- RPC `create_post` lấy `auth.uid()` và họ tên từ `sinh_vien`, rồi tạo `tai_lieu`
  và `tin_dang` trong cùng transaction. ID, người đăng, trạng thái và ngày tạo
  không phải dữ liệu người dùng tự nhập.
- Trong lúc gửi, form khóa để tránh gửi liên tiếp. Lỗi xác định giữ nội dung form
  và cố gắng xóa ảnh chưa được dùng. Nếu mất phản hồi sau khi gửi, giữ ảnh và UUID,
  dùng `get_post_result` khi thử lại để tránh tạo bài trùng. Receipt được lưu trong
  bảng nội bộ `post_requests`, không cho client đọc/ghi trực tiếp.
- Policy Storage giới hạn ghi theo mã sinh viên và không cho sửa/xóa ảnh đã được
  một bài đăng tham chiếu. Bucket public cho phép tải ảnh bằng URL.
- Khi thành công, form được xóa, chuyển về trang chủ và tải lại danh sách thật
  (50 bài đang hiển thị mới nhất). Đổi tab trong app shell giữ bản nháp trong phiên
  hiện tại; chưa lưu bản nháp qua lần đóng/mở app.

## Chạy và kiểm tra

```sh
flutter pub get
flutter analyze --no-pub
flutter test --no-pub
flutter build apk --debug --no-pub
```

Android đã có quyền Internet; iOS có mô tả quyền camera/thư viện ảnh trong Info.plist.
Camera native hiển thị trên Android/iOS, chọn file cũng hỗ trợ desktop/web theo
plugin. Tham khảo [image_picker](https://pub.dev/packages/image_picker) và
[Supabase Storage public buckets](https://supabase.com/docs/guides/storage/buckets/fundamentals#public-buckets).

Để kiểm thử SQL, tạo database PostgreSQL **cục bộ trống riêng biệt**, rồi chạy
theo thứ tự fixture, migration, test bằng `psql -v ON_ERROR_STOP=1 -f ...`.
Fixture mô phỏng Auth/Storage và dùng schema đại diện cho hai bảng; không thay
thế kiểm thử trên Supabase thật. Bộ test kiểm tra transaction rollback, receipt,
không giả mạo người đăng, phân quyền Storage và không xóa ảnh đã đăng.

Sau khi áp dụng migration, thử bằng tài khoản đã có hồ sơ: đăng không ảnh nếu
schema cho phép, đăng ảnh từ camera/thư viện, xem bài trên trang chủ và thử lỗi
mạng. Migration chưa được áp dụng lên Supabase thật trong lần triển khai mã này;
quyền camera và upload cần được kiểm tra trên thiết bị với dự án thật.
