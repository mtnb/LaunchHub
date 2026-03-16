# LaunchHub プロジェクトファイル形式 (`.launchhub`)

> バージョン: 1.0
> 作成日: 2026-03-17

---

## 概要

`.launchhub` ファイルはUTF-8エンコードのJSONファイル。
ライトショーの全データ（フレーム、カラー設定、メタデータ）を格納する。

---

## スキーマ

```json
{
  "version": "1.0",
  "metadata": {
    "name": "Show 1",
    "created": "2026-03-17T12:00:00Z",
    "modified": "2026-03-17T14:30:00Z",
    "bpm": 120,
    "author": "User"
  },
  "target_device": "launchpad_x",
  "frames": [
    {
      "index": 0,
      "duration_ms": 500,
      "transition": "cut",
      "pads": [
        {
          "note": 11,
          "color_type": "palette",
          "color_value": 5,
          "led_mode": "static"
        },
        {
          "note": 12,
          "color_type": "rgb",
          "color_value": { "r": 63, "g": 0, "b": 32 },
          "led_mode": "pulsing"
        }
      ],
      "cc_buttons": [
        { "cc": 104, "color_type": "palette", "color_value": 21 }
      ],
      "scene_buttons": [
        { "note": 19, "color_type": "palette", "color_value": 45 }
      ]
    }
  ]
}
```

---

## フィールド定義

### トップレベル

| フィールド | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| `version` | string | Yes | スキーマバージョン (`"1.0"`) |
| `metadata` | object | Yes | プロジェクトメタデータ |
| `target_device` | string | Yes | 対象デバイス (後述) |
| `frames` | array | Yes | フレーム配列 (1つ以上) |

### `metadata`

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `name` | string | プロジェクト表示名 |
| `created` | string (ISO 8601) | 作成日時 |
| `modified` | string (ISO 8601) | 最終更新日時 |
| `bpm` | number (20–300) | テンポ |
| `author` | string | 作成者名 |

### `target_device` 値

| 値 | モデル |
|----|--------|
| `launchpad_mk2` | Launchpad MK2 |
| `launchpad_pro` | Launchpad Pro (初代) |
| `launchpad_pro_mk3` | Launchpad Pro MK3 |
| `launchpad_mini_mk3` | Launchpad Mini MK3 |
| `launchpad_x` | Launchpad X |

### `frames[n]`

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `index` | number | フレーム番号 (0始まり) |
| `duration_ms` | number | 表示時間 (ミリ秒) |
| `transition` | string | `"cut"` / `"fade"` / `"slide"` |
| `pads` | array | 8x8グリッドのパッド設定 |
| `cc_buttons` | array | 上部ボタン (CC 104–111) |
| `scene_buttons` | array | サイドボタン (Note x9) |

### `pads[n]` / `scene_buttons[n]`

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `note` | number | MIDIノート番号 (11–88 or x9) |
| `color_type` | string | `"palette"` / `"rgb"` |
| `color_value` | number or object | パレット: 0–127, RGB: `{r, g, b}` 各0–63 |
| `led_mode` | string | `"static"` / `"flashing"` / `"pulsing"` |

### `cc_buttons[n]`

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `cc` | number | CC番号 (104–111) |
| `color_type` | string | `"palette"` / `"rgb"` |
| `color_value` | number or object | パレット値またはRGBオブジェクト |
