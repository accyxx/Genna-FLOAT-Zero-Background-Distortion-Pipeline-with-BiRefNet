
# 🚀 Genna & FLOAT: Zero Background Distortion Pipeline with BiRefNet

This repository provides optimized configurations and essential hotfixes tailored for running advanced generative pipelines on consumer and budget GPUs with **8GB VRAM**. 

### The Repository were using right here is ZHO-ZHO-ZHO >>> https://github.com/ZHO-ZHO-ZHO/ComfyUI-BiRefNet-ZHO

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




---

## 💾 Recommended Launch Flags for 8GB VRAM

To prevent CUDA Out-of-Memory (OOM) crashes on 8GB GPUs, I always launch ComfyUI with the following optimization arguments, on my Tesla P4 8GB-Server GPU 
```bash
python main.py --lowvram --fp16-unet --fp16-vae --preview-method taesd --disable-smart-memory --disable-pinned-memory
```
### USE THE FLAGS THAT WORKS BEST FOR YOU 

*Tip:* Place a `Purge VRAM` node right after the BiRefNet stage to unload the segmentation weights before the heavy FLOAT rendering starts.


## 🛠️ Troubleshooting: BiRefNet ImportError Fix

If you encounter the following startup error message in ComfyUI when loading the BiRefNet extension:
`ImportError: cannot import name 'path_to_image' from 'utils'`

This happens due to a naming collision where Python gets confused between the local `utils.py` inside the extension and the core ComfyUI utility files. You can use my quick code-patch to resolve this instantly.


### 🕵️‍♂️ Behind the Scenes: Some Hours of Deep Analysis

This fix is the result of some hours of rigorous troubleshooting and log analysis to pinpoint the exact root cause of the crash. Thanks to a professional architectural breakdown by my AI collaborator, we fully deciphered the underlying mechanics of how Python's module resolution pathing and the latest Hugging Face `transformers` updates collided. 

Instead of just applying a temporary bandage, we completely understood the system behavior and engineered a permanent, elegant solution that keeps your ComfyUI environment clean and stable.


### ⚠️ Compatibility Disclaimer
> [!IMPORTANT]
> This fix is guaranteed to work if you are using the **exact same system specifications** or a very similar setup (Ubuntu 24.04.4 LTS, PyTorch 2.5.1+cu121). There is **no guarantee** if you are running newer, non-LTS releases like **Ubuntu 26.04**, as I specifically develop and test on the stable LTS 24.04.4 layer to ensure environment predictability.

---

### 🚀 How to Apply the Fix

Since we want to avoid breaking anything via bash automations, you can apply this permanent local patch manually or via the terminal:

1. **Navigate to the extension directory:**
   ```bash
   cd custom_nodes/ComfyUI-BiRefNet-ZHO
   ```

2. **Rename the conflicting utility file:**
   Change the file name from `utils.py` to `biref_utils.py` so it no longer collides with ComfyUI's core files:
   ```bash
   mv utils.py biref_utils.py
   ```

<img width="675" height="315" alt="grafik" src="https://github.com/user-attachments/assets/3dde1c52-fe54-4264-94a0-aa89321ee946" />


3. **Update the internal script imports:**
   Open the files in your text editor and change the import paths, or use these two simple lines to swap them:
   ```bash
   sed -i 's/from utils import path_to_image/from biref_utils import path_to_image/g' dataset.py
   sed -i 's/import utils/import biref_utils as utils/g' preproc.py
   ```

4. **Restart ComfyUI:**
   Relaunch your ComfyUI instance. The `ImportError` will be gone, and the `🧹BiRefNet` nodes will load perfectly.

### THE PATCH IN DETAIL

### 🚀 How to Apply the Fix (Automated Script)

You can apply the permanent patch automatically using the verified script stored in this repository. Open your terminal in your **main ComfyUI root directory** and execute this single command:

### 🚀 Automated Hotfix Script

You can view or copy the entire verification and patching script directly below. To run it, you can save these lines into a local file (e.g., `patch.sh`) inside your **main ComfyUI root directory**, make it executable, and run it:

```bash
#!/bin/bash

# ==============================================================================
# 🚀 ACCYXX BiRefNet ImportError Hotfix for ComfyUI
# Developed and tested on Ubuntu 24.04.4 LTS / PyTorch 2.5.1+cu121
# ==============================================================================

echo "🔍 Starting BiRefNet path optimization..."

# 1. Navigate to the absolute expected directory
TARGET_DIR="custom_nodes/ComfyUI-BiRefNet-ZHO"

if [ -d "\$TARGET_DIR" ]; then
    cd "\$TARGET_DIR" || exit
    
    # 2. Check if the conflicting utils.py exists
    if [ -f "utils.py" ]; then
        echo "📦 Found conflicting utils.py. Renaming to biref_utils.py..."
        mv utils.py biref_utils.py
    else
        echo "ℹ️ utils.py already renamed or not found. Skipping move."
    fi

    # 3. Patch the internal imports cleanly
    echo "🛠️ Patching import layers in dataset.py and preproc.py..."
    sed -i 's/from utils import path_to_image/from biref_utils import path_to_image/g' dataset.py
    sed -i 's/import utils/import biref_utils as utils/g' preproc.py

    echo "✅ Fix applied successfully! Please restart ComfyUI."
else
    echo "❌ Error: Directory '\$TARGET_DIR' not found."
    echo "💡 Make sure to run this script from your main ComfyUI root directory!"
    exit 1
fi
```





### 🔄 How to Rollback (Undo the Fix)
If you ever need to restore the original repository files, run this single command from your main ComfyUI root directory:

```bash
cd custom_nodes/ComfyUI-BiRefNet-ZHO && git checkout dataset.py preproc.py && mv biref_utils.py utils.py && cd ../..
```



*Note: Keep in mind that running `git pull` on this custom node in the future might cause a conflict because of the renamed file. If you update the node later, simply back up your workflow and re-apply these steps.*


