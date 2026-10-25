# working-papers/ — 論文工作區

每一篇要編修的論文各自一個資料夾放在這裡（`working-papers/<title>/`），所有編修工作檔都在該夾內。

## 開一篇新論文

複製範本骨架，改成簡短 kebab-case slug：

```bash
cp -r working-papers/_TEMPLATE working-papers/<your-paper-slug>
```

骨架已含六個大章節檔（`Introduction.md`、`Literature Review.md`、`Research Method.md`、`Data Analysis.md`、`Results.md`、`Discussion and Conclusion.md`，清單設定在 `Basic Information.md` 的 `chapters`）、過去手稿的集中檔 `Manuscript.md`，以及 `Basic Information.md`、`progress.md`、`reference.md`、`style-guide.md`、`todo.md`（待辦清單）、`consistency-map.md`（連動對照表），以及 `drafts/`、`target-journal-samples/`、`revisions/`、`papers/` 子夾。這篇的參考文獻原文放在該夾的 `papers/`（內分 `pdf/`、`md/`）。完整首次設定步驟見 [`../docs/NEW-PAPER.md`](../docs/NEW-PAPER.md)。

## 作用中論文（active paper）

同時編修多篇時，每個 session 都要先確認**正在編修哪一篇**。建議在下方維護一行，開場即可讓 Claude 據此載入該篇 `style-guide.md`；不確定時 Claude 會先問一句。

> **目前主要編修：**（填 slug，例如 `technological-trust-recommendation-systems`）

## 版控說明（重要）

**你實際編修的論文資料夾是私人內容，已被 [`.gitignore`](../.gitignore) 忽略、不進版控。** 這個 `working-papers/` 目錄裡**只有** `_TEMPLATE/`（骨架）與本 `README.md` 會進版控——所以你複製出來的 `working-papers/<your-paper-slug>/` 不會出現在 `git status`，這是預期行為，你的稿件只留在本機。
