# 🚀 Genna & FLOAT: Zero Background Distortion Pipeline with BiRefNet

This repository provides an optimized ComfyUI pipeline tailored for consumer and budget GPUs with **8GB VRAM**. It solves the common background warping/distortion issue encountered when using the FLOAT (Flow Matching for Audio-driven Talking Portrait) engine for dynamic avatar animations.

By isolating Genna using `ComfyUI-BiRefNet-ZHO` prior to the animation stage, we ensure the surrounding environment remains 100% static, crisp, and pixel-perfect.

---

## 🎯 The Core Logic

Instead of feeding a full image into FLOAT, the process is split into three distinct phases to save VRAM and maintain quality:
1. **Extraction:** BiRefNet cuts Genna out, creating a transparent Alpha channel.
2. **Animation:** FLOAT animates *only* the isolated, background-free avatar.
3. **Compositing:** The animated frame sequence is layered back onto the untouched, crisp original background.

The Repository were using right here is ZHO-ZHO-ZHO >>> https://github.com/ZHO-ZHO-ZHO/ComfyUI-BiRefNet-ZHO
---

# 🚀 Genna & FLOAT: Zero Background Distortion Pipeline with BiRefNet

This repository provides optimized configurations and essential hotfixes tailored for running advanced generative pipelines on consumer and budget GPUs with **8GB VRAM**. 

It specifically solves the common background warping/distortion issue encountered when using the FLOAT (Flow Matching for Audio-driven Talking Portrait) engine for dynamic avatar animations. By isolating Genna using `ComfyUI-BiRefNet-ZHO` prior to the animation stage, the surrounding environment remains 100% static, crisp, and pixel-perfect.

---

## 📺 YouTube Tutorial & Lab System Specifications

In the [YouTube Video Linked to this Repo](YOUR_YOUTUBE_VIDEO_URL_HERE), I will show how to get the entire workflow running on **Ubuntu 24.04.4 LTS**. 

The pipeline and optimizations were developed, patched, and benchmarked using the following specialized hardware and environment setup:

### 💻 Hardware Specifications
* **Operating System:** Ubuntu 24.04.4 LTS (Noble Numbat)
* **GPU:** NVIDIA Tesla P4 (8GB VRAM / Pascal Architecture) / *Equivalent to GTX 1080*
  * *Note:* Headless server card without physical display outputs. The Linux desktop environment and monitor output are fully driven by the Intel CPU's iGPU, dedicating the Tesla card purely to AI inference.
* **CPU:** Intel(R) Core(TM) i7-6700T (Providing active Intel iGPU layer)
* **System RAM:** 24 GB

### 📦 Runtime Alignment & Dependencies
Our lab operates completely headless regarding system-wide `nvcc` dependencies (`nvidia-cuda-toolkit` is **NOT** required). Instead, we rely entirely on the isolated execution layers inside our Python virtual environment to guarantee stable execution of modern latent diffusion networks.

| Package | Version | Specific Purpose in Stack |
| :--- | :--- | :--- |
| **torch** | `2.5.1+cu121` | Tensor computations (Pascal Legacy Wheel) |
| **torchvision** | `0.20.1+cu121` | Image processing and visual pipelines |
| **torchaudio** | `2.5.1+cu121` | Audio processing & audio-focused nodes |
| **transformers** | `5.9.0` | Text encoder parsing (Required for Qwen3 GGUF) |
| **numpy** | `2.3.5` | Array operations (Strict Array Mode for VFX masks) |
| **safetensors** | `0.7.0` | High-speed secure model weight loading |
| **accelerate** | `1.12.0` | VRAM management (Essential for `--lowvram`) |
| **einops** | `0.8.1` | Matrix transformations for diffusion architectures |

---

## 🎯 The Core Logic

Instead of feeding a full image into FLOAT, the process is split into three distinct phases to save VRAM and maintain quality:
1. **Extraction:** BiRefNet cuts Genna out, creating a transparent Alpha channel.
2. **Animation:** FLOAT animates *only* the isolated, background-free avatar.
3. **Compositing:** The animated frame sequence is layered back onto the untouched, crisp original background.

*The full visual setup and node-by-node connection guide are demonstrated in the linked video tutorial.*

---

## 💾 Optimization Command for Pascal Architecture (8GB VRAM)

To prevent CUDA Out-of-Memory (OOM) crashes on the Tesla P4 or similar 8GB GPUs, I always launch ComfyUI with the following optimization arguments:
```bash
python main.py --enable-manager-legacy-ui --lowvram --fp16-unet --fp16-vae --preview-method taesd --disable-smart-memory --disable-pinned-memory
```
USE THE FLAGS - WORKING BEST FOR YOUR NEEDS

*Tip:* Place a `Purge VRAM` node right after the BiRefNet stage to unload the heavy segmentation weights from the GPU memory before the intensive FLOAT rendering sequence begins.



---

## 💾 Recommended Launch Flags for 8GB VRAM

To prevent CUDA Out-of-Memory (OOM) crashes on 8GB GPUs,I always launch ComfyUI with the following optimization arguments, on my Tesla P4 8GB-Server GPU 
```bash
python main.py --lowvram --fp16-unet --fp16-vae --preview-method taesd --disable-smart-memory --disable-pinned-memory
```

*Tip:* Place a `Purge VRAM` node right after the BiRefNet stage to unload the segmentation weights before the heavy FLOAT rendering starts.
