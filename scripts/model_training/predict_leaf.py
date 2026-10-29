#!/usr/bin/env python3
"""
TeaYield AI - Local Leaf Shoot Maturity & Heap Quality Inspection Script
Loads the trained MobileNetV3-Small model and evaluates input tea leaf photographs.
Supports single shoot close-ups or batch evaluation across multiple heap locations,
computing individual maturity distributions and aggregated Fine Leaf Ratio for export grading.

Usage:
    Single Image:
        ./.venv_ml/bin/python scripts/model_training/predict_leaf.py test_images/photo1.jpg

    Batch Heap Inspection (Multiple Photos):
        ./.venv_ml/bin/python scripts/model_training/predict_leaf.py test_images/

Author: Bhanuka Bandara (Student ID: 082 | Coventry ID: 16604375)
Module: iOS Application Development (BSCCOMP25.1P)
"""

import sys
import os
from pathlib import Path
from PIL import Image
import torch
import torch.nn as nn
from torchvision import models, transforms

PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
WEIGHTS_PATH = PROJECT_ROOT / "TeaYieldAI/Models/CoreML/TeaShootClassifier_v2.pth"
DEFAULT_SAMPLE = PROJECT_ROOT / "TeaYieldAI/Preview Content/sample_fine_shoot.jpg"
TEST_IMAGES_DIR = PROJECT_ROOT / "test_images"

CLASS_LABELS = [
    "1-2 Days (Tender Bud)",
    "3-4 Days (Standard Two Leaves & a Bud)",
    "5-7 Days (Maturing Three Leaves)",
    "7+ Days (Coarse Foliage / Overgrown)"
]

CLASS_SHORT = [
    "1-2 Days",
    "3-4 Days",
    "5-7 Days",
    "7+ Days"
]

def load_model():
    if not WEIGHTS_PATH.exists():
        print(f"Error: Model checkpoint not found at: {WEIGHTS_PATH}")
        print("Please train the model first using train_tea_classifier_v2.py")
        sys.exit(1)

    model = models.mobilenet_v3_small(weights=None)
    in_features = model.classifier[3].in_features
    model.classifier[3] = nn.Linear(in_features, 4)

    state_dict = torch.load(WEIGHTS_PATH, map_location=torch.device("cpu"))
    model.load_state_dict(state_dict)
    model.eval()
    return model

def analyze_single_image(model, image_path: Path, transform):
    try:
        raw_img = Image.open(image_path).convert("RGB")
    except Exception as e:
        print(f"Failed to read image {image_path.name}: {e}")
        return None

    input_tensor = transform(raw_img).unsqueeze(0)

    with torch.no_grad():
        logits = model(input_tensor)
        probabilities = torch.softmax(logits, dim=1).squeeze(0).tolist()

    top_idx = int(torch.argmax(logits, dim=1).item())
    fine_leaf_ratio = (probabilities[0] + probabilities[1]) * 100.0
    coarse_leaf_ratio = (probabilities[2] + probabilities[3]) * 100.0

    return {
        "filename": image_path.name,
        "path": image_path,
        "top_label": CLASS_LABELS[top_idx],
        "top_short": CLASS_SHORT[top_idx],
        "confidence": probabilities[top_idx] * 100.0,
        "probabilities": probabilities,
        "fine_leaf_ratio": fine_leaf_ratio,
        "coarse_leaf_ratio": coarse_leaf_ratio
    }

def print_single_result(res: dict):
    print("=" * 70)
    print("TeaYield AI - Tea Shoot Maturity & Quality Analysis")
    print("=" * 70)
    print(f"Analyzing photograph : {res['filename']}")
    print(f"Absolute path        : {res['path']}")
    print("\n[Analysis Results]")
    print(f"Primary Classification : {res['top_label']}")
    print(f"Confidence             : {res['confidence']:.2f}%")
    print("-" * 70)
    print("Maturity Age Probability Distribution:")
    for i in range(4):
        bar_len = int(res['probabilities'][i] * 35)
        bar = "#" * bar_len + "-" * (35 - bar_len)
        print(f"  {CLASS_SHORT[i]:<10} : [{bar}] {res['probabilities'][i] * 100.0:5.2f}%")

    print("-" * 70)
    print(f"Composite Fine Leaf Ratio (T1 + T2)   : {res['fine_leaf_ratio']:.2f}%")
    print(f"Composite Coarse Leaf Ratio (T3 + T4) : {res['coarse_leaf_ratio']:.2f}%")
    print("-" * 70)

    if res['fine_leaf_ratio'] >= 85.0:
        verdict = "PASSED - EXPORT AUCTION GRADE A (Meets 85% Fine Leaf Standard)"
        action = "Approved for high-value factory processing."
    elif res['fine_leaf_ratio'] >= 70.0:
        verdict = "WARNING - SUB-OPTIMAL GRADE B (Between 70% and 84% Fine Leaf)"
        action = "Sorting required before weighing. Supervisor inspection recommended."
    else:
        verdict = "REJECTED - EXCESS COARSE FOLIAGE (Below 70% Fine Leaf Threshold)"
        action = "Deductions apply. Plucker retargeting required for selective plucking."

    print(f"Commercial Verdict     : {verdict}")
    print(f"Recommended Action     : {action}")
    print("=" * 70)

