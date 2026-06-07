# ComfyUI Setup

Dockerized ComfyUI with **SageAttention2** baked in, running on Debian/Ubuntu with NVIDIA GPUs.

---

## Host Specs

| Component | Detail |
|---|---|
| **CPU** | AMD Ryzen 7 3700X (8C/16T) |
| **RAM** | 32 GB |
| **GPU** | 2x NVIDIA RTX 2080 Ti (22 GB each, compute 7.5) |
| **Storage** | ADATA SX8200PNP NVMe (238 GB) |
| **OS** | Ubuntu 24.04.4 LTS |
| **Kernel** | 6.8.0-100-generic |
| **Docker** | 29.5.3 |
| **Docker Compose** | v5.1.4 |
| **NVIDIA Driver** | 580.159.03 |

---

## Files

| File | Purpose |
|---|---|
| `Dockerfile` | PyTorch 2.4 + CUDA 12.4, ComfyUI, triton 3.0+, SageAttention2 (compiled for SM75) |
| `docker-compose.yml` | GPU passthrough, volume mounts, env vars, CLI flags |
| `entrypoint.sh` | Minimal passthrough — all setup baked into image |

---

## Quick Start

```bash
git clone <this-repo-url> && cd comfyui-setup

# Place models into ./models/ in the expected subdirectories
# (see [workflows/](workflows/) for per-workflow model requirements)

docker compose up -d --build
```

Open **http://localhost:8188**.

The first build compiles SageAttention2 CUDA kernels — takes ~5 minutes. Subsequent starts are instant.

---

## GPU Tuning

Edit `CLI_ARGS` in `docker-compose.yml`:

| VRAM | Flag | Best for |
|---|---|---|
| ≥24 GB | `--highvram` | Maximum speed — everything stays in VRAM |
| 16–22 GB | `--lowvram` (default) | Swaps model parts — fits larger models (Wan, FLUX) |
| 8–12 GB | `--lowvram` | Use fp8 models, smaller resolutions |

For non-Turing GPUs, edit the `{"7.5"}` in the Dockerfile `sed` command:

| GPU | Compute Cap | Value |
|---|---|---|
| RTX 20-series (Turing) | 7.5 | `{"7.5"}` |
| RTX 30-series (Ampere) | 8.6 | `{"8.6"}` |
| RTX 40-series (Ada) | 8.9 | `{"8.9"}` |

---

## Workflows

| Workflow | Description |
|---|---|
| [Wan2.2 I2V 14B](workflows/wan2.2-i2v-14b.md) | Image-to-video, first+end frame, 4-step LoRA |

*Add more as `workflows/<name>.md` and link them above.*

---

## Key Config

- **SageAttention2 fork**: https://github.com/gameblabla/SageAttention2 (modified for Turing)
- **PyTorch caching**: `PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True` prevents VRAM lock after OOMs
- **SageAttention** compiled once at build time, not on every container start
