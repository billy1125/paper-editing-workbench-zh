# 首次設定：為一篇論文建立資料夾與工作檔

本檔是 `CLAUDE.md` §5 抽出的**開新論文一次性流程**，只有「新增一篇論文」時才需要；日常編修循環見 CLAUDE.md §5。（給人看的簡版另見 `README.md`「開一篇新論文」。）

1. **建立論文資料夾**：複製範本骨架 `working-papers/_TEMPLATE/` 為 `working-papers/<title>/`（`<title>` 用簡短 kebab-case slug，如 `working-papers/technological-trust-recommendation-systems`）。骨架已含六個大章節檔、過去手稿的集中檔 `Manuscript.md`、`Basic Information.md`、`progress.md`、`references.md`、`style-guide.md` 與 `drafts/`、`target-journal-samples/`、`revisions/`、`papers/` 子夾。之後這篇的所有工作檔都放在此夾內。先填 `Basic Information.md`（含目標期刊），並**由作者在其中的 `chapters` 設定大章節**：範本建議的大綱是 `Introduction.md`、`Literature Review.md`、`Research Method.md`、`Data Analysis.md`、`Results.md`、`Discussion and Conclusion.md`，可依實際大綱增刪、改名，清單與資料夾內的檔名要一致。日常編修以這些章節檔為工作檔。這篇的參考文獻原文放在本夾的 `papers/`，內分 `pdf/`、`md/` 兩個資料夾。
2. **放入來源文件**：使用者把原始論文（`.docx`、`.pdf` 等）放在 `working-papers/<title>/drafts/`（例如 `working-papers/<title>/drafts/Manuscript.docx`）。
3. **抽取正文成 Markdown**：用 `source-document-extraction` skill 把正文截取出來，存成**該篇的 `working-papers/<title>/Manuscript.md`**。這是這篇**過去所有手稿的集中檔**，供撰寫與編修章節檔時取材、對照，不是編修工作檔。
   - 範例指令（以現有論文為例）：
     ```bash
     conda run -n research python .claude/skills/source-document-extraction/scripts/extract_docx.py working-papers/technological-trust-recommendation-systems/drafts/Manuscript.docx -o working-papers/technological-trust-recommendation-systems/Manuscript.md
     ```
   - Markdown 是預設輸出，不需旗標；輸出會自動清理 Word 的內嵌 base64 圖片、書籤錨點與反斜線跳脫（要保留原樣才加 `--keep-images`／`--no-clean`）。來源是 PDF 時改用同目錄的 `extract_pdf.py`。
   - `drafts/` 的原始檔**保留不動**，僅作對照與回溯來源；**不再直接編輯 `drafts/`**。
   - 該 skill 不綁定本專案，落檔位置一律靠 `-o` 指定（**不要留在它預設的 `extracted/`**）；抽完**回報實際輸出路徑**，再接第 4 步建 `progress.md`。上下游與分流規則見 CLAUDE.md §4「接線註記」。
   - 之後「在 Word 改過的稿件要合併回章節檔」屬 `docx-manuscript-sync`，不是這一步。
4. **建立進度清單 `progress.md`**：在該篇資料夾建一份輕量編修進度表，依 `chapters` 逐章節標狀態（未動／進行中／已定稿），跨 session 一目了然。每次定稿後更新對應節（見 CLAUDE.md §5 日常編修循環最後一步）。
5. **（建議）風格校準**：先設定跨論文共用的風格區塊——把自己的中文文章放 `writing-style/personal-voice/sources/`（執行 `personal-voice-calibration` 蒸餾 `personal-voice.md`）、把蒐集的學術中文原則放 `writing-style/academic-principles/sources/`（執行 `academic-principles-calibration` 萃取 `academic-principles.md`）；再把目標期刊範文放進該篇 `target-journal-samples/`，執行 `personal-voice-calibration` 產生該篇 `style-guide.md`。未做前以 `writing-style/style-defaults.md` 的預設基準先行。
