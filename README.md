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
- 台幣定價：有填就用；沒填 = 原價(日幣) × 匯率
- 實際購買價（＝總成本）= 台幣定價 + 運費 + 手續費 + 海關稅 − 折扣；也可以直接填最終付款金額覆蓋
- 總賣出價 = 狀態為「已售出」那幾隻的賣出價合計
- 利潤 = 總賣出價 − 總成本；還有沒賣的會另外顯示「全賣完」的預估（未售的用定價算）
- 每隻分攤成本：把「總成本」分給每一隻。每隻都填了日幣價就按比例分，否則平均
- 這隻利潤 = 賣出價 − 分攤成本
- 分帳：已售出的每一隻可勾「已分帳」；統計頁顯示未分帳貨款總額與明細，可勾選多隻一次標記
- 購買平台統計：額外費用 = 實際購買價 − 台幣定價；費用比例 = 額外費用 ÷ 台幣定價
- 每月統計：成本算在購買月份，賣出算在售出日期的月份
- 售出通路：依售出位置、交易方式分組，期間依售出日期
- 標籤統計：一筆有多個標籤時分別計入每個標籤

## 每一隻的圖片
點圖片框上傳、拖曳，或點一下圖片框再 Ctrl+V 貼上；「從主圖裁切」可以直接在整張圖上框出那一隻。
用外部網址當主圖時，瀏覽器不允許裁切，要改成上傳。

## 購買證明
新增／編輯記錄的「購買證明」區可以放多張截圖（訂單頁、付款紀錄等）。點「＋」可一次選多張，也能拖曳或點一下該區再 Ctrl+V。
雲端模式會保留較高解析度（長邊 2000px），讓文字看得清楚。首頁名稱下方的「購買證明 N」可以直接開啟瀏覽，左右鍵切換。

## 升級
每次改版到 Supabase SQL Editor 把 `schema.sql` 整份再執行一次，會補上新欄位，舊資料不受影響。

## 注意
GitHub Pages 條款不允許用來經營商業網站；這是內部管理工具（不對外販售）通常沒問題，若要更保險可改放 Cloudflare Pages，檔案不用改。
