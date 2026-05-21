# Design Spec: Tối ưu token cho BA-kit theo hướng compression-first

## 1. Tóm tắt thiết kế

Mục tiêu của thiết kế này là giảm mạnh lượng input token khi vận hành BA-kit trên dự án thật, đặc biệt trong các trường hợp nguồn đầu vào lớn, artifact tăng dần theo lifecycle, và có phát sinh CR cần đi qua `impact`.

Thiết kế ưu tiên:

- giảm token nhanh nhất
- chấp nhận làm flow chặt hơn
- chấp nhận sinh thêm artifact điều hướng nhỏ nếu đổi lại giảm được broad-read

Thiết kế này không tối ưu trước cho backward compatibility mềm hay trải nghiệm linh hoạt. Khi hai mục tiêu đó xung đột với token discipline, token discipline được ưu tiên.

## 2. Bối cảnh và vấn đề

Qua rà soát repo hiện tại, BA-kit đã có nền tảng tốt cho token discipline:

- có `source-extract`
- có `project-memory` compact và shard mode
- có read-scope contract theo command
- có rule `index-first navigation`
- có guardrail cho instruction surface

Tuy nhiên, lượng input token thực tế vẫn có thể vượt `150,000+` khi chạy trên dự án thật vì ba nhóm nguyên nhân:

1. instruction surface của runtime vẫn khá lớn
2. raw source và artifact lớn vẫn có thể bị đọc lại nhiều lần
3. một số exception path hợp lệ như `impact` có thể trở thành broad-read escape hatch

Vấn đề chính không nằm ở một file đơn lẻ, mà nằm ở cách full flow vẫn có khả năng kéo lại context lớn qua nhiều bước.

## 3. Mục tiêu

### Mục tiêu chính

- giảm lượng context phải nạp ở từng command
- giảm số lần đọc lại raw source và artifact lớn
- buộc downstream steps chỉ đọc lớp điều hướng nhỏ trước khi đọc tài liệu lớn
- kiểm soát exception path như `impact` để không phá vỡ token discipline

### Mục tiêu phụ

- giữ source of truth hierarchy hiện tại
- tăng khả năng test được bằng parity/contract tests
- tạo nền cho tối ưu sâu hơn ở giai đoạn sau

## 4. Phi mục tiêu

Thiết kế này không nhằm:

- giữ nguyên hành vi hiện tại nếu hành vi đó làm tăng token
- tối ưu UI hoặc wording của BA-facing flow
- refactor toàn bộ contract prose ngay trong pha đầu
- thay đổi triết lý source of truth của BA-kit

## 5. Audit conflict và tồn đọng

### 5.1 `source-extract` chưa là cổng bắt buộc

Đây là xung đột lớn nhất.

Hiện `intake` ưu tiên extract cho PDF, nhưng `md/txt` vẫn có thể bị đọc trực tiếp. Điều này cho phép raw source lớn đi thẳng vào context ngay từ đầu, làm suy yếu toàn bộ các tối ưu về sau.

### 5.2 Compact mode có thể trở thành monolith mới

`project-memory.md` vẫn hữu ích cho dự án nhỏ, nhưng nếu dự án có input hoặc artifact lớn mà chưa được ép sang shard/index mode sớm, compact memory có thể tiếp tục phình to và trở thành một file tóm tắt nhưng vẫn quá nặng.

### 5.3 Contract có rule đúng nhưng thiếu artifact điều hướng đủ mạnh

Repo đã có rule read-scope và index-first navigation. Tuy nhiên, downstream steps vẫn thường phải đọc full `backbone`, `stories`, hoặc `SRS` vì chưa có `section map` hoặc `artifact index` đủ tốt để thay thế full read.

### 5.4 `impact` là exception hợp lý nhưng nguy hiểm

`impact` cần đủ rộng để làm change triage. Nhưng nếu không đổi sang mô hình `delta-first`, command này sẽ tiếp tục là broad-read path hợp pháp và dễ phá vỡ token discipline khi có nhiều CR.

### 5.5 `package` và fallback path có nguy cơ thành full rebuild read-path

Về nguyên tắc, `package` chỉ validate và compile. Nhưng nếu cross-check không dựa trên trace ID, section index, hoặc artifact map đủ hẹp, bước này vẫn có thể vô tình kéo quá nhiều file lớn vào cùng một lượt.

### 5.6 Instruction surface vẫn là baseline cost đáng kể

