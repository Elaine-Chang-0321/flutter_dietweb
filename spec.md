# Diet Web – 首頁改版規格（文字化樣式說明）

## 0. 架構與檔案
- `lib/main.dart`：入口，只負責 `runApp` 與路由設定。
- `lib/pages/home_page.dart`：首頁（本文件描述的畫面）。
- `lib/pages/record_page.dart`：Record Meal 空頁（之後會實作）。
- `lib/pages/history_page.dart`：History 空頁（之後會實作）。
- `lib/widgets/goal_card.dart`：下方四張目標卡的共用元件。
- `lib/stores/goal_store.dart`：今日目標/進度的暫存資料（記憶體）。

> 路由  
`/` → Home, `/record` → Record Meal, `/history` → History

---

## 1. 頁面目標
- 首頁即時呈現「今日飲食目標達成狀況」。
- 四張卡片顯示四大分類的「今日攝取 / 目標」與視覺化進度。
- 導覽列可前往「紀錄飲食（Record Meal）」與「過去紀錄（History）」。

---

## 2. 版面與區塊（自上而下）

### 2.1 頂端列（Navigation Bar）
- **背景**：純白 `#FFFFFF`，底部 1px 分隔線或淺陰影（`rgba(0,0,0,0.06)`，blur 12）。
- **高度**：64 px（桌機）；行高與內容垂直置中。
- **左右間距**：頁面左右內距 24 px（mobile）、48 px（tablet）、72 px（desktop ≥1024px）。
- **內容排版**：左右分佈（左 logo/字標、右導覽）。
  - **左側字標**：文字 “Diet Web”，字色 `#111827`，字重 700，字級 18。
  - **右側導覽**：水平橫排兩個按鈕：
    - “Record Meal”、 “History”
    - 字色預設 `#374151`、Hover 時 `#111827`；目前頁面（首頁）對應導覽項以粗體或底線高亮。
    - 按鈕左右間距 20 px；點擊區塊高度≥40 px 以利觸控。

> 可存取性：導覽項可 Tab 聚焦；聚焦態加 2px 外框（`#3B82F6`）。

---

### 2.2 Hero 區（主標區）
- **背景**：極淺灰 `#F7F7F8`（與頂端列白色有層次）。
- **垂直內距**：上 64 px、下 48 px（桌機）；行動裝置可減為 48/32。
- **主標文字**：  
  - 內容：`Your goals start with a meal.`
  - 對齊：置中
  - 字色：`#111827`
  - 字級：桌機 56–64、平板 48、手機 36
  - 字重：800
  - 字距：+0.5
- **次標（可選）**：若加入一句說明，使用 `#6B7280`、字級 16–18、行高 1.6，置中。

---

### 2.3 內容容器（整體寬度限制）
- **最大內容寬度**：`max-width: 1120px`；置中。
- 兩側留白依前述 RWD 內距規則。

---

### 2.4 目標卡片區（四張卡）
- **區塊外距**：與 Hero 區之間間距 40 px（mobile 32）。
- **排版**：
  - 桌機（≥1024px）：四欄（每欄 1 卡，欄距 16–20 px）
  - 平板（600–1023px）：兩欄兩列
  - 手機（<600px）：一欄四列、每卡寬度 100%
- **每張卡片**：
  - **外觀**：
    - 背景色（依序四張）：
      1. Warm Grey `#D6D1CF`
      2. Beige Grey `#E5DBD5`
      3. Soft Pink `#F2C9C4`
      4. Tan `#D8C1AA`
    - 圓角：16–20
    - 陰影：`rgba(0,0,0,0.10)`，Y=10，blur=24，spread=-4
    - 內距：上 24、左右 24、下 20（mobile 可 16）
    - 最小寬：240 px；最小高：220 px
  - **內容層級與樣式**（由上而下、置左對齊；手機可置中）：
    1. **序號**（如 “1.”、“2.” …）  
       字級 16、字重 700、字色 `#111827`、下方間距 8。
    2. **分類標題**（粗體大字）  
       - 四張卡標題依序為：  
         - `Whole Grains`  
         - `Protein (Eggs/Beans/Fish/Meat)`（若空間不足可只寫 `Protein`）  
         - `Vegetables`  
         - `Junk Food`
       - 字級 18–20、字重 700、字色 `#111827`、行高 1.3、下方間距 8。
    3. **數據行**  
       - 文字： `Today: {current} / Goal: {goal} servings`  
       - 字級 14–16、字色 `#374151`、行高 1.6。
       - {current} 以數字強調（700）。
    4. **進度條**（位於卡片底部上方 12 px）  
       - 高度 10–12 px、圓角與卡片一致。  
       - 背景 `rgba(0,0,0,0.08)`。  
       - 填滿色預設使用綠色 `#16A34A`。  
       - **Junk Food 特例**：  
         - 目標為 0，邏輯為「越少越好」。  
         - 建議顯示**反向進度**：  
           - 若 `current == 0` → 進度 100% 並顯示綠色 `#16A34A`。  
           - 若 `current > 0` → 進度 = `max(0, 1 - (current / 1))`，且改用紅色 `#EF4444`（或橙色 `#F59E0B` 視覺提醒）；同時在數據行後加小字 `(reduce intake)`、字色 `#B91C1C`。
  - **互動**：暫無按鈕；Hover 整卡可略微抬升（translateY(-2px) + 陰影加深 10%）。

