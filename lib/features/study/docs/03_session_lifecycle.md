# 03. Session Lifecycle

## Session Lifecycle Overview

Một session generic đi qua các pha:

1. Eligibility check
2. Session creation
3. Active learning
4. Retry handling
5. Session completion
6. Long-term update

## Eligibility Check

Trước khi tạo session, hệ thống cần xác định:

- learner có quyền học container đó không
- có item nào đủ điều kiện để học không
- item đó phù hợp với session type nào

Nếu không có item phù hợp:

- session không nên được tạo
- hệ thống nên trả về trạng thái `nothing to study` hoặc tương đương

## Session Creation

Khi tạo session, hệ thống cần:

1. Chọn item phù hợp.
2. Xác định session type.
3. Xác định mode plan.
4. Snapshot item vào session.
5. Đặt current mode và current item ban đầu.
6. Trả về session snapshot đầu tiên.

## Active Learning

Trong phiên active learning:

1. Hệ thống hiển thị current item theo active mode.
2. User thực hiện một action hợp lệ.
3. Hệ thống chấm hoặc ghi nhận tự đánh giá.
4. Hệ thống ghi attempt.
5. Hệ thống cập nhật trạng thái item.
6. Hệ thống quyết định luồng tiếp theo.

## Retry Handling

Nếu một item chưa đạt:

- item không được xem là hoàn thành trong mode hiện tại
- item được đánh dấu cần retry

Khi lượt đầu của mode kết thúc:

- nếu còn item retry, system mở vòng retry
- nếu không còn item retry, mode hoàn tất

## Session Completion

Session hoàn tất khi:

- mode cuối cùng hoàn tất
- không còn item chưa đạt trong session theo completion rule của session đó

Sau đó hệ thống:

- cập nhật learning state
- sinh result summary
- ghi analytics event

## Session Types

Một hệ thống generic nên xem session type là `business policy`, không phải màn hình.

### Session Type Purpose

Session type quyết định:

- cách chọn item
- mode plan
- độ dài phiên học
- mức độ khó
- completion rule

### Generic Session Type Examples

| Session type | Mục tiêu |
| --- | --- |
| First Learning | học nội dung mới |
| Review | ôn nội dung đã học |
| Remedial | tập trung vào nội dung yếu |
| Exam Prep | luyện tập mô phỏng kỳ thi |
| Quick Drill | phiên ngắn, xử lý nhanh |
| Reinforcement | củng cố sau khi học xong một module |

### Session Type Inputs

Các yếu tố thường được dùng để quyết định session type:

- item mới
- item đến hạn ôn
- item thường fail
- user preference
- curriculum stage
- due date hoặc exam date
- business priority
