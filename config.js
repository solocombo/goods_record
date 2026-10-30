// 商品紀錄系統設定
// 兩個都留 null：資料存在這台裝置的瀏覽器裡（本機模式，可先試用）。
// 填入 Supabase 專案的 URL 和 anon (publishable) key：改用雲端資料庫，需要登入。
// anon key 本來就是公開的，安全性靠資料表的 RLS（schema.sql 已設定）。
window.LEDGER_CONFIG = {
  supabaseUrl: "https://ctlkyzqleyazswcwymot.supabase.co", // 例如 'https://xxxxxxxx.supabase.co'
  supabaseAnonKey: "sb_publishable_kPdZtPSR8lmnSXJ6QE1akw_D3OttcMd", // 例如 'eyJhbGciOi...'
  defaultRate: 0.215, // 抓不到即時匯率時的預設 JPY→TWD
};
