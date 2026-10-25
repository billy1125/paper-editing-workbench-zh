# 編修輔助 Agent 與待辦彙整 Skill 設計

> 設計日期：2026-10-25。依據 `working-papers/lifestyle-privacy-disclosure/` 的編修紀錄（`revisions/` 110 筆、`progress.md`、`todo.md`、01–06 章節檔）歸納。
> 狀態：設計稿，尚未實作。實作前先處理第 9 節「待決定事項」。

---

## 1. 目的與範圍

在既有 skill 之外，加上兩個元件，輔助日常編修並提醒該注意的事：

- **編修輔助 Agent（`editing-assistant`）**：在固定時間點讀檔、回報提醒。只讀不寫，不改稿件、不取代既有 skill。
- **待辦彙整 Skill（`todo-consolidation`）**：把各章散落的待補事項、工作筆記、文內標記彙整成作用中論文的 `todo.md`，並在之後增量更新。做法取自 2026-10-25 建立 `todo.md` 的過程。

兩者都不改研究邏輯、主張、數據與引用，界線同 CLAUDE.md §1。

---

## 2. 依據：這篇論文的編修流程

### 2.1 工作類型

依 `revisions/` 的 `skill:` 欄統計：

| 類型 | 筆數 | 固定步驟 |
|---|---|---|
| 引用查證（`citation-source-verification`） | 36 | 查原文 → 回報位置與信心程度 → 使用者判斷 → 標 `[Verified]`／`[No Reference]`／`[Need Reference]` → 更新章末書目與查證結果表 |
| 段落校修（`passage-revision`） | 約 30 | 多版本 → 使用者挑選 → 替換 → 留底 → 更新 `progress.md` |
| 論證檢查（`argument-review`） | 7 | 檢查 → 替換修訂稿 → 跨章對齊 |
| 依使用者指示直接更新（未走 skill） | 約 37 | 處理 TODO、依統計報表補數值、重組章節、改檔名、匿名化 |

### 2.2 反覆出現的問題

| 問題 | 紀錄中的例子 |
|---|---|
| ⚠️ 觀察累積、沒有結案機制 | `revisions/` 共 67 行 ⚠️；`progress.md` 第 1 章備註一格寫成長文；2026-10-25 才另建 `todo.md` 彙整 |
| 研究模型變動後跨章沒同步 | 前因構面緒論 3 項、資料分析 4 項（含 PI）；調節效果在緒論是補充分析、在第 3 章是正式假設；摘要與題目仍寫 K-means 分群；「電子生活型態」與 e-lifestyle 混用 |
| 改寫後查證結果表過時 | 多筆紀錄指出查證結果表的文句片段、行號仍是改寫前的版本 |
| 書目分散、與 `reference.md` 不同步 | 各章各自維護書目；部分書目依記憶寫出；第 2 章沒有參考文獻清單；García-Fernández et al. (2020) 在 01、03 用法不一致 |
| 使用者在回合之間手改稿件 | 2026-10-19 使用者改回原段落後改採 V1 |
| 匿名化漏網 | Lu (2024) 多次在不同時間點被提醒未匿名化 |
| 改檔名使 skill 失效 | skill 寫死檔名，`Basic Information.md`、參考文獻檔被迫改回原名 |
| 待補事項處理後未同步標記 | `revisions/2026-10-23-method-todo-*`、`2026-10-25-data-analysis-todo-*` 逐項刪除或改寫 TODO，正文標記與章末清單需各自處理 |

---

## 3. 架構總覽

| 元件 | 位置 | 角色 | 會寫檔嗎 |
|---|---|---|---|
| `editing-assistant` Agent | `.claude/agents/editing-assistant.md`（跨論文共用） | 在 A–E 五個時間點讀檔，回報提醒與建議的 skill | 不寫 |
| `todo-consolidation` Skill | `.claude/skills/todo-consolidation/SKILL.md`（專案自有） | 建立與增量更新 `todo.md` | 只寫該篇 `todo.md` |
| `todo.md` | `working-papers/<title>/todo.md`（每篇一份） | 待辦與 ⚠️ 的唯一結案清單 | 由 skill 寫 |
| `consistency-map.md` | `working-papers/<title>/consistency-map.md`（每篇一份） | 全文共用事實與引用位置的對照表 | 由使用者或主對話經同意後寫 |
| hooks（選配） | `.claude/settings.json` | 在 session 開始、Edit 章節檔後插入提醒文字 | 不寫 |