Đây không phải vấn đề lớn nhất, nhưng vẫn là chi phí cố định cho mỗi run. Nếu cần giảm token triệt để, giai đoạn sau vẫn nên tiếp tục tách deterministic prose khỏi `contract-behavior.md`.

## 6. Các hướng tiếp cận đã cân nhắc

### Hướng A - Siết flow theo hướng compression-first

Ý tưởng:

- ép mọi bước đọc theo `summary -> index -> targeted section`
- raw source chỉ được đọc lại khi có `READ_ESCALATION`
- artifact lớn phải có lớp điều hướng nhỏ đi trước

Ưu điểm:

- giảm token mạnh nhất
- xử lý đúng gốc vấn đề là repeated broad-read
- phù hợp với ưu tiên hiện tại

Nhược điểm:

- flow cứng hơn
- cần sinh thêm artifact phụ
- cần thêm test để khóa behavior

### Hướng B - Vá guardrail trên flow hiện tại

Ý tưởng:

- giữ flow hiện tại
- thêm vài rule cho `source-extract`, `impact`, `memory shard`

Ưu điểm:

- ít thay đổi hơn
- rủi ro thấp hơn trong ngắn hạn

Nhược điểm:

- khó kéo token xuống đủ mạnh
- broad-read path vẫn còn đất sống

### Hướng C - Giảm instruction surface trước

Ý tưởng:

- tách prose deterministic khỏi `contract-behavior.md`
- đẩy thêm logic sang YAML, JSON, hoặc CLI helper

Ưu điểm:

- giảm baseline cost cố định
- làm contract rõ hơn về mặt cấu trúc

Nhược điểm:

- không giải quyết được phần nổ lớn nhất là runtime project context
- tác động ngắn hạn lên case `150,000+` không mạnh bằng hướng A

### Khuyến nghị

Chọn hướng A làm chính.

Sau khi hướng A đã khóa xong flow và read discipline, có thể dùng một phần của hướng C để hạ thêm instruction surface.

## 7. Thiết kế đích

### 7.0 Lớp contract hóa bắt buộc

Trước khi enforce read ladder, BA-kit phải đưa các artifact điều hướng mới vào contract chính thức.

Các path cần bổ sung vào `core/contract.yaml`:

- `source_chunk_index`: `plans/{slug}-{date}/00_source/chunk-index.md`
- `backbone_index`: `plans/{slug}-{date}/02_backbone/backbone-index.md`
- `stories_index`: `plans/{slug}-{date}/03_modules/{module_slug}/user-stories-index.md`
- `srs_index`: `plans/{slug}-{date}/03_modules/{module_slug}/srs-index.md`

Các output cần bổ sung:

- `intake` tạo hoặc promote `source_summary`, `source_chunks_dir`, và `source_chunk_index` khi dùng file source lớn
- `backbone` tạo `backbone` và `backbone_index`
- `stories` tạo `stories` và `stories_index`
- `srs` tạo `srs`, `srs_group`, `wireframe_input`, và `srs_index`

Nếu artifact điều hướng chưa được khai báo trong contract, runtime không có nguồn chuẩn để resolve path, kiểm tra prerequisite, hoặc viết parity test. Vì vậy contract hóa là bước nền trước khi thay đổi behavior ở downstream steps.

### 7.1 Read ladder bắt buộc

BA-kit nên vận hành theo read ladder cứng:

```text
raw source
-> source summary
-> source chunks / section index
-> intake
-> backbone index
-> targeted artifact sections
-> package
```

Nguyên tắc:

- raw source chỉ là lớp đầu vào ban đầu
- sau `intake`, downstream không quay lại raw source theo mặc định
- sau `backbone`, downstream không mở full backbone theo mặc định nếu đã có index hoặc section map
- mọi tài liệu lớn phải có lớp điều hướng nhỏ đứng trước

### 7.2 Các artifact điều hướng mới hoặc bắt buộc hơn

Thiết kế này ưu tiên các artifact nhỏ sau:

- `00_source/summary.md`
- `00_source/chunks/*`
- `00_source/chunk-index.md`
- `02_backbone/backbone-index.md`
- `03_modules/{module_slug}/user-stories-index.md`
- `03_modules/{module_slug}/srs-index.md`

Các artifact này không thay thế source of truth. Chúng chỉ làm nhiệm vụ điều hướng bounded context.

