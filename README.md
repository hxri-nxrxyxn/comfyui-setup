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
docker compose up -d --build
```

Open **http://localhost:8188**. First build takes ~5 min (compiles SageAttention once).

---

## GPU Tuning

| VRAM | CLI flag | Best for |
|---|---|---|
| ≥24 GB | `--highvram` | Max speed |
| 16–22 GB | `--lowvram` (current) | Wan2.2, FLUX |
| 8–12 GB | `--lowvram` | fp8 models, smaller res |

For non-Turing GPUs, change `{"7.5"}` in the Dockerfile `sed` to your compute capability (e.g. `{"8.6"}` for Ampere, `{"8.9"}` for Ada).

---

## Workflows

| Workflow | Description |
|---|---|
| [Wan2.2 I2V 14B](docs/workflows/wan2.2-i2v-14b.md) | I2V, first+end frame, 4-step LoRA, 640×640, 5 sec |

---

## Key Config

- **SageAttention2**: https://github.com/gameblabla/SageAttention2 (Turing fork)
- **`PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True`** — prevents VRAM lock after OOM
- **Workflows saved** in `./workflows/` — survives restarts