分工：Agent 發現問題 → 主對話轉述給使用者 → 使用者決定 → 主對話跑對應 skill 處理；待辦類事項一律經 `todo-consolidation` 寫入 `todo.md`。

---

## 4. 編修輔助 Agent（`editing-assistant`）

### 4.1 Agent 檔草稿

```markdown
---
name: editing-assistant
description: Read-only checker for the active paper. Use at session start, before editing a passage, after adopting a version, at chapter wrap-up, and before submission. Reports reminders; never edits files.
tools: Read, Grep, Glob
---
```

本文（system prompt）要寫的內容：

1. 先讀根目錄 `CLAUDE.md`、`response-guide.md`，遵守 §1 界線。
2. 依輸入的時間點（A–E）讀第 4.3 節列的檔案。
3. 只回報檔案裡有的東西；每項附檔名與行號或節號；沒有依據的不寫。
4. 依第 4.4 節的格式輸出。

### 4.2 輸入

| 欄位 | 說明 |
|---|---|
| 論文 | `working-papers/<title>/` |
| 時間點 | A／B／C／D／E |
| 範圍 | 章節檔與段落（時間點 B、C 必填） |

### 4.3 五個時間點

| 時間點 | 讀哪些檔 | 檢查與提醒 |
|---|---|---|
| A. 開工／切換論文 | `style-guide.md`（不存在時讀 `writing-style/style-defaults.md`）、`Basic Information.md`、`progress.md`、`todo.md`、最近 3 筆 `revisions/` | 完成 CLAUDE.md §5 step 0 的複習並輸出確認行；列出未結案的 U 項；章節檔或 `revisions/` 的修改時間晚於 `todo.md` 的彙整日期時，建議跑 `todo-consolidation` |
| B. 動手改某段前 | 目標段落當下內容、該段相關的 `revisions/`、`todo.md`、`consistency-map.md` | 該段的文內標記；該段曾提出、未結案的 ⚠️；`todo.md` 中位置落在該段的 U 項；`consistency-map.md` 中該段涉及的事實與其他引用位置；提醒先重讀 live 文字 |
| C. 採用版本後 | 改過的章節檔、最新一筆 `revisions/`、`progress.md`、`reference.md` | 檢查清單：留底是否存在、`progress.md` 是否更新、行號位移是否影響查證結果表與 `todo.md` 的位置欄、書目是否與 `reference.md` 同步、新的 ⚠️ 是否已交給 `todo-consolidation` |
| D. 一章告一段落 | 全部章節檔、`consistency-map.md`、`todo.md` | 跨章規格比對（構面清單、假設編號、模型 1／2 設定、樣本數、用詞決定）；各類標記數量；該章工作筆記是否過時 |
| E. 投稿前 | 全部檔案 | 匿名化（作者姓名、自引、Word 屬性）；剩餘 `[No Reference]`、`[Need Reference]`、`[TODO]`；工作筆記與待補事項是否移出正文；摘要與題目是否與第 5、6 章結果一致；之後接 `final-consistency-sweep`、`markdown-to-word` |

### 4.4 輸出格式

固定四區，每區最多 5 項，超過時寫「另有 N 項，見 `todo.md`」：

```
已載入 <title>：style-guide（§9 規則 N 條）＋progress＋近 3 筆 revisions   ← 只在時間點 A

【動手前必須處理】
- 01.Introduction.md 第 13 行：García-Fernández et al. (2020) 仍是 [No Reference]（todo U-02）

【連動提醒】
- 改這段的前因構面，會牽動 03 §3.6、05 §5.3、06 §6.1.3（consistency-map：前因構面）

【待結案】
- revisions/2026-10-24-data-analysis-todo-8.md 的 ⚠️ 尚未出現在 todo.md

【建議 skill】
- citation-source-verification（U-02）
```

