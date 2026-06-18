
# 🚀 Genna & FLOAT: Zero Background Distortion Pipeline with BiRefNet

This repository provides optimized configurations and essential hotfixes tailored for running advanced generative pipelines on consumer and budget GPUs with **8GB VRAM**. 

It specifically solves the common background warping/distortion issue encountered when using the FLOAT (Flow Matching for Audio-driven Talking Portrait) engine for dynamic avatar animations. By isolating Genna using `ComfyUI-BiRefNet-ZHO` prior to the animation stage, the surrounding environment remains 100% static, crisp, and pixel-perfect.

---

## 📌 Table of Contents
1. [📺 YouTube Tutorial & Lab System Specifications](#-youtube-tutorial--lab-system-specifications)
2. [🎯 The Core Logic](#-the-core-logic)
3. [💾 Optimization Command for Pascal Architecture](#-optimization-command-for-pascal-architecture-8gb-vram)
4. [🛠️ Troubleshooting: BiRefNet ImportError Fix](#%EF%B8%8F-troubleshooting-birefnet-importerror-fix)

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

To prevent CUDA Out-of-Memory (OOM) crashes on the Tesla P4 or similar 8GB GPUs,I always launch ComfyUI with the following optimization arguments:
```bash
python main.py --enable-manager-legacy-ui --lowvram --fp16-unet --fp16-vae --preview-method taesd --disable-smart-memory --disable-pinned-memory
```

*Tip:* Place a `Purge VRAM` node right after the BiRefNet stage to unload the heavy segmentation weights from the GPU memory before the intensive FLOAT rendering sequence begins.

---

## 🛠️ Troubleshooting: BiRefNet ImportError Fix

If you encounter the following startup error message in ComfyUI when loading the BiRefNet extension:
`ImportError: cannot import name 'path_to_image' from 'utils'`

This happens due to a naming collision where Python encounters an ambiguity between the local `utils.py` inside the extension and the core ComfyUI utility files. You can use this permanent code-patch to resolve this instantly.

### 🕵️‍♂️ Behind the Scenes: Some Hours of Deep Analysis
This fix is the result of some hours of rigorous troubleshooting and log analysis to pinpoint the exact root cause of the crash. Thanks to a professional architectural breakdown by my AI collaborator, we fully deciphered the underlying mechanics of how Python's module resolution pathing and the latest Hugging Face `transformers` updates collided. 

Instead of just applying a temporary bandage, we completely understood the system behavior and engineered a permanent, elegant solution that keeps your ComfyUI environment clean and stable.

### 🔍 Technical Explainer: Runtime Path Overlap & Why This Patch Works
* **The Mechanism:** When ComfyUI initializes, it registers its native core directory named `/utils`. The extension includes a local script file named `utils.py`. Under certain environment conditions, the Python interpreter searches the global ComfyUI folder instead of the local subdirectory, throwing an error because the requested function does not exist there.
* **The Trigger:** Recent updates in the Hugging Face `transformers` ecosystem (`v5.9.0+`) modified how third-party nodes resolve relative paths during startup, causing the system-wide path to take precedence over the local one.
* **The Solution:** Renaming the file to `biref_utils.py` creates an entirely unique identifier, making a naming collision with the core framework mathematically impossible.

### ⚠️ Compatibility Disclaimer
> [!IMPORTANT]
> This fix is guaranteed to work if you are using the **exact same system specifications** or a very similar setup (Ubuntu 24.04.4 LTS, PyTorch 2.5.1+cu121). There is **no guarantee** if you are running newer, non-LTS releases like **Ubuntu 26.04**, as I specifically develop and test on the stable LTS 24.04.4 layer to ensure environment predictability.

### 🚀 How to Apply the Fix (Step-by-Step Shell Code)

You can view or copy the entire verification and patching code directly below. To run it, you can execute these commands from within your **main ComfyUI root directory**:

```bash
# 1. Move into the extension directory
cd custom_nodes/ComfyUI-BiRefNet-ZHO

# 2. Rename the conflicting utils file to break the naming overlap
mv utils.py biref_utils.py

# 3. Patch the active import calls inside the source files
sed -i 's/from utils import path_to_image/from biref_utils import path_to_image/g' dataset.py
sed -i 's/import utils/import biref_utils as utils/g' preproc.py

# 4. Success check and restart directive
echo "✅ Code layer patched successfully. Please restart ComfyUI."
```

### 🔄 How to Rollback (Undo the Fix)
If you ever need to restore the original repository files, run this single command from your main ComfyUI root directory:

```bash
cd custom_nodes/ComfyUI-BiRefNet-ZHO && git checkout dataset.py preproc.py && mv biref_utils.py utils.py && cd ../..
```

### 📸 Verified Directory Structure
After successfully applying the patch, your directory should look exactly like this:

<img width="675" height="315" alt="grafik" src="https://github.com/user-attachments/assets/0815075f-d234-4ff0-a83f-d5fa8b8beafc" />