### 7.3 Format tối thiểu của index

Mỗi index phải nhỏ, có cấu trúc, và không lặp nội dung chi tiết của artifact gốc.

`source chunk index` cần có:

- chunk id
- path
- heading hoặc candidate section
- source type
- page number hoặc source range nếu có
- 5-10 keywords ngắn
- excerpt rất ngắn, chỉ để nhận diện nội dung

`backbone index` cần có:

- section name
- section anchor hoặc heading
- trace IDs xuất hiện trong section
- module hoặc feature liên quan
- short summary tối đa 1-2 dòng

`stories index` cần có:

- epic/story IDs
- feature hoặc FR liên quan
- acceptance criteria count
- screen IDs liên quan nếu có
- path/heading để mở đúng phần

`srs index` cần có:

- group id
- UC/SCR/rule/message IDs
- screen hoặc flow liên quan
- path/heading hoặc group file
- dependency ngắn đến stories/backbone IDs

Index không được chứa full requirement text, full acceptance criteria, full use case flow, hoặc full screen description.

## 8. Thiết kế flow theo command

### 8.1 `intake`

Thiết kế mới:

- input lớn không được đọc thẳng, kể cả `md` và `txt`
- luôn đi qua `source-extract`
- `intake` đọc `summary.md` trước
- chỉ mở chunk liên quan khi cần làm rõ
- `source-extract` phải tạo thêm `chunk-index.md`

Yêu cầu thiết kế:

- normalized `intake.md` phải đủ giàu để downstream không cần quay lại `00_source`
- nếu user đưa raw source mới hoặc thay nguồn đầu vào gốc, đó là một event mới chứ không phải broad reread mặc định

Ngưỡng đề xuất ban đầu:

- file text hoặc markdown trên `20 KB` phải đi qua `source-extract`
- file có trên `8` chunks phải có `chunk-index.md`
- chunk mặc định nên giảm từ `4000` ký tự xuống khoảng `2000-2500` ký tự để route chính xác hơn
- pasted text trên `8 KB` nên được staging vào source cache trước khi normalize

### 8.2 `options`

Thiết kế mới:

- chỉ đọc `intake.md`, `plan.md`, và chunk nguồn khi thật sự cần đối chiếu
- không scan lại toàn bộ `00_source`
- option output phải giữ là brief ngắn, không biến thành mini-backbone

### 8.3 `backbone`

Thiết kế mới:

- chỉ đọc `intake.md`, `plan.md`, và option đã chọn nếu có
- sau khi sinh `backbone.md`, bắt buộc sinh thêm `backbone index`

Vai trò của `backbone index`:

- cung cấp map section, ID, và trace anchors
- cho phép downstream chọn đúng phần cần mở
- giảm nhu cầu đọc full backbone

Ngưỡng đề xuất ban đầu:

- luôn sinh `backbone-index.md` sau khi tạo hoặc rerun `backbone.md`
- downstream chỉ được mở full `backbone.md` khi index thiếu route hoặc có `READ_ESCALATION`

### 8.4 `frd`

Thiết kế mới:

- đọc `backbone index` trước
- chỉ mở section backbone liên quan đến module hoặc requirement đang được phát triển
- không lấy full backbone nếu index đã đủ route
- nếu sinh FRD trên `20 KB`, tạo thêm lightweight section map trong chính FRD hoặc artifact index riêng ở pha sau

### 8.5 `stories`

Thiết kế mới:

- đọc `backbone index` trước
- chỉ mở section backbone liên quan
- chỉ đọc `FRD` khi thật sự cần vocabulary hoặc workflow bổ sung
- sau khi tạo stories, sinh `user-stories-index.md`

Nguyên tắc:

- không đọc full `FRD` chỉ để lấy cách gọi thuật ngữ
- ưu tiên vocabulary từ hot memory hoặc section route nhỏ hơn

### 8.6 `srs`

Đây là điểm nguy hiểm nhất về token.

Thiết kế mới:

- đọc `backbone index` và `stories index` trước
- chỉ load đúng module, đúng group, đúng section
- giữ mô hình chia `srs-core`, `srs-wireframes`, `srs-assembly`, nhưng bổ sung section map để router không cần kéo quá nhiều upstream context
- sau khi tạo hoặc assemble SRS, sinh `srs-index.md`

### 8.7 `wireframes`

Thiết kế mới:

