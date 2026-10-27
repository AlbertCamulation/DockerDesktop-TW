# Docker Desktop 繁體中文（台灣）

本倉庫提供 **Docker Desktop 繁體中文（台灣用語）** 漢化腳本與翻譯設定，在**本機官方安裝檔**上就地解包、替換字串、重打包，並同步 4.74+ 的 `app.asar` 完整性校驗。

> 衍生自 [asxez/DDCS](https://github.com/asxez/DDCS)（GPLv3）與 [asxez/DockerDesktop-CN](https://github.com/asxez/DockerDesktop-CN) 的簡體漢化思路。感謝原作者。  
> **本倉庫不發布 Docker 專有二進位檔**（不含 `app.asar`、`app.asar.unpacked`、`Docker Desktop.exe` 或安裝程式）。

## 設計原則

- **設定頁灰色說明／按鈕／一般句子**：翻成台灣繁體（例：帳戶、檔案、網路、設定、軟體）。
- **技術專有名詞刻意保留英文**：側欄與物件名如 Containers、Images、Logs、Volumes、Builds、Models、Extensions、Kubernetes、Docker Hub、Gordon、MCP Toolkit、Docker Scout、Swarm、Compose、Dockerfile、registry、tag，以及句中的 WSL 2、Hyper-V、containerd、Wasm、DNS 等。
- **只改字串**：不注入新邏輯、不下載預製漢化包；以本機官方檔為來源。

## 支援版本

目前針對 **Docker Desktop 4.97.0** 驗證。其他版本可自行 `ddcs_extract.py` 補譯後再跑。

## 環境需求

- Windows（管理員權限）
- Python >= 3.10
- Node.js >= 22

## 使用方式（推薦：一鍵腳本）

1. 完全退出 Docker Desktop。
2. 以系統管理員開啟 PowerShell，進入本倉庫根目錄。
3. 執行：

```powershell
.\scripts\套用繁中.bat
```

或：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Apply-TraditionalChinese.ps1
```

腳本會：

1. 定位安裝目錄（`Program Files` 或每使用者安裝路徑）
2. 備份 `app.asar`、`app.asar.unpacked`、`Docker Desktop.exe` 到 `%LOCALAPPDATA%\DockerDesktop-TW\backup\<時間戳>`
3. 安裝依賴（`pip` / `npm install --ignore-scripts`）
4. 執行 `python ddcs.py`（解包 → 字串替換 → 打包 → 更新 asar hash）

### 還原原版

```powershell
.\scripts\還原原版.bat
```

會從最近一次備份還原上述三個項目。

## 手動使用腳本

```bash
pip install -r requirements.txt
npm install --ignore-scripts
# 管理員權限、Docker Desktop 已退出
python ddcs.py
```

### 4.74+ 完整性校驗

Windows 會在 `Docker Desktop.exe` 內記錄 `resources\app.asar` header 的 SHA256。只換 `app.asar` 會出現 `Integrity check failed for asar archive`。本腳本會同步改 hash；修補後 Authenticode 簽章會失效（預期現象）。

## 翻譯者

```bash
python ddcs_extract.py          # 或 --path <已解包 app>
# 編輯 lib/extract_config.py 空字串 dst；技術名詞設 dst=None
# 無法自動抓到的句子放入 lib/extract_config_manually.py
```

OpenCC `s2twp` 之後請再跑台灣用語修正（帳／檔案／網路／設定…），見倉庫內 `Apply` 流程說明。

## FAQ

**Q: 為什麼側欄還是英文？**  
A: 刻意保留。只翻譯說明與操作句，避免 Docker 專有名詞中英混雜難搜。

**Q: 可以下載現成 app.asar 嗎？**  
A: 本倉庫不提供。請用腳本對本機官方檔處理。

**Q: 更新 Docker Desktop 後？**  
A: 官方更新會覆蓋檔案，需重新執行套用腳本；建議先還原或重裝後再漢化。

## 免責

非 Docker 官方專案。修改前端資源可能影響支援條款或更新流程；請自行備份。GPLv3。

## Credits

- [asxez/DDCS](https://github.com/asxez/DDCS)
- [asxez/DockerDesktop-CN](https://github.com/asxez/DockerDesktop-CN)
