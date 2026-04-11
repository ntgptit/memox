# 02. Domain Model

## Business Entities

### Learning Container

Mục đích:

- gom nhóm nội dung để người dùng có thể học theo chủ đề hoặc đơn vị

Ví dụ:

- deck
- lesson
- chapter
- module

### Learning Item

Mục đích:

- đại diện cho một đơn vị kiến thức hoặc kỹ năng cần được kiểm tra

Ví dụ:

- flashcard
- multiple-choice question
- statement-definition pair
- process step

### Study Session

Mục đích:

- đại diện cho một buổi học cụ thể của người học tại một thời điểm

Chứa:

- learner
- session type
- mode plan
- current mode
- current item
- progress
- completion status

### Session Item

Mục đích:

- lưu snapshot của learning item trong session để:
  - tránh lệ thuộc dữ liệu gốc thay đổi giữa buổi học
  - theo dõi trạng thái của item trong session hiện tại

Thường chứa:

- snapshot prompt
- snapshot answer
- metadata phụ trợ
- sequence
- current mode completion
- retry flag
- last outcome

### Attempt

Mục đích:

- lưu dấu vết nghiệp vụ của từng lần user tương tác

Dùng cho:

- analytics
- audit
- progress review
- debug nghiệp vụ
- reporting

### Learning State

Mục đích:

- lưu trạng thái ghi nhớ dài hạn qua nhiều session

Ví dụ:

- Leitner box
- mastery score
- confidence score
- next review date
- lapse count

## Entity Relationships

Một learner có thể có nhiều study session.

Một study session:

- thuộc về một learning container
- có nhiều session item
- có nhiều attempt
- có một current mode tại mỗi thời điểm

Mỗi session item:

- ánh xạ tới một learning item gốc
- có thể phát sinh nhiều attempt trong cùng session

Mỗi learning item:

- có thể có một learning state dài hạn cho mỗi learner

## Generic Session Snapshot

Khi mở hoặc resume session, system thường trả về:

- `sessionId`
- `sessionType`
- `modePlan`
- `activeMode`
- `modeState`
- `allowedActions`
- `currentItem`
- `progress`
- `sessionCompleted`

## Dữ liệu cần ghi trong quá trình học

- câu trả lời hoặc lựa chọn của user
- kết quả chấm
- retry flag
- trạng thái hoàn tất item trong mode hiện tại
- nhật ký attempt

## Dữ liệu dài hạn sau khi kết thúc

- mastery level hoặc box level
- lần học gần nhất
- kết quả gần nhất
- lịch học tiếp theo
- thống kê fail, success, lapse
