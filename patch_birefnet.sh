#!/bin/bash

# ==============================================================================
# 🚀 BiRefNet ImportError Hotfix for ComfyUI
# Developed and tested on Ubuntu 24.04.4 LTS / PyTorch 2.5.1+cu121
# ==============================================================================

echo "🔍 Starting BiRefNet path optimization..."

# 1. Navigate to the absolute expected directory
TARGET_DIR="custom_nodes/ComfyUI-BiRefNet-ZHO"

if [ -d "$TARGET_DIR" ]; then
    cd "$TARGET_DIR" || exit
    
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
    echo "❌ Error: Directory '$TARGET_DIR' not found."
    echo "💡 Make sure to run this script from your main ComfyUI root directory!"
    exit 1
fi
