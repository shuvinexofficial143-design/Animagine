# Animagine AntCloud Server

One-command Ubuntu/NVIDIA setup for **Animagine XL 3.1 + ComfyUI API**.

## Install on a fresh AntCloud GPU server

SSH into the server, then run:

```bash
git clone https://github.com/shuvinexofficial143-design/Animagine.git && cd Animagine && bash setup.sh
```

The installer checks NVIDIA GPU access, installs system dependencies, clones/updates ComfyUI, creates an isolated Python environment, installs dependencies, downloads Animagine XL 3.1, creates a systemd service, starts it, and verifies the local API.

## Access safely from your Windows PC

Keep port 8188 private and create an SSH tunnel:

```powershell
ssh -L 8188:127.0.0.1:8188 USER@SERVER_IP
```

Then open `http://127.0.0.1:8188` locally.

## Commands

```bash
bash start.sh
bash stop.sh
bash status.sh
sudo journalctl -u animagine -f
```

## Notes

- Designed for Ubuntu/Debian NVIDIA GPU instances.
- Do not expose ComfyUI port 8188 directly to the public internet without authentication/reverse-proxy protection.
- The model is downloaded on the server, not stored in GitHub.
- Re-running `setup.sh` is intended to be safe: existing model downloads are skipped and ComfyUI is updated.
- If the upstream model URL changes, set `ANIMAGINE_MODEL_URL` before running setup.
