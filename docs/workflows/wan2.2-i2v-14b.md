# Wan2.2 I2V 14B — Workflow Notes

Image-to-video with first frame + end frame, using lightx2v 4-step LoRA.

---

## Models Required

```
models/
├── diffusion_models/
│   ├── wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors  (14 GB)
│   └── wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors   (14 GB)
├── text_encoders/
│   └── umt5_xxl_fp8_e4m3fn_scaled.safetensors             (6.3 GB)
├── vae/
│   └── wan_2.1_vae.safetensors                              (243 MB)
└── loras/
    ├── wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors  (1.2 GB)
    └── wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors   (1.2 GB)
```

**Total: ~37 GB**

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