- ưu tiên tuyệt đối `wireframe-input`
- chỉ fallback sang nguồn khác khi input pack chưa tồn tại
- không kéo ngược nhiều artifact upstream nếu pack đã đủ

### 8.8 `package`

Thiết kế mới:

- chỉ validate artifact đã tồn tại
- không được trở thành lối đi vòng để reread cả flow
- cross-check phải dựa trên trace ID, section map, và artifact presence thay vì mở lại quá nhiều full artifact

Read contract đề xuất cho `package`:

- must read: `contract.yaml`, `contract-behavior.md`, artifact presence, `backbone_index` khi tồn tại
- may read: `stories_index`, `srs_index`, `memory_index`, `wireframe_state`
- may read full artifact only for the exact artifact being converted to HTML
- must not read: raw source, full intake, full backbone, full stories, or full SRS only to perform cross-reference discovery
- escalation allowed only when index is missing, stale, or contradictory

## 9. Exception path: `CR -> impact -> rerun`

### 9.1 Mô hình hiện tại cần thay đổi

`impact` hiện là broad-read exception hợp lý, nhưng nếu giữ như hiện tại thì đây sẽ là điểm phá token discipline mạnh nhất khi dự án có nhiều change request.

### 9.2 Thiết kế mới: `delta-first`

`impact` phải chạy theo thứ tự:

1. nhận CR hoặc correction
2. map thay đổi vào node hoặc ID bị ảnh hưởng
3. xác định artifact sở hữu node đó
4. chỉ mở artifact và section cần thiết
5. đề xuất rerun path nhỏ nhất

Các node ưu tiên map:

- scope
- actor
- FR / NFR
- story
- UC
- SCR
- rule code
- message code

### 9.3 Quy tắc escalation

Chỉ cho phép broad-read rộng hơn khi:

- CR không thể map vào node cụ thể
- node bị ảnh hưởng nằm ở nhiều source-of-truth layer khác nhau
- thiếu section route sẽ buộc runtime phải đoán

Khi đó phải emit lý do escalation rõ ràng.

### 9.3.1 Invalidation sau CR

Khi `impact` xác định một CR ảnh hưởng đến source-of-truth hoặc downstream artifact, nó phải đánh dấu index và memory nào có thể stale.

Invalidation rules:

- scope hoặc goal đổi: `intake`, `plan`, `backbone`, `backbone_index`, downstream indexes, và project memory có thể stale
- FR/NFR intent đổi: `backbone`, `backbone_index`, `stories`, `stories_index`, SRS-related indexes có thể stale
- story acceptance detail đổi: `stories`, `stories_index`, SRS indexes có thể stale
- UC/SCR/rule/message đổi: `srs`, `srs_index`, `wireframe_input`, `wireframe_map` có thể stale
- navigation hoặc screen behavior đổi: `srs_index`, `wireframe_input`, `wireframe_map`, `design_doc` có thể stale

`impact` không cần tự sửa các artifact này, nhưng phải đưa stale set vào output để rerun path biết artifact điều hướng nào cần refresh.

### 9.4 Rerun path nhỏ nhất

`impact` không nên đề xuất rerun toàn flow theo mặc định.

Ví dụ:

- scope đổi -> `intake -> backbone -> downstream gated rerun`
- FR intent đổi nhưng không đổi scope lock -> `backbone -> stories`
- validation flow đổi -> `srs`
- screen behavior đổi -> `srs -> wireframes`

## 10. Kích hoạt shard/index theo kích thước context

Thiết kế hiện tại kích hoạt chủ yếu theo module/owner/delegation. Điều đó chưa đủ cho mục tiêu giảm token nhanh.

Thiết kế mới nên bổ sung activation theo kích thước context, ví dụ:

- source chunk count
- tổng bytes của `backbone`
- tổng bytes của emitted artifact
- số section hoặc trace node vượt ngưỡng

Ngưỡng đề xuất ban đầu:

- `source_chunk_count >= 8` kích hoạt source index requirement
- `backbone_bytes >= 25 KB` bắt buộc downstream đọc `backbone_index` trước
- `stories_bytes >= 25 KB` bắt buộc sinh và dùng `stories_index`
- `srs_total_bytes >= 30 KB` bắt buộc sinh và dùng `srs_index`
- `artifact_total_bytes >= 80 KB` kích hoạt runtime context budget warning cho project set

Khi vượt ngưỡng:

