# ユーザー共通の指示（全プロジェクト）

- 私の Claude Code / Codex は **Herdr**（terminal workspace manager）のペイン内で動いている（`HERDR_ENV=1`）。
  「別ペインで」「別 space で」「codex を yolo で立ち上げて」と頼まれたら `herdr` スキル（`~/.claude/skills/herdr/SKILL.md`）の手順で
  別プロセスとして起動する。Agent ツールのサブエージェントはペインを作らないので代わりにならない
- Herdr の設定は dotfiles（`~/Documents/dev/kohey18/dotfiles`）で管理している。手順を更新したら dotfiles 側を直す