---

## 5. 待辦彙整 Skill（`todo-consolidation`）

### 5.1 用途與觸發

- 用途：讀作用中論文各章節檔的待辦來源，合併重複、核對正文，產生或更新該篇 `todo.md`。
- 觸發說法：「彙整待辦」「更新 todo」「整理各章 TODO」「看還有哪些沒處理」；或 Agent 在時間點 A／C／D 建議時。
- 不做：不改章節檔、不刪文內標記、不替使用者決定待作者決定的事項。刪除或改寫章節檔內的 TODO，照現行做法依使用者指示另行處理並留底（如 `revisions/2026-10-23-method-todo-3.md`）。

### 5.2 來源範圍

依 2026-10-25 `todo.md` 檔頭寫明的範圍：

| 來源 | 內容 |
|---|---|
| 各章章末 | 「待補事項」「工作筆記」「編修紀錄」節 |
| 文內標記 | `[TODO]`、`[No Reference]`、`[待補文獻]`、`[待確認…]` |
| 排除 | `progress.md` 的 ⚠️ 觀察 |

本設計另外加入 `[Need Reference]`（原 `todo.md` 的來源範圍沒有列）。`revisions/` 與 `progress.md` 的 ⚠️ 是否納入，見第 9 節。

### 5.3 步驟

1. **確認論文與章節**：依 `Basic Information.md` 的 `chapters` 取得章節檔清單，不自行增減。
2. **收集**：逐章抽出第 5.2 節的來源，記下檔名、行號、所在節號。
3. **合併重複**：同一事項出現在多處（例如章末待補與文內標記、或跨章同一筆文獻）合併為一項，「來源」欄列出合併前的所有出處。
4. **核對正文**：工作筆記仍列為待辦、但正文已處理的事項，歸入「已解決」，寫明處理情形與依據（正文行號或 `revisions/` 檔名）。核對不到依據時留在未解決，不推定已處理。
5. **分類**：依下表分組。

   | 代碼 | 分類 |
   |---|---|
   | A | 引用查證（原文缺漏或尚未查證） |
   | B | 參考文獻書目 |
   | C | 資料與數值 |
   | D | 理論依據待補文獻 |
   | E | 待作者決定（寫法與定位） |
   | F | 投稿前處理 |
   | G | 工作筆記整理 |

6. **寫項目**：每項包含下列欄位。

   | 欄位 | 必填 | 說明 |
   |---|---|---|
   | 編號＋標題 | 是 | `U-xx`（未解決）、`R-xx`（已解決） |
   | 位置 | 是 | 檔名＋行號或節號 |
   | 來源 | 是 | 合併前的出處 |
   | 現況 | 否 | 目前檔案裡的實際狀態 |
   | 建議作法 | 是 | 能用既有 skill 處理的寫出 skill 名；需作者決定的列選項 (a)(b)，不替作者選 |

7. **寫檔頭**：彙整日期、來源範圍、排除範圍、「行號以彙整日期的章節檔為準」、編號規則。
8. **回報**：只回報 `todo.md` 路徑、未解決與已解決的項數、本次新增與結案的編號。

### 5.4 增量更新規則

`todo.md` 已存在時：

- 既有編號不重排，其他檔案（`revisions/`、對話）引用的 U-xx 才不會失效。
- 已處理的 U 項改列到「已解決」，取得下一個 R 編號，並註明原 U 編號。
- 新事項取得下一個 U 編號，放進對應分類。
- 所有項目的位置欄依當下章節檔重算行號，檔頭彙整日期更新。

### 5.5 與其他 skill 的分工

| 情況 | 交給 |
|---|---|
| `[No Reference]` 補上原文、需重查 | `citation-source-verification` |
| 書目缺漏或待核對 | `citation-reference-management` |
| 用詞統一、全文一致性 | `final-consistency-sweep` |
| 跨章論證或模型規格不一致 | `argument-review` |
| 段落改寫 | `passage-revision` |

