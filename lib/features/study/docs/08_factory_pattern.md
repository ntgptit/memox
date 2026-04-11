# 08. Factory Pattern

## Vì sao study engine hợp với Factory Pattern

Trong thực tế, bài toán study gần như luôn có đặc điểm sau:

- có nhiều `session type`
- có nhiều `study mode`
- mỗi mode có rule riêng
- hệ thống phải chọn đúng logic theo ngữ cảnh hiện tại

Nếu xử lý bằng chuỗi `if/else` hoặc `switch` trải dài trong nhiều lớp, hệ thống sẽ nhanh chóng:

- khó mở rộng
- khó test
- khó đọc rule
- dễ làm lẫn logic giữa các mode

Do đó, về mặt thiết kế nghiệp vụ lẫn kỹ thuật, `Factory Pattern` là một pattern rất phù hợp.

## Mục tiêu của Factory Pattern trong study domain

Mục tiêu của factory trong study domain là:

- chọn đúng rule set cho đúng ngữ cảnh
- cô lập biến thể nghiệp vụ
- giảm branching logic phân tán
- cho phép mở rộng thêm mode hoặc session type mà ít ảnh hưởng code cũ

Factory trong study domain là một cơ chế:

- nhận context
- quyết định dùng implementation nào
- trả về đúng business behavior cho context đó

## Những nơi factory nên xuất hiện

### Session Type Factory

Mục đích:

- chọn `sessionType` phù hợp theo dữ liệu đầu vào

### Mode Plan Factory

Mục đích:

- trả về `modePlan` theo session type hoặc policy

### Study Mode Factory

Mục đích:

- chọn đúng implementation cho mode hiện tại

Ví dụ output:

- `ReviewModeHandler`
- `MatchModeHandler`
- `GuessModeHandler`
- `RecallModeHandler`
- `FillModeHandler`

### Outcome Evaluation Factory

Mục đích:

- chọn đúng evaluator theo loại answer hoặc loại item

### Result Presentation Factory

Mục đích:

- chọn cách trình bày dữ liệu theo mode hoặc outcome

## Factory Pattern thường đi cùng Strategy Pattern

Trong domain này, pattern thực tế thường là cặp:

- `Factory Pattern` để chọn implementation
- `Strategy Pattern` để chứa rule của implementation đó

Business interpretation:

- factory trả lời câu hỏi: “Trong ngữ cảnh hiện tại, dùng bộ rule nào?”
- strategy trả lời câu hỏi: “Bộ rule đó xử lý như thế nào?”

Vì vậy trong study engine, cách kết hợp phù hợp thường là:

1. Factory nhận `mode` hoặc `session type`
2. Factory trả về strategy tương ứng
3. Strategy xử lý:
   - allowed actions
   - prompt
   - scoring
   - completion rule
   - feedback rule

## Lợi ích nghiệp vụ và sản phẩm

### Dễ mở rộng mode mới

- không cần sửa quá nhiều luồng cũ
- chỉ cần thêm implementation mới và đăng ký vào factory

### Dễ tách business rule theo biến thể

Mỗi mode có:

- goal khác nhau
- cách chấm khác nhau
- completion rule khác nhau

### Dễ kiểm thử

- mỗi mode có thể test như một unit logic riêng

### Dễ cấu hình cho dự án khác

- có thể giữ cùng khung factory
- chỉ thay danh sách strategy và policy

### Hỗ trợ Open/Closed Principle

- hệ thống mở cho việc thêm mode mới
- không cần sửa logic trung tâm quá nhiều

## Generic Factory Contract

### Input

- một key nghiệp vụ rõ ràng

Ví dụ:

- `sessionType`
- `activeMode`
- `answerType`
- `resultType`

### Output

- một implementation đúng với key đó

### Failure Rule

Nếu không có implementation phù hợp:

- hệ thống phải fail fast
- trả lỗi rõ ràng
- không nên fallback im lặng sang logic sai

## Nguyên tắc thiết kế factory cho dự án khác

1. Factory chỉ chịu trách nhiệm chọn implementation, không chứa business rule chi tiết.
2. Business rule nằm trong strategy hoặc handler cụ thể.
3. Key dùng để resolve phải là key nghiệp vụ, không phải key UI.
4. Factory nên fail fast nếu thiếu implementation.
5. Danh sách implementation nên có thể cấu hình hoặc đăng ký rõ ràng.
6. Không nên để nhiều lớp khác nhau tự `switch` theo mode; nên gom việc chọn vào factory.

## Mapping vào `lumos`

### Frontend factory

Frontend đang có:

- `StudyModeViewStrategyFactory`

Vai trò:

- nhận `activeMode`
- trả về đúng `StudyModeViewStrategy`

### Backend factory

Backend đang có:

- `StudyModeStrategyFactory`

Vai trò:

- nhận `StudyMode`
- trả về đúng business strategy cho mode đó

Backend strategy quyết định các nội dung như:

- `resolveAllowedActions`
- `evaluateAnswer`
- `resolvePrompt`
- `resolveExpectedAnswer`
- `resolveChoices`
- `resolveMatchPairs`
- `resolvePassedItems`
- `resolveInstruction`
- `resolveInputPlaceholder`

## Kết luận

Trong `lumos`, pattern đang áp dụng thực chất là:

- `Factory Pattern` để resolve implementation
- kết hợp với `Strategy Pattern` để chứa rule khác nhau của từng mode

Đây là hướng thiết kế đúng với một study engine nhiều mode và rất phù hợp để mang sang các dự án khác.