- ép chuyển sang index-first navigation
- không giữ compact-only mode quá lâu
- không cho downstream full-read mặc định

## 11. Kiểm thử và chứng minh thiết kế

### 11.1 Contract/parity tests nên có

- input lớn `md/txt` không được đọc thẳng
- project một module nhưng source hoặc backbone lớn vẫn phải auto vào index/shard mode
- `impact` chỉ mở artifact sở hữu node bị đổi trong case thông thường
- `package` không reread full flow
- `wireframes` không kéo ngược nhiều upstream source khi `wireframe-input` đã đủ

### 11.2 Budget measurement nên bổ sung

Ngoài instruction budget, cần thêm runtime context budget estimator cho từng command:

- `intake`
- `options`
- `backbone`
- `frd`
- `stories`
- `srs`
- `impact`
- `wireframes`
- `package`

Mục tiêu:

- thấy trước command nào đang đọc quá nhiều
- phát hiện regression sớm
- chứng minh tối ưu có hiệu quả trên project thật

## 12. Metadata freshness cho index

Mỗi index phải có metadata đủ để runtime biết index còn đáng tin hay đã stale.

Metadata tối thiểu:

- `index_type`: `source_chunk | backbone | stories | srs`
- `source_artifact`: path artifact gốc
- `source_hash`: hash nội dung artifact gốc tại thời điểm index được sinh
- `generated_at`: thời điểm sinh index
- `generated_by_command`: command sinh hoặc refresh index
- `stale_status`: `current | possibly-stale | stale`
- `coverage_summary`: mô tả ngắn index đang cover phần nào

Quy tắc freshness:

- nếu `source_hash` không khớp artifact hiện tại, index là `stale`
- nếu `impact` đánh dấu artifact có thể bị ảnh hưởng nhưng rerun chưa chạy, index là `possibly-stale`
- nếu index thiếu metadata freshness, runtime phải xem index là `possibly-stale`
- downstream command được dùng `possibly-stale` index để route sơ bộ, nhưng phải emit warning và xác nhận bằng section liên quan trước khi viết artifact

## 13. Failure và degraded behavior

Thiết kế compression-first cần nói rõ khi nào fail, khi nào degrade.

### 13.1 Source extraction

- Nếu input lớn vượt ngưỡng nhưng `source-extract` không chạy được, `intake` phải stop và báo lý do.
- Nếu source nhỏ hơn ngưỡng, có thể đọc trực tiếp nhưng vẫn nên ghi nhận rằng source không được cached.
- Nếu `chunk-index.md` không sinh được khi `chunk_count >= 8`, `intake` phải stop thay vì tiếp tục bằng broad-read.

### 13.2 Backbone index

- Sau khi tạo hoặc rerun `backbone.md`, nếu backbone dưới `25 KB` mà index generation fail, runtime có thể tiếp tục với warning.
- Nếu backbone từ `25 KB` trở lên mà `backbone-index.md` không sinh được, downstream index-first enforcement phải block cho đến khi index được tạo.
- Nếu downstream command thấy `backbone-index.md` stale, nó phải refresh index hoặc emit `READ_ESCALATION` trước khi mở full backbone.

### 13.3 Stories và SRS index

- Nếu `stories` hoặc `SRS` vượt ngưỡng mà index thiếu, command tiếp theo phải stop và yêu cầu refresh index.
- Nếu artifact nhỏ hơn ngưỡng, full-read fallback được phép trong giai đoạn chuyển tiếp nhưng phải ghi rõ degraded behavior.

### 13.4 Package

- `package` được phép đọc full artifact đang convert sang HTML.
- `package` không được đọc full artifact chỉ để khám phá cross-reference khi index hợp lệ đã tồn tại.
- Nếu index bị stale, `package` phải report stale index và stop hoặc yêu cầu refresh, không tự quét toàn bộ project set.

### 13.5 Impact

- Nếu CR map được vào node cụ thể, `impact` phải dùng delta-first path.
- Nếu CR không map được vào node cụ thể, `impact` được escalation nhưng phải emit `READ_ESCALATION`.
- Nếu escalation làm read scope vượt budget, `impact` phải dừng với focused questions thay vì quét toàn bộ artifact set.

## 14. Implementation decomposition

Không nên triển khai thiết kế này như một plan lớn. Scope nên tách thành bốn implementation plan độc lập.

### Plan 1 - Contract và index artifacts

Mục tiêu:

