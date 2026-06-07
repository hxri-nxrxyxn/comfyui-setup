# ComfyUI Setup — Wan2.2 I2V on 22GB

Dockerized ComfyUI with **SageAttention2** baked in, tuned for **Wan2.2 14B image-to-video** on dual RTX 2080 Ti (22 GB each).

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
| `Dockerfile` | Builds the image: PyTorch 2.4 + CUDA 12.4, ComfyUI, triton 3.0+, SageAttention2 (compiled for SM75) |
| `docker-compose.yml` | Container config — GPU passthrough, volume mounts, env vars, CLI flags |
| `entrypoint.sh` | Runtime entry — currently just passes through to ComfyUI (SageAttention is baked into image) |

---

## Models Installed

| Model | Type | Size |
|---|---|---|
| `wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors` | Diffusion (high noise) | ~27 GB total |
| `wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors` | Diffusion (low noise) | (same dir) |
| `wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors` | LoRA — 4-step high noise | ~2.3 GB |
| `wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors` | LoRA — 4-step low noise | ~2.3 GB |
| `umt5_xxl_fp8_e4m3fn_scaled.safetensors` | Text encoder (T5-XXL fp8) | ~6.3 GB |
| `wan_2.1_vae.safetensors` | VAE | ~243 MB |

---

## Performance — Wan2.2 I2V 14B (768×768)

Tested on single RTX 2080 Ti (22 GB) with `--lowvram`.

| Workload | Time | Notes |
|---|---|---|
| 5-sec video, first frame + end frame | ~5 min | With SageAttention, expandable_segments, lowvram |
| Same with `--highvram` | OOM | T5 encoder + UNet exceed 22 GB |
| With SageAttention | ✓ active | Confirmed in logs: `Using sage attention` |
| Without SageAttention | slower | Falls back to PyTorch attention |

---

## How to Use (Restore on a Different Machine)

### Prerequisites
- Docker + Docker Compose with NVIDIA Container Toolkit
- NVIDIA GPU with compute capability ≥ 7.5 (Turing or newer)
- At least 22 GB VRAM for Wan 14B

### Setup

```bash
# 1. Clone this repo
git clone <this-repo-url> && cd comfyui-setup

# 2. Download models into ./models/ in the same structure:
#    models/diffusion_models/
#    models/text_encoders/
#    models/vae/
#    models/loras/

# 3. (Optional) Add custom nodes to ./custom_nodes/
#    ComfyUI-Manager is recommended

# 4. Build and start
docker compose up -d --build

# 5. Open http://localhost:8188
```

The first build compiles SageAttention2 CUDA kernels — this takes ~5 minutes (one-time). Subsequent starts are instant.

### Tweaking for Your GPU

Edit `CLI_ARGS` in `docker-compose.yml`:

- **High VRAM (≥24 GB)**: `--highvram` for maximum speed
- **Medium (16–22 GB)**: `--lowvram` (current config — works reliably)
- **Low (8–12 GB)**: Keep `--lowvram`; consider fp8 models or smaller resolution

For other architectures, edit the `{"7.5"}` in the Dockerfile `sed` command to match your GPU's compute capability (e.g., `{"8.6"}` for RTX 30-series, `{"8.9"}` for RTX 40-series).

---

## Key Config Details

- **SageAttention2 fork**: https://github.com/gameblabla/SageAttention2 (modified for Turing)
- **PyTorch caching**: `PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True` prevents VRAM from staying locked after OOMs
- **SageAttention is baked into the image** — compiles once at build time, not on every container start
- **entrypoint.sh** is intentionally minimal — all setup happens in the Dockerfile
