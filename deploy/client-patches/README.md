# Bản vá client Flash

Code game của client nằm trong `Source Flash/FlashSV1/2.png`. Thực chất đây là một file SWF (nén CWS),
được `DDT_Loading.swf` nạp vào. File trong repo **đã được vá sẵn**. Thư mục này lưu mã nguồn của bản vá
để có thể kiểm tra lại hoặc làm lại từ bản gốc.

## TaskManager-dedupe-quest-add.diff

**Lỗi:** khi nhân vật có nhiều nhiệm vụ mới cùng lúc (ví dụ GM nâng từ cấp 1 lên 10 bằng SQL),
`TaskManager.isAvailableQuest` gửi `QUEST_ADD` cho **mọi** nhiệm vụ chưa có dữ liệu, và gửi lại mỗi lần
nó được gọi. Hàm này chạy nhiều lần trong mỗi khung hình. Ruffle đẩy dữ liệu socket ra theo từng khung hình,
nên hàng nghìn gói trùng xếp hàng trước các gói vào sảnh hay tạo phòng: sảnh trống, bấm tạo phòng không có
tác dụng, cho đến khi đăng nhập lại.

**Sửa:** `socketSendQuestAdd` ghi nhớ những nhiệm vụ đang chờ server trả lời và không gửi lại. Khi
server gửi cập nhật cho nhiệm vụ đó (`__updateAcceptedTask`) thì xoá khỏi danh sách chờ, nên nhiệm vụ
lặp lại vẫn nhận lại được bình thường.

## Làm lại từ bản gốc

Cần Java và [JPEXS FFDec](https://github.com/jindrapetrik/jpexs-decompiler) (đã thử với bản 22.0.2):

```bash
git show <commit-trước-bản-vá>:"Source Flash/FlashSV1/2.png" > orig.swf
java -jar ffdec.jar -export script src orig.swf                 # dịch ngược
cp src/scripts/ddt/manager/TaskManager.as TaskManager.as
patch --ignore-whitespace TaskManager.as TaskManager-dedupe-quest-add.diff
java -jar ffdec.jar -replace orig.swf 2.png ddt.manager.TaskManager TaskManager.as
```
