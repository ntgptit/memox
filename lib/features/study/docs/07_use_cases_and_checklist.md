# 07. Use Cases and Checklist

## Generic Use Cases

## Use Case: Start Study Session

### Goal

Tạo một buổi học phù hợp cho learner.

### Preconditions

- learner hợp lệ
- learning container hợp lệ
- có item đủ điều kiện học

### Main Flow

1. Learner chọn container.
2. System xác định item đủ điều kiện.
3. System xác định session type.
4. System xác định mode plan.
5. System tạo session.
6. System trả về current item đầu tiên.

### Alternative Flows

- không có item phù hợp
- learner không có quyền truy cập
- container không tồn tại

### Postconditions

- session được tạo hoặc từ chối tạo có lý do rõ ràng

## Use Case: Perform Action in Study Mode

### Goal

Cho learner thực hiện một hành động học hợp lệ trong mode hiện tại.

### Preconditions

- session đang active
- current item tồn tại
- action thuộc `allowedActions`

### Main Flow

1. Learner thực hiện action.
2. System validate action.
3. System evaluate outcome.
4. System record attempt.
5. System update session item state.
6. System trả session snapshot mới.

### Alternative Flows

- action không hợp lệ ở state hiện tại
- answer payload không hợp lệ
- timeout hoặc interruption

### Postconditions

- outcome được ghi nhận hoặc request bị từ chối

## Use Case: Complete Study Session

### Goal

Hoàn tất phiên học và cập nhật learning state dài hạn.

### Preconditions

- mode cuối đã thỏa completion rule

### Main Flow

1. System xác định tất cả điều kiện complete đã đạt.
2. System tổng hợp final item outcomes.
3. System update learning state.
4. System mark session completed.
5. System trả result summary.

### Alternative Flows

- còn item chưa đạt
- còn retry pending
- update learning state thất bại

### Postconditions

- session completed
- learning state được cập nhật hoặc rollback theo policy

## Business Rules Catalog

Phần này dùng như checklist BA và dev để áp dụng cho dự án khác.

### Item Selection Rules

- Item nào được đưa vào session?
- Ưu tiên item mới hay item đến hạn?
- Có giới hạn số lượng item không?
- Có phân tầng difficulty không?

### Session Rules

- Có bao nhiêu session type?
- Mỗi session type có mode plan nào?
- Session có thể resume không?
- Session hết hạn sau bao lâu?

### Mode Rules

- Mỗi mode đo loại tín hiệu nào?
- Mode nào là mandatory, mode nào optional?
- Mode nào cho reveal?
- Mode nào cho self-assessment?

### Scoring Rules

- Outcome nào được dùng?
- Chấm exact hay normalized?
- Reveal có penalty không?
- Skip có được tính vào mastery không?

### Retry Rules

- Fail có retry trong cùng session không?
- Retry vô hạn hay giới hạn?
- Retry có đổi mode không?

### Completion Rules

- Khi nào item được coi là complete?
- Khi nào mode complete?
- Khi nào session complete?

### Learning State Rules

- Session nào mới được update learning state?
- Update theo box, score hay band?
- Fail có reset interval không?

### Reporting Rules

- Cần dashboard nào?
- Cần KPI nào?
- Event nào cần theo dõi?
