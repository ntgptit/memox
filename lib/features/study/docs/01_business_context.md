# 01. Business Context

## Mục đích tài liệu

Tài liệu này dùng để:

- làm business baseline cho chức năng học tập nhiều bước
- thống nhất ngôn ngữ giữa BA, PO, UX, QA và DEV
- tách business rule khỏi cách triển khai kỹ thuật
- cung cấp khung chuẩn để áp dụng cho dự án khác

## Phạm vi nghiệp vụ

Tài liệu bao phủ các nội dung sau:

- mô hình session học
- mô hình item học
- mô hình mode học
- luồng người dùng trong một buổi học
- business rule chấm kết quả
- business rule retry
- business rule cập nhật trạng thái học dài hạn
- dữ liệu cần đọc, cần ghi, cần báo cáo

Tài liệu không đi sâu vào:

- layout UI chi tiết
- lựa chọn framework
- thiết kế API cụ thể
- schema database cụ thể

## Bối cảnh nghiệp vụ

Một sản phẩm học tập không chỉ cần hiển thị nội dung và ghi nhận đúng hoặc sai.

Nó cần giải quyết 5 bài toán nghiệp vụ:

1. Chọn đúng nội dung cần học tại đúng thời điểm.
2. Tạo trải nghiệm học theo nhiều mức độ khó khác nhau.
3. Thu thập tín hiệu đủ tin cậy về mức độ ghi nhớ của người học.
4. Quyết định nội dung nào đã đạt và nội dung nào cần quay lại.
5. Cập nhật trạng thái học dài hạn để tối ưu phiên học tiếp theo.

Do đó, thay vì chỉ xây một màn hình quiz, hệ thống nên được thiết kế như một `study engine`.

## Business Objectives

### Mục tiêu chính

- Tăng khả năng ghi nhớ của người học theo thời gian.
- Giảm việc học dàn trải, học sai thời điểm hoặc học lặp không cần thiết.
- Tạo bằng chứng định lượng và định tính về tiến độ ghi nhớ.
- Tự động hóa quyết định nội dung nào nên học, ôn hay học lại.

### Mục tiêu phụ

- Tăng completion rate của session.
- Tăng retention qua nhiều ngày hoặc nhiều tuần.
- Giảm cognitive overload bằng cách chia nội dung thành nhiều mode phù hợp.
- Tạo dữ liệu cho analytics, progress report và reminder.

## Stakeholders

| Stakeholder | Mối quan tâm |
| --- | --- |
| Learner | học hiệu quả, ít ma sát, biết mình đang tiến bộ thế nào |
| Product Owner | retention, engagement, outcome học tập |
| BA | business rule rõ ràng, flow rõ ràng, có thể kiểm thử |
| UX Designer | luồng học dễ hiểu, phản hồi đúng ngữ cảnh |
| QA | có state, action, outcome rõ ràng để test |
| Developer | có domain model và contract rõ ràng để implement |
| Data/Analytics team | có event và outcome chuẩn hóa để báo cáo |

## Actors

### Primary Actor

- Learner

### Secondary Actors

- Study Engine
- Scoring Engine
- Recommendation Engine
- Analytics Engine
- Reminder Engine

Trong nhiều hệ thống, các actor phụ có thể là một service hoặc nhiều service riêng, nhưng về BA có thể xem là một phần của System.

## Glossary

| Thuật ngữ | Định nghĩa generic |
| --- | --- |
| Learning container | tập hợp nội dung để học theo phiên, ví dụ deck, lesson, module, chapter |
| Learning item | đơn vị kiến thức nhỏ nhất, ví dụ flashcard, quiz item, concept |
| Study session | một buổi học hữu hạn có điểm bắt đầu và kết thúc |
| Session item | snapshot của learning item trong một session |
| Study mode | kiểu tương tác học cụ thể |
| Attempt | một lần user thực hiện hành động có ý nghĩa chấm điểm |
| Outcome | kết quả nghiệp vụ của attempt hoặc item |
| Retry | việc đưa item chưa đạt quay lại vòng học trong session hiện tại |
| Learning state | trạng thái ghi nhớ dài hạn của item |
| Session type | loại buổi học, quyết định cách chọn item và mode plan |
| Mode plan | chuỗi mode mà session sẽ đi qua |
| Allowed actions | tập hành động user được phép thực hiện ở một thời điểm cụ thể |

## Business Capabilities

Một study engine generic nên có ít nhất các capability sau:

1. Select learning items
2. Start or resume session
3. Determine session type
4. Determine mode plan
5. Render current item in current mode
6. Accept user action
7. Evaluate outcome
8. Record attempt
9. Retry unfinished items
10. Complete mode
11. Complete session
12. Update long-term learning state
13. Expose analytics and result summary
