# 04. Mode Patterns

## Study Mode Framework

Study mode là một interaction pattern nhằm thu thập một loại tín hiệu học tập cụ thể.

Mỗi mode nên định nghĩa rõ:

- mục tiêu
- input hiển thị
- action user được làm
- logic chấm
- completion rule
- dữ liệu cần ghi

## Vì sao cần nhiều mode

Một mode đơn lẻ thường không đủ phản ánh chất lượng ghi nhớ.

Ví dụ:

- multiple-choice đo recognition
- typed answer đo recall mạnh hơn
- self-assessment đo confidence hoặc self-awareness

Do đó nhiều sản phẩm học nên dùng `mode plan` thay vì chỉ một kiểu bài.

## Review Mode Pattern

### Business Goal

- thu thập self-assessment nhanh từ người học

### Preconditions

- current item có thể hiển thị đầy đủ hoặc gần đầy đủ
- user đủ thông tin để tự đánh giá

### Main Flow

1. Hệ thống hiển thị item.
2. User xem item.
3. User chọn remembered hoặc retry.
4. Hệ thống ghi outcome.
5. Hệ thống cho đi tiếp.

### Alternative Flows

- user bỏ ngang session
- user reset mode
- user yêu cầu thêm trợ giúp hoặc audio

### Postconditions

- item có outcome
- attempt được ghi
- item được đánh dấu complete hoặc retry

### Typical Actions

- `MARK_REMEMBERED`
- `RETRY_ITEM`
- `GO_NEXT`

### Business Strength

- nhanh
- nhẹ
- phù hợp warm-up hoặc reinforcement

### Business Risk

- phụ thuộc vào sự trung thực và tự nhận thức của user

## Match Mode Pattern

### Business Goal

- đo khả năng nhận diện quan hệ giữa hai vế kiến thức

### Preconditions

- item hoặc nhóm item có thể biểu diễn thành cặp

### Main Flow

1. Hệ thống sinh hai tập phần tử cần ghép.
2. User ghép các phần tử.
3. Hệ thống kiểm tra độ đầy đủ và độ chính xác.
4. Hệ thống ghi outcome.
5. Hệ thống cho đi tiếp hoặc cho retry.

### Alternative Flows

- thiếu cặp
- ghép sai
- board lớn chia thành nhiều nhóm nhỏ

### Postconditions

- board được pass hoặc fail
- attempt được ghi
- item liên quan được mark complete hoặc retry

### Typical Actions

- select left
- select right
- `SUBMIT_ANSWER`
- `GO_NEXT`

### Business Strength

- tốt cho concept linking
- trực quan
- phù hợp giai đoạn đầu và giữa

### Business Risk

- nếu board quá lớn, user mệt
- nếu distractor yếu, mode quá dễ

## Guess Mode Pattern

### Business Goal

- đo recognition bằng lựa chọn có ràng buộc

### Preconditions

- có thể sinh đáp án đúng và distractor hợp lý

### Main Flow

1. Hệ thống hiển thị prompt.
2. Hệ thống hiển thị choice set.
3. User chọn đáp án.
4. Hệ thống chấm đúng hoặc sai.
5. Hệ thống ghi outcome.
6. Hệ thống cho đi tiếp.

### Alternative Flows

- choice set không đủ chất lượng
- user hết thời gian
- user chọn sai rồi cần remediation

### Postconditions

- item được pass hoặc fail
- attempt được ghi

### Typical Actions

- select choice
- `SUBMIT_ANSWER`
- `GO_NEXT`

### Business Strength

- rất dễ tiếp cận
- chấm tự động rõ ràng
- phù hợp với session ngắn

### Business Risk

- user có thể đoán
- tín hiệu nhớ yếu hơn recall

## Recall Mode Pattern

### Business Goal

- đo khả năng nhớ chủ động trước khi có trợ giúp

### Preconditions

- prompt đủ để user cố gắng recall
- reveal policy được định nghĩa rõ

### Main Flow

1. Hệ thống chỉ hiển thị prompt.
2. User cố nhớ.
3. Hệ thống cho reveal:
   - do user chủ động
   - hoặc do timeout
4. Sau reveal, user tự đánh giá remembered hoặc retry.
5. Hệ thống ghi outcome.
6. Hệ thống cho đi tiếp.

### Alternative Flows

- reveal nhưng không self-assess
- timeout reveal
- reveal có penalty

### Postconditions

- item có outcome `PASSED`, `FAILED` hoặc `SKIPPED`
- attempt được ghi

### Typical Actions

- `REVEAL_ANSWER`
- `MARK_REMEMBERED`
- `RETRY_ITEM`
- `GO_NEXT`

### Business Strength

- tín hiệu ghi nhớ mạnh
- phù hợp spaced repetition

### Business Risk

- nếu UX không tốt, user thấy áp lực quá mức
- nếu rule self-assessment không rõ, outcome thiếu tin cậy

## Fill Mode Pattern

### Business Goal

- đo khả năng tái tạo đáp án thay vì chỉ nhận diện

### Preconditions

- đáp án có thể chấm theo policy rõ ràng

### Main Flow

1. Hệ thống hiển thị prompt.
2. User nhập đáp án.
3. Hệ thống chấm theo answer policy.
4. Nếu đúng:
   - ghi pass
   - cho đi tiếp
5. Nếu sai:
   - ghi fail
   - cho retry hoặc reveal tùy policy

### Alternative Flows

- input rỗng
- input đúng một phần
- input đúng sau normalize nhưng sai exact
- reveal trợ giúp

### Postconditions

- item pass hoặc fail
- attempt được ghi
- nếu fail có thể đi vào retry loop

### Typical Actions

- type answer
- `SUBMIT_ANSWER`
- `REVEAL_ANSWER`
- `GO_NEXT`

### Business Strength

- tín hiệu mạnh về recall
- rất phù hợp ôn tập

### Business Risk

- dễ gây frustration nếu policy quá chặt
- cần rule normalize minh bạch
