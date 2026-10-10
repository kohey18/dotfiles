# MacBook → mac-studio へのファイル受け渡し (同期フォルダ + Mutagen)

## 困りごと

自宅 Mac Studio (`studio`) に herdr で繋ぎ、その上で Claude Code / Codex を動かしている。
手元の MacBook にあるファイルを Finder から herdr のペインにドラッグ&ドロップすると、入るのは
**MacBook 側の絶対パス** (`/Users/<MacBook のユーザ>/Downloads/foo.pdf`) で、studio にはそのパスが無いので
エージェントが読めない。これまでは Google Drive に上げてリンクを渡していた。

## 方針

ドロップで渡るのはパス文字列だけなので、**両方の Mac に同じ絶対パスで同じ中身のフォルダ**を用意する。

| | 内容 |
|---|---|
| フォルダ | `/Users/Shared/sync` (両機)。`/Users/Shared` はどの Mac にも最初からあり、ホーム名に依存しない |
| 同期 | [Mutagen](https://github.com/mutagen-io/mutagen) を MacBook に常駐させ、既存の `ssh studio` 経由で双方向 (`two-way-safe`) に即時同期 |
| 使い方 | `~/Downloads` から必要なものだけ Finder で `sync` にドラッグ → `sync` から herdr のペインにドラッグ → エージェントがそのまま Read |
| 戻り | 双方向なので、studio 側の Claude が `sync` に書いた成果物は MacBook の Finder に現れる |
| 画像 | スクショは `herdr --remote` の `ctrl+v` (`keys.remote_image_paste`) が画像をリモートの一時ファイルに転送する。確認済み |

`~/Downloads` 全体は同期しない (4GB 以上、会社資料も混ざる)。studio から MacBook に接続する経路は作らない。

## セットアップ

```sh
./setup.sh                 # brew で mutagen が入り、/Users/Shared/sync 作成と daemon の自動起動登録まで
studio-sync setup          # 両機のフォルダ、studio の CLAUDE.md / AGENTS.md への案内追記、同期セッション作成
studio-sync status         # Status: Watching for changes なら OK
```

`studio-sync setup` は何度実行しても安全。Finder で `/Users/Shared/sync` を開くので、サイドバーの「よく使う項目」にドラッグしておく。
前提は `ssh studio` が鍵でパスフレーズなしに通ること (`ssh-add --apple-use-keychain`)。

studio 側のエージェントには `studio-sync setup` が次の案内を追記する (`~/.claude/CLAUDE.md` と `~/.codex/AGENTS.md`):

> /Users/Shared/sync は手元の端末 (MacBook など、この Mac に ssh してくる側) と Mutagen で双方向同期されている。
> この Mac のホーム以外の /Users/<別ユーザ>/... で始まるパスや、この Mac に存在しないパスを渡されたら、
> そのファイルは別の Mac にあるので「/Users/Shared/sync に入れてください」と頼む。

## 運用メモ

- 双方向なので `sync` の中身を手で消すと studio 側も消える。「渡したら消す」運用なら `STUDIO_SYNC_MODE=one-way-replica studio-sync setup` で片方向にする。
- 衝突 (両側で同じファイルを編集) は上書きせず `studio-sync status` に出る。`studio-sync reset` で解消。
- 片側のフォルダが**完全に空**になると Mutagen は安全弁で止まる (`Halted due to one-sided root emptying`。実機で確認)。`studio-sync setup` が `.keep` を置いて空にならないようにしている。`.keep` ごと消して止まったら `studio-sync reset`。
- Finder の「場所」に外付けディスクのように出したい場合は、両機で同名のディスクイメージを `/Volumes/Studio` にマウントし、同期対象をそこに変える (`STUDIO_SYNC_DIR`)。マウント忘れで Mutagen からフォルダが消えて見える弱点があるので、まずは `/Users/Shared/sync` で始める。

## 検討した代替案

| 案 | 判定 | 理由 |
|---|---|---|
| Google Drive (従来) | × | 手数が多い。リンク経由の読み取りが不安定 |
| `~/inbox` に rsync で push するスクリプト + `~/Downloads` を launchd で自動複製 | × | 初版で試作し Codex レビューも受けたが、ドロップしたパスがそのまま使えない点が解決しない。Mutagen に置き換え |
| ssh 越しに studio のクリップボードへ画像を載せる | × | herdr --remote の ctrl+v が標準でやっている (Codex の指摘) |
| Taildrop | △ | ssh 不要だが着地先が `~/Downloads` 固定で、パスが揃わない |
| sshfs / SMB で MacBook のフォルダを studio にマウント | × | MacBook のスリープ・回線切替で studio 側のマウントが固まる |
| Dropbox / Google Drive の Finder 連携 | × | クラウド経由になり、パスもホーム名で変わる。ストリーミングのスタブを studio 側で読めないことがある |

## 経緯

2026-10-10 に Claude (Fable 5.1) が設計し、herdr の別ペインで Codex (gpt-6-astra) がレビュー (「条件付き採用」、18 件)。
主な指摘は herdr 標準の画像転送の見落とし、同名衝突、mtime 保存による掃除の破綻、リモート shell への未引用埋め込みなど。
その後「ドロップしたパスがそのまま読める」を要件として言語化し直し、同期フォルダ + Mutagen の構成に変更した。
