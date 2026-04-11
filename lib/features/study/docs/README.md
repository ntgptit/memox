# Study Spec README

Bộ tài liệu này mô tả `study engine` theo hướng generic và BA-first, nhưng đã được tách nhỏ để dev dễ implement.

## Mục tiêu

- đọc theo từng concern nghiệp vụ
- dễ map sang domain, application, API và UI
- dễ tách task cho team

## Reading Order

1. `01_business_context.md`
2. `02_domain_model.md`
3. `03_session_lifecycle.md`
4. `04_mode_patterns.md`
5. `05_execution_rules.md`
6. `06_learning_lifecycle.md`
7. `07_use_cases_and_checklist.md`
8. `08_factory_pattern.md`
9. `09_adoption_template.md`

## Map sang implementation

| File | Dev thường dùng khi nào |
| --- | --- |
| `01_business_context.md` | cần hiểu bài toán và mục tiêu sản phẩm |
| `02_domain_model.md` | dựng entity, DTO, aggregate, schema |
| `03_session_lifecycle.md` | implement create/resume/complete session |
| `04_mode_patterns.md` | implement logic từng mode |
| `05_execution_rules.md` | implement action-state, retry, scoring policy |
| `06_learning_lifecycle.md` | implement learning state, analytics, reset/exit |
| `07_use_cases_and_checklist.md` | chia task và kiểm tra completeness |
| `08_factory_pattern.md` | tổ chức code theo factory + strategy |
| `09_adoption_template.md` | áp framework này sang dự án mới |
