#!/bin/bash

# Ensure this file is sourced, not executed
[[ $0 != "${BASH_SOURCE[0]}" ]] || { echo "This script must be sourced, not executed."; exit 1; }

# Environment variables
export POPS_ENV=${POPS_ENV:-development}
export PYTHONPATH=${PYTHONPATH:+$PYTHONPATH:}$(pwd)

# Development aliases
alias pops-run="python app/metrics_server.py"
alias pops-test="pytest tests/"
alias pops-lint="flake8 app/ tests/"

# Function to start all services
pops-start-all() {
    echo "Starting pOps services..."
    python app/metrics_server.py &
    python app/example_inference.py &
}

# Function to stop all services
pops-stop-all() {
    echo "Stopping pOps services..."
    pkill -f "python app/metrics_server.py"
    pkill -f "python app/example_inference.py"
}

# Export functions so they're available in subshells
export -f pops-start-all
export -f pops-stop-all

# Git branch function
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# GPU info function
get_gpu_info() {
    if command -v nvidia-smi &> /dev/null; then
        echo "GPU"
    else
        echo "CPU"
    fi
}

# Print environment info on login
echo "pOps Development Environment"
echo "Environment: $POPS_ENV"
echo "Python Path: $PYTHONPATH"

# Auto-activate venv
if [ -d "/app/venv" ]; then
  source /app/venv/bin/activate
fi

# Health banner
echo ""
echo "🧠  ML Dev Environment Ready"
echo "--------------------------------"
python --version
[ -x "$(command -v nvidia-smi)" ] && nvidia-smi | head -n 1 || echo "🖥️  No GPU detected"
echo "📦  Installed packages: $(pip list | wc -l)"
echo "📅  $(date)"
echo "--------------------------------"

# Simple, stable prompt
PS1='(pops) \w \$ '

# Safe shell loop
safe_venv_shell() {
  echo \"Welcome to the AI/ML dev shell (venv active). Type 'exit' to quit.\"
  while true; do
    read -e -p \"(venv) ➜  \" user_cmd
    if [[ \"$user_cmd\" == \"exit\" ]]; then
      break
    fi
    eval \"$user_cmd\" || echo \"⚠️  Command failed: $user_cmd\"
  done
}
safe_venv_shell
