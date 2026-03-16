# Novation Launchpad MIDI仕様

> 調査日: 2026-03-17  
> 参照: Novation Programmer's Reference Manual (MK2 v1.03, Pro MK3, Mini MK3, Launchpad X)

---

## 対応モデルとSysExヘッダー

| モデル | SysExヘッダー (Hex) | デバイスID | LED色深度 |
|--------|-------------------|-----------|---------|
| Launchpad MK2 | `F0 00 20 29 02 18` | `69h`–`78h` | 128色パレット + RGB (各6bit) |
| Launchpad Pro (初代) | `F0 00 20 29 02 10` | `51h`–`60h` | 128色パレット + RGB |
| Launchpad Pro MK3 | `F0 00 20 29 02 0E` | `0Ch` | 128色パレット + RGB |
| Launchpad Mini MK3 | `F0 00 20 29 02 0D` | — | 128色パレット + RGB |
| Launchpad X | `F0 00 20 29 02 0C` | `13h 11h` | 128色パレット + RGB |

> **実装方針:** Device Inquiryでモデルを自動識別し、ヘッダーを切り替える。

---

## Device Inquiry（デバイス識別）

```
// Query (Universal Device Inquiry)
Host → Device: F0 7E 7F 06 01 F7

// MK2 応答例
Device → Host: F0 7E <deviceID> 06 02 00 20 29 69 00 00 00 <fw[4]> F7
//                                                        ^^ ここでモデル識別
```

### モデル識別バイト (応答の [8]バイト目)

| 値 | モデル |
|----|--------|
| `69h` (105) | Launchpad MK2 |
| `51h` (81) | Launchpad Pro (初代) |
| `0Ch` (12) | Launchpad Pro MK3 |
| `13h` | Launchpad X |

---

## LEDインデックス体系

レイアウトに関わらず、LED指定には常に **Session Layout (Programmer Mode) のノート番号** を使用する。

```
// 8x8グリッド (Session Layout, 10進数)
81  82  83  84  85  86  87  88   ← Row 8 (上)
71  72  73  74  75  76  77  78
61  62  63  64  65  66  67  68
51  52  53  54  55  56  57  58
41  42  43  44  45  46  47  48
31  32  33  34  35  36  37  38
21  22  23  24  25  26  27  28
11  12  13  14  15  16  17  18   ← Row 1 (下)

// 右サイドボタン (Scene Launch)
19  29  39  49  59  69  79  89

// 上部ボタン (Control Change, 共通)
104 105 106 107 108 109 110 111  (0x68–0x6F)
```

座標変換の公式 (Session Layout):
```
note = (row * 10) + col   // row: 1–8 (下から), col: 1–8 (左から)
```

---

## Programmer Mode への切り替え

LEDを自由制御するには **Programmer Mode** が必要。

### MK2
```
Host → MK2: F0 00 20 29 02 18 22 <layout> F7

// layout値:
// 00h = Session
// 01h = User 1 (Drum Rack)
// 02h = User 2
// 03h = (Ableton Live 予約済み)
// 04h = Volume
// 05h = Pan
```

### Launchpad X / Mini MK3 / Pro MK3
```
Host → Device: F0 00 20 29 02 0C 0E <mode> F7
// mode: 0 = Live Mode, 1 = Programmer Mode

// 終了時はLive Modeに戻す
Host → Device: F0 00 20 29 02 0C 0E 00 F7
```

---

## LED制御メッセージ

### 1. Note On / CC による単体制御

MIDIチャンネルで発光モードを指定する。

| チャンネル | モード | メッセージ |
|-----------|--------|-----------|
| Ch 1 | Static (固定) | `90 <note> <palette_color>` |
| Ch 2 | Flashing (点滅) | `91 <note> <palette_color>` |
| Ch 3 | Pulsing (呼吸) | `92 <note> <palette_color>` |
| Ch 1 | 消灯 | `90 <note> 00` |

上部ボタン (CC) の場合:
```
B0 <cc_number> <palette_color>   // Ch1 Static
```

### 2. SysEx — パレットカラー一括設定

最大 **80パッド** を1メッセージで更新できる。

