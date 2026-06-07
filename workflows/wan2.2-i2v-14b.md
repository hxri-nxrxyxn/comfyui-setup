# Wan2.2 I2V 14B — Workflow Notes

Image-to-video with first frame + end frame conditioning, using LoRA for 4-step inference.

---

## Models Required

| File | Type | Size |
|---|---|---|
| `wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors` | Diffusion (high noise) | ~27 GB total (both) |
| `wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors` | Diffusion (low noise) | (same dir) |
| `wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors` | LoRA — 4-step | ~2.3 GB |
| `wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors` | LoRA — 4-step | ~2.3 GB |
| `umt5_xxl_fp8_e4m3fn_scaled.safetensors` | Text encoder (T5-XXL) | ~6.3 GB |
| `wan_2.1_vae.safetensors` | VAE | ~243 MB |

**Model paths under `models/`:**

```
models/diffusion_models/
models/text_encoders/
models/vae/
models/loras/
```

---

## Performance

Tested on **single RTX 2080 Ti** (22 GB, compute 7.5) with `--lowvram --use-sage-attention`.

| Metric | Value |
|---|---|
| **Model** | wan2.2_i2v_14B (fp8) |
| **LoRA** | lightx2v 4-step |
| **Conditioning** | First frame + end frame |
| **Output resolution** | 640×640 |
| **Output duration** | 5.06 sec |
| **Frame rate** | 16 fps |
| **Total frames** | 81 |
| **Output file size** | 1.2 MB (H.264) |
| **Prompt execution time** | **294.25 sec (≈4.9 min)** |
| **Time per frame** | ~3.6 sec/frame |
| **SageAttention** | ✓ active (`Using sage attention`) |
| **VRAM mode** | `--lowvram` |
| **OOM without lowvram** | `--highvram` fails — T5 encoder + UNet exceed 22 GB |

---

## Notes

- fp8 models are essential for fitting on 22 GB
- The 4-step LoRA dramatically reduces inference time vs standard 50-step sampling
- First frame + end frame conditioning adds ~10–20% overhead over first frame only
- Output is 16 fps H.264 — can be re-encoded to 24/30 fps in post
