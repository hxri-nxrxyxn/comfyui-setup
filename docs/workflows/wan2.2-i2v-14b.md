# Wan2.2 I2V 14B — Workflow Notes

Image-to-video with first frame + end frame, using lightx2v 4-step LoRA.

---

## Models Required

| File | Location | Size |
|---|---|---|
| `wan2.2_i2v_high_noise_14B_fp8_scaled` | `models/diffusion_models/` | ~27 GB |
| `wan2.2_i2v_low_noise_14B_fp8_scaled` | `models/diffusion_models/` | (same dir) |
| `lightx2v_4steps_lora_v1_high_noise` | `models/loras/` | ~2.3 GB |
| `lightx2v_4steps_lora_v1_low_noise` | `models/loras/` | ~2.3 GB |
| `umt5_xxl_fp8_e4m3fn_scaled` | `models/text_encoders/` | ~6.3 GB |
| `wan_2.1_vae` | `models/vae/` | ~243 MB |

---

## Performance

Tested on **1x RTX 2080 Ti (22 GB)** with `--lowvram`. Output: 640×640, 81 frames, 5 sec.

| Mode | Time | vs SageAttention |
|---|---|---|
| **SageAttention** | **4.9 min (294s)** | — |
| PyTorch attention | 6.8 min (407s) | +38% slower |

SageAttention saves ~2 min per generation. Same quality.

---

## Notes

- fp8 models essential for 22 GB
- 4-step LoRA much faster than standard 50-step sampling
- First + end frame conditioning adds ~10–20% overhead
