# Flutter 飲食紀錄應用程式技術規格說明

## 1. 專案概述

本文件旨在提供 Flutter 飲食記錄應用程式的技術架構、UI 設計、API 整合、狀態管理及樣式資源使用規範，以確保開發團隊能依循一致的標準進行開發與維護。

## 2. 專案架構與啟動流程

應用程式的啟動點為 [`lib/main.dart`](lib/main.dart) 中的 `main()` 函式。
1.  `WidgetsFlutterBinding.ensureInitialized()`: 確保 Flutter 框架初始化完成。
2.  `dotenv.load(fileName: ".env")`: 載入 `.env` 檔案中的環境變數，用於配置 API 端點等敏感資訊。
3.  `runApp(const MyApp())`: 啟動根 Widget `MyApp`。

[`MyApp`](lib/main.dart) 是一個 [`StatelessWidget`](lib/main.dart)，負責配置應用程式級別的狀態管理 (`MultiProvider`) 和路由。目前主要提供 [`GoalStore`](lib/stores/goal_store.dart) 實例。

### 頁面路由 (Named Routes)

-   `/`: [`HomePage`](lib/pages/home_page.dart) - 應用程式主頁，展示每日飲食目標進度。
-   `/record`: [`RecordPage`](lib/pages/record_page.dart) - 餐點記錄頁面。
-   `/history`: [`HistoryPage`](lib/pages/history_page.dart) - 歷史記錄頁面（目前為佔位頁）。

頁面導航使用 `Navigator.pushNamed` 和 `Navigator.pushReplacementNamed` 實現。

## 3. 資料模型

專案定義了兩個核心資料模型，位於 [`lib/models/`](lib/models/) 目錄下：

### 3.1 [`DayTotals`](lib/models/day_totals.dart)

-   **用途**: 表示某一天的營養攝取總計。
-   **屬性**:
    -   `date`: `DateTime` (日期)
    -   `wholeGrains`: `double` (全穀物攝取量)
    -   `vegetables`: `double` (蔬菜攝取量)
    -   `proteinTotal`: `double` (蛋白質總量)
    -   `junkFood`: `double` (垃圾食物攝取量)
-   **方法**:
    -   `fromJson(Map<String, dynamic> json)`: 工廠方法，將 JSON 數據反序列化為 `DayTotals` 物件。

### 3.2 [`MealRecord`](lib/models/meal_record.dart)

-   **用途**: 表示單一餐點的詳細記錄。
-   **屬性**:
    -   `id`: `String` (記錄 ID)
    -   `createdAt`: `DateTime` (創建時間)
    -   `date`: `DateTime` (餐點日期)
    -   `meal`: `String` (餐別，如 "Breakfast", "Lunch", "Dinner", "Snack")
    -   `wholeGrains`: `double`
    -   `vegetables`: `double`
    -   `proteinLow`: `double` (低脂蛋白質)
    -   `proteinMed`: `double` (中脂蛋白質)
    -   `proteinHigh`: `double` (高脂蛋白質)
    -   `proteinXHigh`: `double` (特高脂蛋白質)
    -   `junkFood`: `double`
    -   `note`: `String?` (備註，可選)
    -   `imageUrl`: `String?` (圖片 URL，可選)
-   **方法**:
    -   `fromJson(Map<String, dynamic> json)`: 工廠方法，將 JSON 數據反序列化為 `MealRecord` 物件。

## 4. API 服務整合

API 服務整合由 [`lib/services/api_client.dart`](lib/services/api_client.dart) 中的 `ApiClient` 類別負責。

-   **API Base URL**: `_apiBase` 常量定義為 `https://dietapi.zeabur.app`。
-   **日期格式化**: `_yyyyMmDd()` 靜態輔助方法用於將 `DateTime` 物件格式化為 `yyyy-MM-dd` 字符串。

### 4.1 API 規格

