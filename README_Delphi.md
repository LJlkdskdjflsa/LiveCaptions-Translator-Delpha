# LiveCaptions Translator - Delphi XE 7 Port

這是原 C# WPF 專案 LiveCaptions Translator 轉換為 Delphi XE 7 的版本。

## 專案結構

```
LiveCaptionsTranslator/
├── LiveCaptionsTranslator.dpr          # 主程式檔案
├── LiveCaptionsTranslator.dproj        # 專案檔案
├── LiveCaptionsTranslator.groupproj    # 群組專案檔案
├── src/
│   ├── forms/                          # 表單檔案
│   │   ├── MainForm.pas/.dfm          # 主表單
│   │   ├── OverlayForm.pas/.dfm       # 覆蓋視窗
│   │   ├── SettingsForm.pas/.dfm      # 設定表單
│   │   └── WelcomeForm.pas/.dfm       # 歡迎畫面
│   ├── models/                         # 資料模型
│   │   ├── CaptionUnit.pas            # 字幕類別
│   │   ├── SettingUnit.pas            # 設定類別
│   │   ├── WindowStateUnit.pas        # 視窗狀態
│   │   ├── TranslateAPIConfigUnit.pas # API 設定
│   │   └── TranslationHistoryUnit.pas # 翻譯歷史
│   ├── core/                           # 核心功能
│   │   └── TranslatorUnit.pas         # 翻譯引擎
│   └── utils/                          # 實用工具
│       ├── LiveCaptionsHandlerUnit.pas # LiveCaptions 處理
│       ├── TranslateAPIUnit.pas        # 翻譯 API
│       ├── TextUtilUnit.pas            # 文字處理工具
│       ├── WindowHandlerUnit.pas       # 視窗處理
│       ├── HistoryLoggerUnit.pas       # 歷史記錄
│       ├── UpdateUtilUnit.pas          # 更新工具
│       └── WindowsAPIUnit.pas          # Windows API
└── README_Delphi.md                   # 本說明檔案
```

## 主要功能

- **即時字幕翻譯**: 基於 Windows LiveCaptions 的即時語音翻譯
- **多 API 支援**: 支援 Google、DeepL、OpenAI、百度等翻譯服務
- **覆蓋視窗**: 可在螢幕上顯示翻譯結果的覆蓋視窗
- **設定管理**: 完整的設定介面與持久化儲存
- **歷史記錄**: 翻譯歷史的記錄與查看

## 系統需求

- Windows 7 或更新版本
- Delphi XE 7 或相容的開發環境
- Windows LiveCaptions 功能 (Windows 10/11)

## 編譯說明

1. 在 Delphi XE 7 中開啟 `LiveCaptionsTranslator.groupproj`
2. 確保所有相依性已正確設定
3. 建置專案 (Build -> Build LiveCaptionsTranslator)

## 與原版差異

### 架構變更
- **UI 框架**: WPF → VCL
- **語言**: C# → Object Pascal
- **執行緒模型**: async/await → TTask 與 TThread
- **資料繫結**: WPF Binding → 手動更新

### 實作差異
- **UI Automation**: 使用 Windows API 替代 .NET 的 UI Automation
- **HTTP 客戶端**: 使用 THttpClient 替代 .NET HttpClient
- **JSON 處理**: 使用 System.JSON 替代 System.Text.Json
- **設定儲存**: 簡化的 JSON 序列化

### 功能限制
- UI 自動化功能需額外實作 (目前為 stub)
- 部分翻譯 API 的完整實作需進一步開發
- 背景工作執行緒的錯誤處理需強化

## 待完成項目

1. **UI Automation 整合**: 完整實作 LiveCaptions 文字擷取
2. **翻譯 API 完善**: 完成所有翻譯服務的完整實作
3. **設定序列化**: 實作複雜物件的 JSON 序列化/反序列化
4. **錯誤處理**: 強化例外處理與使用者回饋
5. **資源管理**: 最佳化記憶體使用與資源釋放

## 授權

與原專案相同的授權條款。

## 貢獻

歡迎提交 Pull Request 來改善此 Delphi 版本的實作。