---

## 3. 色彩與字體
- **主字色**：`#111827`
- **次字色**：`#374151`
- **弱字色/輔助**：`#6B7280`
- **背景**：頁面底 `#F7F7F8`；卡片用前述粉彩四色。
- **強調色（進度條正常）**：綠 `#16A34A`
- **警示色（Junk Food 超標）**：紅 `#EF4444`
- **字體**：系統字體即可；若可加入 `google_fonts`，偏好 **Poppins** 或 **DM Sans**。
  - 標題字重 700–800；正文 400–500。

---

## 4. 互動與狀態
- 導覽項：Hover 變色、底線或字重加粗；Focus 狀態加 2px 藍色外框 `#3B82F6`。
- 進度條：比例動畫 150–250ms 緩動（ease-out）。
- RWD：版面在 3 個斷點調整：
  - **mobile** `<600px`
  - **tablet** `600–1023px`
  - **desktop** `≥1024px`

---

## 5. 資料與邏輯

### 5.1 固定目標值
| 類別 (id) | 顯示標題 | 目標 (goal) |
|---|---|---|
| grains  | Whole Grains | 5  |
| protein | Protein (Eggs/Beans/Fish/Meat) | 10 |
| veggies | Vegetables | 3  |
| junk    | Junk Food | 0  |

### 5.2 當日目前值
- `current`（整數），預設皆為 0。之後會由紀錄頁帶入。

### 5.3 進度計算
```text
一般三類：progress = clamp(current / goal, 0..1)
Junk Food：progress = (current == 0 ? 1 : max(0, 1 - current))  // 可視需求調整分母
色彩：一般綠色；Junk Food 當 current > 0 時顯示紅色
```

---

## 6. 可存取性（a11y）
- 文字與背景對比符合 WCAG AA（深色字搭配粉彩底 OK）。
- 進度條旁需有可被讀屏讀取的文字（例如 `Semantics` 包裹：「Whole Grains progress 60%」）。
- 導覽可鍵盤操作；Focus 樣式清晰。

---

## 7. 驗收標準（Acceptance Criteria）
1. 首頁 `/` 顯示頂端列（左 “Diet Web”、右 “Record Meal”、“History”）。
2. Hero 區置中顯示大字 **Your goals start with a meal.**
3. 下方四張卡，依序為 **Whole Grains / Protein / Vegetables / Junk Food**，  
   顯示 `Today: {current} / Goal: {goal} servings`；預設皆 0。
4. 進度條按規則正確顯示；Junk Food 在 `current=0` 時顯示 100% 並為綠色；`current>0` 時以紅色比例警示。
5. RWD：桌機四欄、平板兩欄、手機單欄；卡片在各裝置間距合理，最小寬 240。
6. 導覽可跳轉至 `/record` 與 `/history`；兩頁顯示頁名即可。
7. 本機 `flutter build web --release` 可通過；CI 成功；Zeabur 網站同步更新。

---

## 8. 交付產出
- `main.dart`（MaterialApp、Theme、routes）。
- `pages/home_page.dart`（含頂端列、Hero、卡片區）。
- `widgets/goal_card.dart`（可重用）。
- `stores/goal_store.dart`（暫存資料與計算）。
- `pages/record_page.dart`、`pages/history_page.dart`（基本骨架）。
- README（如何本機執行與部署）。

---

## 9. 文案（英文，請直接使用）
- Navbar: `Record Meal`, `History`
- Hero: `Your goals start with a meal.`
- Card subtitles:  
  - `Whole Grains`  
  - `Protein (Eggs/Beans/Fish/Meat)`  
  - `Vegetables`  
  - `Junk Food`
- Numbers row: `Today: {current} / Goal: {goal} servings`