| 功能 | Method | Endpoint | Request Body (JSON) | Response (JSON) |
| :---------------- | :----- | :--------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :----------------------------------------------------------------------------- |
| 取得每日統計        | `GET`    | `/summary?date={date}` | 無                                                                                                                                                                                                                           | `{ "date": "yyyy-MM-dd", "wholeGrains": 1.0, "vegetables": 1.0, "proteinTotal": 1.0, "junkFood": 1.0 }` |
| 建立餐點紀錄        | `POST`   | `/records`             | `{ "date": "yyyy-MM-dd", "meal": "Breakfast", "wholeGrains": 1.0, "vegetables": 1.0, "proteinLow": 0.0, "proteinMed": 0.0, "proteinHigh": 0.0, "proteinXHigh": 0.0, "junkFood": 0.0, "note": "...", "imageUrl": "..." }` | `{ "id": "uuid", "createdAt": "iso-date", ... }` (返回 MealRecord 物件)      |
| 查詢指定日期紀錄    | `GET`    | `/records?date={date}` | 無                                                                                                                                                                                                                           | `[ { "id": "uuid", "createdAt": "iso-date", ... }, ... ]` (MealRecord 物件陣列) |

-   **HTTP Headers**: 所有請求均包含 `Accept: application/json` 和 `Content-Type: application/json` (POST 請求)。
-   **錯誤處理**: 檢查 HTTP 狀態碼 (非 200 時拋出異常) 及 JSON 解析錯誤。

## 5. UI 結構與頁面功能

### 5.1 [`HomePage`](lib/pages/home_page.dart)

-   **佈局**: 頂部導航欄，下方為 `Expanded` 區域，包含背景圖片、半透明疊加層和 `SingleChildScrollView`。
-   **Hero Section**: 顯示應用程式歡迎語句 ("Your goals start with a meal.")，使用 `GoogleFonts.handlee` 字體。
-   **目標卡片區**: 透過 `PageView.builder` 顯示多天飲食目標進度，每張卡片為 [`GoalCard`](lib/widgets/goal_card.dart)。支援左右滑動切換日期。
-   **響應式設計**: 根據螢幕寬度調整內邊距、字體大小和卡片佈局（手機 2x2 網格，桌面橫向排列）。
-   **數據狀態**: 顯示載入指示器、錯誤訊息或重試按鈕。

### 5.2 [`RecordPage`](lib/pages/record_page.dart)

-   **佈局**: 導航欄與背景設計與 `HomePage` 類似。
-   **表單區域**: 包含用於餐點記錄的 `Form`。
    -   **日期選擇**: `DatePicker` 允許選擇餐點日期，禁用未來日期。
    -   **餐別選擇**: `DropdownButton` 選擇「Breakfast」、「Lunch」、「Dinner」、「Snack」。
    -   **數值輸入**: `TextFormField` 輸入全穀物、蔬菜、蛋白質和垃圾食物的數量。
    -   **圖片上傳**: `_ImageUploadSection` 支援拖放或點擊上傳圖片，顯示預覽圖、替換/移除按鈕。
    -   **提交按鈕**: 觸發 `_submitForm` 方法，將數據通過 API 提交至後端。
-   **當日記錄區**: `DailyRecordsSection` Widget 顯示當前日期已記錄的所有餐點，每筆記錄以 `_RecordCard` 呈現。
-   **響應式設計**: 表單佈局和圖片上傳區根據螢幕寬度調整為單列或雙列。

### 5.3 [`HistoryPage`](lib/pages/history_page.dart)

-   **功能**: 目前為骨架頁面，僅顯示 `AppBar` 和「History Page」文本。
-   **未來規劃**: 應實現日期範圍選擇、歷史記錄列表顯示（時間軸或卡片形式）、以及可能的數據圖表化展示。

## 6. 狀態管理

應用程式主要使用 `Provider` 套件進行狀態管理，核心邏輯位於 [`lib/stores/goal_store.dart`](lib/stores/goal_store.dart) 中的 `GoalStore` 類別。

