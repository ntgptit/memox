# 05. Execution Rules

## Action-State Contract

Phần này là business contract rất quan trọng và nên có ở mọi dự án.

### Principle

Tại mỗi thời điểm, user chỉ được làm những action hợp lệ với state hiện tại.

Không nên để UI tự suy đoán flow.

System nên luôn trả về:

- current state
- allowed actions

### Generic Mode States

| State | Ý nghĩa nghiệp vụ |
| --- | --- |
| `INITIALIZED` | mode mới bắt đầu |
| `IN_PROGRESS` | user đang làm item |
| `WAITING_FEEDBACK` | system đang chờ bước xác nhận tiếp theo |
| `RETRY_PENDING` | có item fail cần quay lại |
| `COMPLETED` | mode đã xong |

### Generic Actions

| Action | Mục đích |
| --- | --- |
| `SUBMIT_ANSWER` | nộp câu trả lời |
| `REVEAL_ANSWER` | xem đáp án hoặc xin trợ giúp |
| `MARK_REMEMBERED` | tự xác nhận nhớ được |
| `RETRY_ITEM` | xác nhận cần học lại |
| `GO_NEXT` | sang bước tiếp theo |
| `RESET_CURRENT_MODE` | làm lại mode hiện tại |

### Generic Outcomes

| Outcome | Ý nghĩa nghiệp vụ |
| --- | --- |
| `PASSED` | item đạt tiêu chí mode hoặc session |
| `FAILED` | item chưa đạt tiêu chí |
| `SKIPPED` | item không có tín hiệu đủ mạnh để đánh giá hoặc user bỏ qua |

## Retry and Remediation Model

### Mục tiêu

- không để item fail biến mất quá sớm
- tạo cơ hội sửa sai trong cùng session

### Generic Rules

Khi item fail:

- item không được mark complete ở mode hiện tại
- item được mark retry pending

Khi hết lượt đầu:

- nếu còn retry pending item, mode đi vào retry loop
- nếu không còn retry pending item, mode có thể complete

### Generic Remediation Options

- retry trong cùng mode
- chuyển sang mode dễ hơn
- reveal có penalty
- thêm hint
- đưa item sang remedial session sau này

## Answer Evaluation Policy

Đây là phần BA phải định nghĩa rõ cho mọi dự án.

### Những câu hỏi bắt buộc

1. Chấm exact hay normalize?
2. Có bỏ qua khoảng trắng thừa không?
3. Có bỏ qua hoa-thường không?
4. Có chấp nhận synonym không?
5. Có chấp nhận typo nhỏ không?
6. Reveal có tính fail không?
7. Input rỗng được xử lý như invalid hay failed?

### Các policy generic thường gặp

| Policy | Phù hợp khi |
| --- | --- |
| Exact match | spelling, formula, code, term chính xác |
| Trim-insensitive | text có khoảng trắng linh hoạt |
| Case-insensitive | từ vựng hoặc label |
| Synonym-aware | language learning, concept learning |
| Fuzzy tolerance | sản phẩm ưu tiên UX hơn strict grading |