---

## 6. 連動對照表（`consistency-map.md`）

記錄全文共用、改一處就要同步他處的事實。每列一項：

| 事實 | 目前定案 | 出現位置 | 最後確認日 |
|---|---|---|---|
| 前因構面 | （例）IPC、PB、T、PI 四項 | 01 第 21、23 行；03 §3.6；05 §5.3；06 §6.1.3 | 2026-10-25 |
| 調節分析定位 | （例）補充分析 | 01 第 25 行；03 §3.7；05 §5.4 | |
| 樣本數、假設編號、模型 1／2 路徑數、核心用詞決定 | | | |

規則：

- 「目前定案」由使用者決定，Agent 與 skill 不自行填寫或修改。
- Agent 在時間點 B、D 依此表比對各「出現位置」的實際文字，不一致時列入【連動提醒】。
- 開新論文時由 `_TEMPLATE/` 提供空白表。

---

## 7. 自動觸發（選配）

| Hook 事件 | 條件 | 插入的提醒 |
|---|---|---|
| SessionStart | 專案內任一 session | 「請先呼叫 editing-assistant（時間點 A）並確認作用中論文」 |
| PostToolUse | Edit／Write 的路徑符合 `working-papers/*/0*.md` | 「已改章節檔，請呼叫 editing-assistant（時間點 C）」 |

hook 只插入文字，不會自己執行 Agent；是否呼叫仍由主對話判斷。章節檔路徑的比對樣式依各篇檔名調整。

---

## 8. 實作時需同步的檔案

| 檔案 | 改什麼 |
|---|---|
| `CLAUDE.md` §4 | 支援性 skill 表加 `todo-consolidation`；另加 agents 一節說明 `editing-assistant` |
| `CLAUDE.md` §5 | 日常編修循環在 step 0、step 5 加入呼叫 Agent 的時間點 |
| `CLAUDE.md` §7 | 目錄結構加 `.claude/agents/`，`<title>/` 列出 `todo.md`、`consistency-map.md`；skill 數量由 11 改為 12 |
| `working-papers/_TEMPLATE/` | 加空白 `todo.md`、`consistency-map.md` |
| `docs/NEW-PAPER.md` | 開新論文步驟加入上述兩檔 |

---

## 9. 待決定事項

1. **⚠️ 觀察是否納入 `todo.md`**：原 `todo.md` 排除 `progress.md` 的 ⚠️；本設計第 3 節把 `todo.md` 定為 ⚠️ 的唯一結案清單。兩者衝突，需選一：(a) 納入 `revisions/` 與 `progress.md` 的 ⚠️，另設一個分類；(b) 維持排除，⚠️ 另建清單。
progress.md僅為單純的紀錄，todo.md則是給作者看得需要解決內容清單
2. **`todo.md` 更新前是否留底**：`revisions/_format.md` 是為章節檔段落設計的格式。`todo.md` 是工作檔，是否也要在 `revisions/` 留底，需決定。
不用，用 `progress.md`紀錄歷程
3. **`consistency-map.md` 首版由誰建**：(a) 使用者自填；(b) 由主對話依各章現況草擬、使用者逐列確認。
b
4. **hooks 是否啟用**：啟用後每個 session、每次改章節檔都會插入提醒。
ok
5. **章節檔重新命名的處理**：skill 寫死檔名的問題（第 2.2 節）不在本設計範圍。Agent 與新 skill 一律依 `Basic Information.md` 的 `chapters` 取檔名，不寫死。
OK
---

## 10. 限制

- Subagent 執行時不能直接與使用者對話；結果回到主對話，由主對話轉述。
- Agent 只看得到寫進檔案的內容。在 Word 或只在對話中做的決定，沒寫進檔案就看不到。
- 跨章論點是否矛盾，Agent 只列疑點，判斷交使用者。
- 「核對正文是否已處理」依文字比對，可能漏判；skill 對判斷不了的事項保留在未解決。