### 6.1 [`GoalStore`](lib/stores/goal_store.dart)

-   **基礎**: 繼承自 `ChangeNotifier`，使 Widgets 能監聽其狀態變化。
-   **數據儲存**: 內部維護 `_dayTotals` ([`DayTotals`](lib/models/day_totals.dart) 列表) 儲存多天營養總計。
-   **目標定義**: 定義固定的目標值，如 `wholeGrainsGoal`、`proteinGoal`。
-   **進度計算**: 提供 `wholeGrainsProgress`、`proteinProgress`、`vegetablesProgress` 和 `junkFoodProgress` 等 getter，計算達成進度 (0.0 到 1.0)。垃圾食物進度在 `current > 0` 時會特別標示。
-   **數據載入**: `loadDays({required DateTime from, required DateTime to})` 方法呼叫 `ApiClient.fetchDailySummary` 載入指定日期範圍數據，處理載入狀態 (`isLoading`) 和錯誤訊息 (`errorMessage`)，並在數據更新後呼叫 `notifyListeners()`。
-   **數據暴露**: `days` getter 將內部 `_dayTotals` 轉換為 `List<DailyProgress>` 供 UI 使用。

### 6.2 狀態互動範例

-   **`HomePage`**: 在 `initState` 中使用 `context.read<GoalStore>().loadDays()` 初始化數據，並使用 `context.watch<GoalStore>()` 監聽變化以更新 UI。
-   **`RecordPage`**: 成功提交新餐點記錄後，使用 `Provider.of<GoalStore>(context, listen: false).loadDays(...)` 觸發 `GoalStore` 重新載入數據，更新 `HomePage` 進度顯示。

## 7. 共用 UI 組件

### 7.1 [`GoalCard`](lib/widgets/goal_card.dart)

-   **用途**: 顯示單一飲食目標進度的可重用卡片。
-   **動態樣式**: 根據 `title` 屬性 ("Whole Grains", "Protein", "Vegetables", "Junk Food") 動態設定背景色、文本色和進度條色。
-   **進度顯示**: 顯示當前值 (`current`) 和目標值 (`goal`)，可選圓形進度條 (`showCircularProgress`)。
-   **響應式字體**: 透過 `isMobileView` 參數調整字體大小。
-   **特殊處理**: 垃圾食物 `current` 值大於 0 時，進度條和文本顯示為紅色。

### 7.2 `_ImageUploadSection` (在 [`RecordPage`](lib/pages/record_page.dart) 內部)

-   **功能**: 處理餐點圖片上傳。
-   **互動**: 支援拖放上傳、點擊開啟文件選擇器。
-   **視覺**: 顯示圖片預覽，提供「Replace」和「Remove」按鈕。
-   **樣式**: 使用 `dotted_border` 套件創建虛線邊框，響應式調整容器高度。

### 7.3 `DailyRecordsSection` (在 [`RecordPage`](lib/pages/record_page.dart) 內部)

-   **功能**: 顯示指定日期下所有已記錄餐點。
-   **數據載入**: 使用 `FutureBuilder` 異步載入數據，顯示載入指示器或錯誤訊息。
-   **佈局**: 透過 `GridView.builder` 以卡片形式 (`_RecordCard`) 佈局餐點記錄，根據螢幕寬度調整列數。

### 7.4 `_RecordCard` (在 [`RecordPage`](lib/pages/record_page.dart) 內部)

-   **用途**: 顯示單一餐點記錄的詳細資訊。
-   **內容**: 包含餐點圖片 (若有)、餐別標籤、時間、各項營養攝取量。

## 8. 設計規範 (Design System)

### 8.1 色彩規範