- thêm paths cho `source_chunk_index`, `backbone_index`, `stories_index`, `srs_index`
- thêm template tối thiểu cho từng index
- thêm outputs vào `core/contract.yaml`
- thêm contract/parity checks cho path và read-scope envelope

Không làm trong plan này:

- chưa đổi downstream behavior sang index-first
- chưa enforce size-based activation

### Plan 2 - Source extract hardening

Mục tiêu:

- nâng `source-extract` để sinh `chunk-index.md`
- áp dụng threshold input lớn cho `md/txt`
- giảm chunk size mặc định
- xử lý pasted text lớn bằng source cache
- thêm test chứng minh input lớn không bị đọc thẳng

Đây là plan có tác động token nhanh nhất.

### Plan 3 - Backbone, stories, và SRS index-first reads

Mục tiêu:

- sinh `backbone-index.md` sau backbone
- sinh `user-stories-index.md` sau stories
- sinh `srs-index.md` sau SRS assembly
- sửa `frd`, `stories`, và `srs` để đọc index trước rồi mới mở section liên quan

Điều kiện vào plan:

- Plan 1 đã có contract paths
- Plan 2 đã ổn định source-side index behavior

### Plan 4 - Impact, package, và runtime context budget

Mục tiêu:

- đổi `impact` sang delta-first
- thêm output schema cho `affected_node_ids`, `owner_artifact`, `stale_artifacts`, `read_escalation`
- siết `package` bằng index read contract
- thêm runtime context budget estimator
- bật size-based enforcement sau khi index coverage đủ

Điều kiện vào plan:

- Plan 3 đã có index coverage cho backbone/stories/SRS

## 15. Thứ tự triển khai khuyến nghị

### Pha 0 - contract hóa artifact điều hướng

1. thêm paths cho `source_chunk_index`, `backbone_index`, `stories_index`, `srs_index`
2. thêm template tối thiểu cho từng index
3. thêm outputs vào command contract
4. thêm parity fixtures kiểm tra path và read-scope envelope

### Pha 1 - nâng source-extract và khóa raw input

1. bắt buộc `source-extract` cho input lớn, kể cả `md/txt`
2. sinh `chunk-index.md`
3. cấm downstream reread raw source theo mặc định
4. thêm test cho input lớn `md/txt` không được đọc thẳng

### Pha 2 - giảm broad-read ở source of truth layer

1. sinh `backbone index`
2. sinh index nhẹ cho artifact lớn
3. đổi downstream reads sang `index -> targeted section`

### Pha 3 - khóa exception path

1. đổi `impact` sang `delta-first`
2. thêm invalidation rules sau CR
3. siết `package` và fallback path
4. thêm escalation evidence rõ ràng

### Pha 3.5 - bật size-based enforcement

1. thêm thresholds vào `core/contract.yaml`
2. enforce index-first khi vượt ngưỡng
3. thêm runtime context budget estimator
4. thêm regression tests cho từng command lớn

### Pha 4 - hạ baseline cố định

1. tách thêm deterministic prose khỏi `contract-behavior.md`
2. chuyển thêm logic sang machine-readable manifest hoặc CLI helper

## 16. Rủi ro và trade-off

### Trade-off chấp nhận

- flow sẽ chặt hơn
- artifact phụ sẽ nhiều hơn
- một số thao tác ad hoc sẽ kém linh hoạt hơn

### Rủi ro cần kiểm soát

- index phụ bị phình to và thành monolith mới
- kích hoạt shard quá sớm gây phức tạp không cần thiết cho dự án nhỏ
- `impact` mapping quá cứng làm bỏ sót ảnh hưởng thực

### Cách giảm rủi ro

- giữ index chỉ là navigator, không nhồi nội dung chi tiết
- dùng threshold rõ ràng cho context-size activation
- cho phép escalation có lý do thay vì cấm tuyệt đối

## 17. Kết luận

Nếu mục tiêu số một là giảm token nhanh nhất, BA-kit không nên chỉ vá guardrail.

Thiết kế đúng là:

- ép `source-extract` thành cổng mặc định cho input lớn
- ép full flow đi theo read ladder
- sinh thêm lớp điều hướng nhỏ trước tài liệu lớn
- chuyển `impact` sang `delta-first`
- đo runtime context budget như một chỉ số hạng nhất

Đây là hướng có tác động lớn nhất lên bài toán `150,000+` input token và phù hợp với ưu tiên compression-first.
