# 06. Learning Lifecycle

## Learning State Update Model

### Mục tiêu

Biến kết quả của session thành quyết định về việc khi nào user nên học lại item đó.

### Generic Update Rules

Ví dụ:

- `PASSED`
  - tăng mastery
  - lùi lịch ôn xa hơn
- `FAILED`
  - giảm mastery hoặc giữ mức thấp
  - đẩy lịch ôn gần hơn
- `SKIPPED`
  - không thay đổi hoặc thay đổi rất ít

### Generic Representations

- Leitner box
- mastery score
- confidence score
- spaced repetition interval
- adaptive difficulty band

### Recommended Principle

Session outcome là tín hiệu ngắn hạn.

Learning state là quyết định dài hạn.

Không nên trộn hai lớp này thành một.

## Resume, Reset, Exit

### Resume Session

Mục tiêu:

- cho phép user quay lại đúng trạng thái session đang dang dở

Business rule:

- session đang active có thể resume
- current mode, current item, progress và allowed actions phải được khôi phục đúng

### Reset Current Mode

Mục tiêu:

- cho phép user làm lại mode hiện tại từ đầu

Business rule:

- clear progress của mode hiện tại
- clear attempt của mode hiện tại nếu business cho phép
- giữ session identity hoặc tạo mode run mới tùy policy

### Exit Session

Mục tiêu:

- user có thể rời session giữa chừng

Business rule cần quyết định:

- session được lưu dở hay không
- outcome dở dang có ghi vào analytics không
- lần quay lại sẽ resume hay mở session mới

## Analytics and Reporting

Một study engine generic nên sinh dữ liệu phục vụ BA và product analytics.

### Dữ liệu nên có

- session started
- session resumed
- session completed
- mode entered
- mode completed
- item passed
- item failed
- item skipped
- retry count
- reveal usage
- average time per item
- completion rate

### KPI gợi ý

| KPI | Ý nghĩa |
| --- | --- |
| Session completion rate | tỷ lệ hoàn tất buổi học |
| Mode drop-off rate | mode nào khiến user bỏ dở |
| Pass rate by mode | mode nào khó nhất |
| Retry rate | tỷ lệ phải làm lại |
| Reveal rate | mức độ phụ thuộc vào trợ giúp |
| Recall accuracy | chất lượng ghi nhớ chủ động |
| Review interval adherence | mức độ học đúng hạn |
