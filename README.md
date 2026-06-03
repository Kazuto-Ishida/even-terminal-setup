# even-terminal setup

Ubuntu/Debian に以下を一括インストール・認証まで行うスクリプト。

- nvm + Node.js LTS
- Claude Code（ブラウザ認証あり）
- Tailscale（ブラウザ認証あり）
- even-terminal

## 使い方

```bash
curl -fsSL https://raw.githubusercontent.com/Kazuto-Ishida/even-terminal-setup/main/setup.sh -o setup.sh && bash setup.sh
```

> **注意**: `curl ... | bash` ではなく必ず一度ファイルに保存してから実行してください。  
> `claude` や `sudo tailscale up` などインタラクティブなコマンドがキー入力を受け取れなくなります。

## 実行フロー

1. nvm・Node.js LTS インストール
2. Claude Code インストール → `claude` でブラウザ認証（完了後 Ctrl+C）
3. Tailscale インストール → `sudo tailscale up` でブラウザ認証
4. even-terminal インストール → `even-terminal --tailscale` で起動
