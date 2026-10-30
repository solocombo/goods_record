# 商品紀錄系統（item-ledger）

單檔網頁＋Supabase。首頁是紀錄表，「每隻定價」點開小視窗編輯每一隻，統計頁有每月成本和標籤統計。

## 檔案
| 檔案 | 說明 |
|---|---|
| `index.html` | 整個程式（HTML＋CSS＋JS） |
| `config.js` | Supabase 網址與 key；留 `null` = 本機模式 |
| `supabase/schema.sql` | 資料表、RLS、照片空間 |

## 先試用（本機模式）
直接把 repo 推上 GitHub Pages，或本機 `python3 -m http.server` 開 `index.html`。
資料存在瀏覽器 localStorage，附 4 筆範例資料；可匯出／匯入 JSON。

## 接上 Supabase
1. 建新專案 → SQL Editor 貼上 `supabase/schema.sql` 執行。
2. Authentication → Sign In / Providers：**關掉 Allow new users to sign up**。
3. Authentication → Users → Add user：建你和合夥人的帳號（email＋密碼）。
4. Project Settings → API：複製 Project URL 和 anon key，填進 `config.js`。
5. 推上 GitHub，Settings → Pages → Deploy from branch（main / root）。

只有登入的帳號能讀寫；anon key 公開沒關係，權限靠 RLS 擋。
照片存在私有 bucket `item-photos`，網頁用 1 小時的簽名網址顯示，上傳前會壓成 WebP（長邊 1400px）。

## 計算方式
- 實際購買價：有填就用；沒填 = 原價(日幣) × 匯率
- 總成本 = 實際購買價 + 運費 + 手續費 − 折扣
- 總賣出價 = 狀態為「已售出」那幾隻的賣出價合計
- 利潤 = 總賣出價 − 總成本；還有沒賣的會另外顯示「全賣完」的預估（未售的用定價算）
- 每隻分攤成本：每隻都填了日幣價就按比例分，否則平均
- 每月統計：成本算在購買月份，賣出算在售出日期的月份
- 標籤統計：一筆有多個標籤時分別計入每個標籤

## 注意
GitHub Pages 條款不允許用來經營商業網站；這是內部管理工具（不對外販售）通常沒問題，若要更保險可改放 Cloudflare Pages，檔案不用改。