| 色彩用途     | Hex 值       | 應用場景                               |
| :----------- | :----------- | :------------------------------------- |
| 主背景色     | `#FFF9F3`    | 全局背景，提供柔和基調                 |
| 強調色       | `#EFC3BD`    | 按鈕、重要連結、目標卡片背景           |
| 成功提示色   | `#A7D8B2`    | 完成、達成目標提示                     |
| 警示色       | `#EF4444`    | 錯誤、超標、需要注意的訊息             |
| 主要文字色   | `#4B5563`    | 一般文本、標題                         |
| 次要文字色   | `#8899A6`    | 輔助說明、次要資訊                     |
| 全穀物卡片色 | `#F5E8CF`    | GoalCard - 全穀物背景                  |
| 蛋白質卡片色 | `#EFC3BD`    | GoalCard - 蛋白質背景                  |
| 蔬菜卡片色   | `#EEE2D3`    | GoalCard - 蔬菜背景                    |
| 垃圾食物卡片色 | `#DED3D6` | GoalCard - 垃圾食物背景                |

### 8.2 字體規範

-   **主標題 (H1/H2)**: Fredoka (字重 `FontWeight.w700` 或 `FontWeight.w600`)
-   **內文/副標題**: Poppins (字重 `FontWeight.w400` 至 `FontWeight.w600`)
-   **特殊標語 (Hero Section)**: Handlee (字重 `FontWeight.w400`)
    -   字體文件: [`assets/fonts/Handlee-Regular.ttf`](assets/fonts/Handlee-Regular.ttf)
-   **字體大小**：
    -   H1: 28-32pt (桌面), 24-28pt (行動)
    -   H2: 20-24pt (桌面), 18-22pt (行動)
    -   內文: 14-16pt
    -   輔助文字: 12-14pt

### 8.3 間距與佈局

-   **主要區塊間距**: 垂直/水平 `24px`。
-   **次要元件間距**: 垂直/水平 `12px`。
-   **圓角半徑**: 常用圓角 `8px` 或 `12px`。
-   **卡片寬高比**: 建議約 `4:3`。
-   **文字行高**: 建議 `1.5` 倍字體大小。

### 8.4 動畫與互動規範

-   **反應時間**: 所有互動回饋應在 `150ms` 內完成。
-   **按鈕點擊**: 點擊時應有 `0.95` 比例的縮放動畫。
-   **頁面轉換**: 使用標準的淡入淡出 (Fade-in/Fade-out) 或輕微滑動 (Slide) 動畫。
-   **數據更新**: 進度條 (Progress Bar) 應以 `600ms` 的緩衝 (Ease-out) 動畫漸進填滿。
-   **載入狀態**: 顯示統一的 `CircularProgressIndicator` 或簡潔的骨架屏。

## 9. 開發原則

1.  **模組化**: 每個頁面、功能區塊應獨立為 Widget 或組件，職責清晰。
2.  **狀態分離**: UI 邏輯與業務邏輯分離，透過 `Provider` 管理應用狀態，避免在 Widget 內部直接操作複雜狀態。
3.  **命名規範**: 遵循 Flutter 官方命名規範，變數、函數、類名應具備語義化。
4.  **響應式設計**: 考慮不同螢幕尺寸（手機、平板、桌面）的佈局適應性。
5.  **錯誤處理**: 所有 API 請求和潛在的運行時錯誤都應具備明確的錯誤處理機制和使用者提示。

## 10. 最終成果驗收標準

-   **功能完整性**: 所有已實現功能（Home, Record 頁面核心功能）應按預期運作。
-   **UI 一致性**: 所有頁面和組件的顏色、字體、間距、圓角等視覺元素必須與設計規範一致。
-   **互動流暢性**: 頁面導航、按鈕點擊、數據更新等互動應流暢且具備規範的動畫回饋。
-   **數據準確性**: API 數據的顯示與處理必須正確無誤。
-   **跨平台兼容性**: 應用程式應在主流瀏覽器和裝置上正常顯示與運作。
-   **文件可追溯性**: 新開發者應能透過此 `spec.md` 文件，清楚理解並重現應用程式的核心功能與設計理念。

---

**版本：v3.0 – 實用開發指南**  
_文件理念：精確指引，確保開發與設計一致性。_