```
// MK2
Host → MK2: F0 00 20 29 02 18 0A <LED> <Color> [<LED> <Color> ...] F7

// 例: パッド11を赤(5)、パッド12を緑(21)に設定
F0 00 20 29 02 18 0A 0B 05 0C 15 F7
```

### 3. SysEx — RGBカラー設定 (フルカラー)

R/G/B各 **0–63** (6bit) で任意色を指定。

```
// MK2
Host → MK2: F0 00 20 29 02 18 0B <LED> <R> <G> <B> [<LED> <R> <G> <B> ...] F7

// 例: パッド11を純赤に設定
F0 00 20 29 02 18 0B 0B 3F 00 00 F7
//                   ^LED ^R  ^G  ^B
//                   11   63   0   0
```

### 4. SysEx — 列・行・全体一括

```
// 列単位 (col: 0=左端, 8=右サイドボタン)
F0 00 20 29 02 18 0C <col> <color> F7

// 行単位 (row: 0=下端, 8=上部ボタン)
F0 00 20 29 02 18 0D <row> <color> F7

// 全パッド同一色
F0 00 20 29 02 18 0E <color> F7

// グリッド全体をRGBで設定
F0 00 20 29 02 18 0F 00 <R> <G> <B> F7
```

---

## カラーパレット (128色)

パレットは 0–127 の値。`0` = 消灯。

主要色の抜粋:

| 値 | 色 |
|----|----|
| 0 | Off |
| 5 | Red |
| 9 | Orange |
| 13 | Yellow |
| 17 | Lime |
| 21 | Green |
| 45 | Blue |
| 53 | Light Blue |
| 81 | Purple |
| 127 | White |

> 完全なパレットは Programmer's Reference Manual の Color Table を参照。

---

## フラッシュ / パルス

```
// フラッシュ: Ch2でFlash色(B)を設定 → Ch1の現在色(A)とB色が交互に点滅
// パルス: Ch3で設定 → 明度が周期的に増減

// テンポ同期: MIDI Clock (0xF8) を24ppq で送信
// デフォルト: 120 BPM
```

---

## テキストスクロール (MK2)

```
Host → MK2: F0 00 20 29 02 18 14 <speed> <loop> <color> <ASCII...> F7

// speed: 1–7
// loop: 0=1回, 1=ループ
// 例: "Hi" を速度4、1回、赤で表示
F0 00 20 29 02 18 14 04 00 05 48 69 F7
```

---

## iOS実装メモ

### CoreMIDI での SysEx 送信

```swift
// SysExはMIDIPacketに分割して送信
// 1パケットの推奨上限: 256バイト
// 大きなメッセージは複数パケットに分割する

var packet = MIDIPacket()
packet.timeStamp = 0
packet.length = UInt16(sysexBytes.count)
// ... データをコピーしてMIDISend()
```

### 接続方法
- **有線 (USB-MIDI):** Camera Connection Kit経由。iOS 16以降でMIDI over USB対応。
- **ワイヤレス:** BLE-MIDI または Wi-Fi MIDI (CoreMIDINetwork)

### 注意事項
- Programmer Modeへの切り替えはアプリ起動時に実施
- アプリ終了時は必ずLive Mode (またはStandalone Mode) に戻す
- `MIDIObjectAddedNotification` でデバイスの接続/切断を監視する

---

## 参考リンク

- [Launchpad MK2 Programmer's Reference Manual v1.03](https://fael-downloads-prod.focusrite.com/customer/prod/s3fs-public/downloads/Launchpad%20MK2%20Programmers%20Reference%20Manual%20v1.03.pdf)
- [Launchpad X Programmer's Reference Manual](https://fael-downloads-prod.focusrite.com/customer/prod/s3fs-public/downloads/Launchpad%20X%20-%20Programmers%20Reference%20Manual.pdf)
- [Launchpad Pro MK3 Programmer's Reference Manual](https://fael-downloads-prod.focusrite.com/customer/prod/s3fs-public/downloads/LPP3_prog_ref_guide_200415.pdf)
- [Novation User Guides — MIDI on Launchpad X](https://userguides.novationmusic.com/hc/en-gb/articles/24001489325330-MIDI-on-Launchpad-X)
