#!/bin/bash
# AI Agent 一鍵安裝腳本 for macOS (Apple Silicon/M2)
# 使用方式：在終端機 cd 到你想安裝的資料夾，執行 sh install_ai_agent.sh

set -e

# 檢查 Python3
if ! command -v python3 &> /dev/null; then
  echo "未偵測到 Python3。"
  # 檢查 Homebrew
  if ! command -v brew &> /dev/null; then
    read -p "未偵測到 Homebrew，它是安裝 Python 的必要工具。是否要現在自動安裝 Homebrew？ (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "正在安裝 Homebrew... (這可能需要您輸入管理者密碼)"
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      echo -e "\nHomebrew 安裝完成！"
      read -p $'\n為了讓 Homebrew 永久生效，需要將其設定加入到您的 Shell 設定檔中。\n本腳本可以自動為您完成此設定。\n\n【風險提示】\n此操作將會修改您的 Shell 設定檔 (~/.zshrc)。\n還原方法：若出現問題，請手動編輯該檔案，刪除末尾的 Homebrew 設定即可。\n\n是否要自動設定？ (y/n) ' -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "正在將 Homebrew 環境設定寫入 ~/.zshrc ..."
        # On Apple Silicon, the path is /opt/homebrew.
        # The shell is almost certainly zsh on a new M2 Mac.
        echo '' >> ~/.zshrc
        echo '# Set PATH, MANPATH, etc., for Homebrew.' >> ~/.zshrc
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
        
        echo "設定已寫入。正在為目前工作階段啟用 Homebrew 以繼續安裝..."
        # Activate brew for the current script session
        eval "$(/opt/homebrew/bin/brew shellenv)"
        # Now brew command should be available, and we can proceed.
      else
        echo "您選擇了手動設定。"
        echo "請依照 Homebrew 的指示，手動執行環境設定命令，然後重新執行本腳本。"
        exit 1
      fi
    else
      echo "使用者選擇不安裝 Homebrew，腳本終止。"
      exit 1
    fi
  fi

  # 如果程式能執行到這裡，代表 brew 已經存在
  echo "偵測到 Homebrew，正在使用它來安裝 Python..."
  brew install python
fi

# 建立虛擬環境
python3 -m venv ai_agent_env
source ai_agent_env/bin/activate

# 安裝依賴
pip install --upgrade pip
pip install requests openai

# 下載主程式（如有自訂 repo 請修改下行網址）
AGENT_URL="https://raw.githubusercontent.com/your-repo/ai_agent.py"
curl -o ai_agent.py "$AGENT_URL"

cat <<EOF

安裝完成！
請執行：
  source ai_agent_env/bin/activate
  python ai_agent.py

如要移除，刪除 ai_agent_env/ 和 ai_agent.py 即可。
EOF