def analyze_directory(model, dir_path: Path, transform):
    extensions = {".jpg", ".jpeg", ".png", ".webp", ".JPG", ".JPEG", ".PNG"}
    image_files = sorted([f for f in dir_path.iterdir() if f.suffix in extensions])

    if not image_files:
        print(f"No image files found in {dir_path}")
        print("Please place your tea leaf photos in this folder.")
        return

    print("=" * 75)
    print(f"TeaYield AI - Multi-Location Heap Inspection Analysis ({len(image_files)} Spot Samples)")
    print("=" * 75)
    print(f"Inspecting directory : {dir_path}")
    print("-" * 75)

    results = []
    print(f"{'#':<3} | {'Image File':<24} | {'Dominant Stage':<12} | {'Fine Leaf %':<11} | {'Status':<10}")
    print("-" * 75)

    for idx, img_path in enumerate(image_files, start=1):
        res = analyze_single_image(model, img_path, transform)
        if res is None:
            continue
        results.append(res)
        status = "PASS (A)" if res['fine_leaf_ratio'] >= 85.0 else ("WARN (B)" if res['fine_leaf_ratio'] >= 70.0 else "FAIL (C)")
        print(f"{idx:<3} | {res['filename'][:24]:<24} | {res['top_short']:<12} | {res['fine_leaf_ratio']:9.2f}% | {status:<10}")

    if not results:
        return

    # Aggregate Heap Statistics
    avg_fine = sum(r['fine_leaf_ratio'] for r in results) / len(results)
    avg_coarse = 100.0 - avg_fine

    # Average class probabilities
    avg_probs = [sum(r['probabilities'][i] for r in results) / len(results) for i in range(4)]

    print("=" * 75)
    print("AGGREGATE HEAP QUALITY SUMMARY (SURFACE SAMPLING CERTIFICATE)")
    print("=" * 75)
    print(f"Total Spot Samples Inspected       : {len(results)}")
    print(f"Overall Heap Average Fine Leaf %   : {avg_fine:.2f}%")
    print(f"Overall Heap Average Coarse Leaf % : {avg_coarse:.2f}%")
    print("-" * 75)
    print("Heap Maturity Composition Breakdown:")
    for i in range(4):
        bar_len = int(avg_probs[i] * 35)
        bar = "#" * bar_len + "-" * (35 - bar_len)
        print(f"  {CLASS_SHORT[i]:<10} : [{bar}] {avg_probs[i] * 100.0:5.2f}%")
    print("-" * 75)

    if avg_fine >= 85.0:
        heap_verdict = "PASSED - EXPORT AUCTION GRADE A (Whole Heap Meets 85% Fine Leaf Standard)"
        heap_action = "Batch approved for immediate weighing and factory dispatch."
    elif avg_fine >= 70.0:
        heap_verdict = "SUB-OPTIMAL GRADE B (Heap between 70% and 84% Fine Leaf)"
        heap_action = "Secondary sorting required to remove coarse foliage before logging weight."
    else:
        heap_verdict = "REJECTED - EXCESS COARSE FOLIAGE (Heap Below 70% Threshold)"
        heap_action = "Green leaf deduction penalty applies. Plucker selective plucking warning."

    print(f"Overall Heap Verdict : {heap_verdict}")
    print(f"Recommended Action   : {heap_action}")
    print("=" * 75)

def main():
    transform = transforms.Compose([
        transforms.Resize((256, 256)),
        transforms.CenterCrop(224),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])

    model = load_model()

    if len(sys.argv) > 1:
        target = Path(sys.argv[1]).resolve()
    else:
        # Check if test_images has photos
        extensions = {".jpg", ".jpeg", ".png", ".webp", ".JPG", ".JPEG", ".PNG"}
        if TEST_IMAGES_DIR.exists() and any(f.suffix in extensions for f in TEST_IMAGES_DIR.iterdir()):
            target = TEST_IMAGES_DIR
        else:
            target = DEFAULT_SAMPLE

    if target.is_dir():
        analyze_directory(model, target, transform)
    else:
        res = analyze_single_image(model, target, transform)
        if res:
            print_single_result(res)

if __name__ == "__main__":
    main()
