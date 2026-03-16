# TODOS

## Phase 2

### Light Modeカラーパレット定義
- **What:** `docs/ui-wireframe.md` §3.1 デザインシステムにLight Modeカラーパレットを追加
- **Why:** 設定画面 (§4.7) に「テーマ: ダーク/ライト/システム」ピッカーがあるが、Light Mode時のSurface/Text/Accent/Gridカラーが未定義
- **Context:** ダークモードデフォルトの方針は正しく、Phase 1では不要。Phase 2でテーマ切替を実装する際に、Light Modeのカラートークン (Surface-0/1/2, Text-Primary/Secondary, Grid-Off/Border) を定義する必要がある。
- **Depends on:** Phase 2 テーマ対応
