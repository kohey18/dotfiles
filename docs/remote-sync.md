# リモート開発機とのファイル受け渡し (remote-sync)

## 困りごと

ssh で繋がるリモートの Mac 上で herdr 経由で Claude Code / Codex を動かしていると、手元の Mac の Finder から
ペインにファイルをドラッグ&ドロップしても、入るのは **手元の絶対パス** (`/Users/<手元のユーザ>/Downloads/foo.pdf`) で、
リモートにはそのパスが無いためエージェントが読めない。

## 方針

ドロップで渡るのはパス文字列だけなので、**両方の Mac に同じ絶対パスで同じ中身のフォルダ**を用意する。

| | 内容 |
|---|---|
| フォルダ | `/Users/Shared/sync` (両機、700)。`/Users/Shared` はどの Mac にも最初からあり、ホーム名に依存しない |
| 同期 | [Mutagen](https://github.com/mutagen-io/mutagen) を手元の Mac に常駐させ、既存の ssh 設定経由で双方向 (`two-way-safe`) に即時同期 |
| 使い方 | `~/Downloads` から必要なものだけ Finder で `sync` にドラッグ → `sync` から herdr のペインにドラッグ → エージェントがそのまま Read |
| 戻り | 双方向なので、リモート側の Claude が `sync` に書いた成果物は手元の Finder に現れる |
| 画像 | スクショは `herdr --remote` の `ctrl+v` (`keys.remote_image_paste`) が画像をリモートの一時ファイルに転送する |

`~/Downloads` 全体は同期しない。リモートから手元の Mac に接続する経路は作らない。

## セットアップ

```sh
./setup.sh                 # brew で mutagen が入り、/Users/Shared/sync 作成と daemon の自動起動登録まで
remote-sync setup          # 両機のフォルダ、リモートの CLAUDE.md / AGENTS.md への案内、同期セッション作成
remote-sync status         # Status: Watching for changes なら OK
```

- 前提は `ssh <REMOTE_HOST>` が鍵でパスフレーズなしに通ること (`ssh-add --apple-use-keychain`)。接続先は `REMOTE_HOST` (既定 `studio`) で変える。
- `remote-sync setup` は何度実行しても安全。同じ設定なら何もせず、`REMOTE_HOST` / `REMOTE_SYNC_DIR` / `REMOTE_SYNC_MODE` を変えて再実行すると既存セッションとの食い違いを表示して止まる (`remote-sync remove` してからやり直す)。
- Finder で `/Users/Shared/sync` を開くので、サイドバーの「よく使う項目」にドラッグしておく。

リモート側の `~/.claude/CLAUDE.md` と `~/.codex/AGENTS.md` には `<!-- remote-sync:begin -->` 〜 `<!-- remote-sync:end -->` で囲った案内ブロックを書く
(再実行時はブロックごと置き換える)。内容は「このフォルダは手元の端末と同期されている。手元のホーム配下のパスや存在しないパスを渡されたら、
まずこのフォルダに同名ファイルが無いか探し、無ければここに入れてもらう。同期は非同期なので数秒待って再確認する」。

## 運用メモ

- **削除は伝播する。** Dropbox と同じで、`sync` の中のファイルを消すと相手側でも消える。片方向 (`one-way-*`) でも手元の削除はリモートに伝播するので、「渡したら手元だけ消す」用途には使えない。リモート側に残したいものは、リモート側で `sync` の外にコピーしてから消す。
- **`.keep` について。** Mutagen は片側のフォルダが完全に空になると `Halted due to one-sided root emptying` で止まる (フォルダ自体が消えたり、マウントが外れたりした場合の安全弁)。`remote-sync setup` は隠しファイル `.keep` を置いてこの停止を避けている。そのぶん、Finder で見えるファイルを全部消しても止まらず、そのまま相手側でも消える。フォルダ自体が消えた場合の安全弁 (`root deletion`) は残る。
- **衝突。** 両側で同じファイルを別々に編集すると `two-way-safe` は上書きせず、`remote-sync status` に Conflicts として出る。片方のファイルをリネームするか消せば解消する。
- **`reset` の意味。** `remote-sync reset` は衝突を解消しない。同期の履歴を捨てて両側の中身を足し合わせ直す操作で、`Halted` で止まったときの復帰に使う。空にした側には相手側のファイルが戻ってくるので、本当に両側から消したいときは両方の Mac で消す。
- **到着の確認。** 同期は非同期なので、大きいファイルや回線が不安定なときは `remote-sync flush` で反映を待ってから渡す。
- **symlink。** `portable` モードなので、フォルダ内の相対リンクだけ同期され、外を指す絶対リンクは同期されない (問題として一覧に出る)。普通のファイルとフォルダを入れる前提。
- **権限。** 受信側のファイルは 0600 / 0700 で作られる。フォルダ自体も 700 にしているので、他のローカルアカウントからは見えない。
- Finder の「場所」に外付けディスクのように出したい場合は、両機で同名のディスクイメージを `/Volumes/<名前>` にマウントし、`REMOTE_SYNC_DIR` をそこに変える。マウント忘れで Mutagen からフォルダが消えて見える弱点があるので、まずは `/Users/Shared/sync` で始める。

## 検討した代替案

| 案 | 判定 | 理由 |
|---|---|---|
| クラウドストレージに上げてリンクを渡す | × | 手数が多い。リンク経由の読み取りが不安定 |
| 手元から rsync でリモートの受信フォルダに push し、パスを返すスクリプト | × | ドロップしたパスがそのまま使えない点が解決しない |
| ssh 越しにリモートのクリップボードへ画像を載せる | × | herdr --remote の ctrl+v が標準でやっている |
| sshfs / SMB で手元のフォルダをリモートにマウント | × | 手元の Mac のスリープ・回線切替でリモート側のマウントが固まる |
| Dropbox / Google Drive の Finder 連携 | × | クラウド経由になり、パスもホーム名で変わる。ストリーミングのスタブをリモート側で読めないことがある |
