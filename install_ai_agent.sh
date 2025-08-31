#!/bin/bash
# AI Agent one-click installer for macOS (Apple Silicon/M2)

set -e

# Check for Python3
if ! command -v python3 &> /dev/null; then
  echo "Python3 not detected."
  # Check for Homebrew
  if ! command -v brew &> /dev/null; then
    read -p "Homebrew is not detected and is required to install Python. Install Homebrew now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "Installing Homebrew... (You may be asked for your password)"
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      echo -e "\nHomebrew installation complete!"
      read -p $'\nTo make Homebrew available permanently, its environment needs to be added to your shell profile.\n\n[RISK WARNING]\nThis will modify your shell profile (~/.zshrc).\nTo revert, manually edit the file and remove the Homebrew settings at the end.\n\nConfigure automatically? (y/n) ' -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Writing Homebrew environment to ~/.zshrc ..."
        echo '' >> ~/.zshrc
        echo '# Set PATH, MANPATH, etc., for Homebrew.' >> ~/.zshrc
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
        
        echo "Settings written. Activating Homebrew for the current session to continue installation..."
        eval "$(/opt/homebrew/bin/brew shellenv)"
      else
        echo "You chose manual setup."
        echo "Please follow the instructions from Homebrew to set up the environment, then run this script again."
        exit 1
      fi
    else
      echo "User chose not to install Homebrew. Script terminated."
      exit 1
    fi
  fi

  echo "Homebrew detected. Installing Python with it..."
  brew install python
fi

# Create virtual environment
python3 -m venv ai_agent_env
source ai_agent_env/bin/activate

# Install dependencies
pip install --upgrade pip
pip install Flask requests beautifulsoup4

# Download the main agent script
AGENT_URL="https://raw.githubusercontent.com/enjoyce20061010/my-ai-agent-installer/main/ai_agent.py"
curl -o ai_agent.py "$AGENT_URL"

cat <<EOF

Installation Complete!
To run:
  source ai_agent_env/bin/activate
  python ai_agent.py

To remove, delete the ai_agent_env/ folder and ai_agent.py file.
EOF
