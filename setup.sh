#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="${ANIMAGINE_HOME:-$HOME/animagine-server}"
COMFY="$ROOT/ComfyUI"
VENV="$ROOT/.venv"
MODEL_DIR="$COMFY/models/checkpoints"
MODEL_FILE="$MODEL_DIR/animagine-xl-3.1.safetensors"
MODEL_URL="${ANIMAGINE_MODEL_URL:-https://huggingface.co/cagliostrolab/animagine-xl-3.1/resolve/main/animagine-xl-3.1.safetensors}"
echo "[1/7] Checking NVIDIA GPU..."
command -v nvidia-smi >/dev/null || { echo "ERROR: nvidia-smi not found. Use an NVIDIA/CUDA-enabled server image."; exit 1; }
nvidia-smi
echo "[2/7] Installing system packages..."
sudo apt-get update
sudo apt-get install -y git python3 python3-venv python3-pip curl wget aria2
mkdir -p "$ROOT"
if [ ! -d "$COMFY/.git" ]; then
  echo "[3/7] Cloning ComfyUI..."
  git clone --depth 1 https://github.com/comfyanonymous/ComfyUI.git "$COMFY"
else
  echo "[3/7] Updating ComfyUI..."
  git -C "$COMFY" pull --ff-only
fi
echo "[4/7] Creating Python environment..."
[ -d "$VENV" ] || python3 -m venv "$VENV"
source "$VENV/bin/activate"
python -m pip install --upgrade pip wheel
pip install -r "$COMFY/requirements.txt"
mkdir -p "$MODEL_DIR" "$ROOT/logs"
if [ ! -s "$MODEL_FILE" ]; then
  echo "[5/7] Downloading Animagine XL 3.1..."
  aria2c -x 8 -s 8 -c -d "$MODEL_DIR" -o "$(basename "$MODEL_FILE")" "$MODEL_URL"
else
  echo "[5/7] Model already present; skipping download."
fi
echo "[6/7] Installing service files..."
sed "s|__ROOT__|$ROOT|g" "$(dirname "$0")/animagine.service.template" | sudo tee /etc/systemd/system/animagine.service >/dev/null
sudo systemctl daemon-reload
sudo systemctl enable animagine.service
echo "[7/7] Starting API..."
sudo systemctl restart animagine.service
sleep 3
curl -fsS http://127.0.0.1:8188/system_stats >/dev/null && echo "SUCCESS: ComfyUI API is running on port 8188." || {
  echo "Service started but health check failed. Check: sudo journalctl -u animagine -n 100 --no-pager"; exit 1;
}
echo "Done. For remote access, prefer SSH tunnel: ssh -L 8188:127.0.0.1:8188 USER@SERVER_IP"
