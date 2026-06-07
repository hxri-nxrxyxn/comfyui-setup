# ComfyUI Setup

Dockerized ComfyUI with **SageAttention2** for Wan2.2 I2V 14B on 22 GB GPUs.

---

## Host Specs

| Component | Detail |
|---|---|
| **CPU** | AMD Ryzen 7 3700X (8C/16T) |
| **RAM** | 32 GB |
| **GPU** | 2x NVIDIA RTX 2080 Ti (22 GB each, compute 7.5) |
| **Storage** | ADATA SX8200PNP NVMe (238 GB) |
| **OS** | Ubuntu 24.04.4 LTS / Docker 29.5.3 / NVIDIA 580.159.03 |

---

## Quick Start

```bash
git clone <url> && cd comfyui-setup
# Place models into ./models/ (see models section below)
docker compose up -d --build
```

Open **http://localhost:8188**. First build takes ~5 min (compiles SageAttention CUDA kernels once).

---

## Models

Place under `models/`:

| File | Path | Size |
|---|---|---|
| `wan2.2_i2v_14B_fp8_scaled` (high + low noise) | `models/diffusion_models/` | ~27 GB |
| `lightx2v_4steps_lora` (high + low noise) | `models/loras/` | ~4.6 GB |
| `umt5_xxl_fp8_e4m3fn_scaled.safetensors` | `models/text_encoders/` | ~6.3 GB |
| `wan_2.1_vae.safetensors` | `models/vae/` | ~243 MB |

---

## Performance — Wan2.2 I2V 14B (640×640, 81 frames, 5 sec)

Tested on **1x RTX 2080 Ti (22 GB)** with `--lowvram`.

| Mode | Time | vs SageAttention |
|---|---|---|
| **SageAttention** | **4.9 min** | — |
| PyTorch attention | 6.8 min | **+38% slower** |

SageAttention saves ~2 minutes per generation. Same output quality.

---

## GPU Tuning

| VRAM | CLI flag | Best for |
|---|---|---|
| ≥24 GB | `--highvram` | Max speed |
| 16–22 GB | `--lowvram` (current) | Wan2.2, FLUX |
| 8–12 GB | `--lowvram` | fp8 models, smaller res |

For non-Turing GPUs, change `{"7.5"}` in the Dockerfile `sed` to your compute capability (e.g. `{"8.6"}` for Ampere, `{"8.9"}` for Ada).

---

## Key Config

- **SageAttention2**: https://github.com/gameblabla/SageAttention2 (Turing fork)
- **`PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True`** — prevents VRAM lock after OOM
- **Workflows saved** in `./workflows/` — survives restarts
