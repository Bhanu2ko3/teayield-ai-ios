#!/usr/bin/env python3
"""
TeaYield AI - Dataset Preparation Script
Extracts the Kaggle teaLeafAgeQuality dataset from /home/codebro/Downloads/archive.zip
and organizes images into 4 temporal maturity classes:
- T1_1_to_2_Days: Golden tip and tender shoot (Grade A+ supreme quality)
- T2_3_to_4_Days: Prime two leaves and a bud (Standard export auction grade)
- T3_5_to_7_Days: Maturing three leaves (Sub-standard grade B)
- T4_7_Plus_Days: Overgrown coarse foliage and woody stalks (Rejection grade C)
"""

import os
import sys
import zipfile
import shutil
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
ARCHIVE_PATH = "/home/codebro/Downloads/archive.zip"
OUTPUT_DIR = PROJECT_ROOT / "dataset/tea_classification"

CLASS_NAMES = [
    "T1_1_to_2_Days",
    "T2_3_to_4_Days",
    "T3_5_to_7_Days",
    "T4_7_Plus_Days"
]

def main():
    if not os.path.exists(ARCHIVE_PATH):
        print(f"Error: Archive not found at {ARCHIVE_PATH}")
        sys.exit(1)

    print(f"Opening archive: {ARCHIVE_PATH}")
    
    # Create target directory structure
    for split in ["train", "valid", "test"]:
        for cls_name in CLASS_NAMES:
            (OUTPUT_DIR / split / cls_name).mkdir(parents=True, exist_ok=True)

    counts = {s: {c: 0 for c in CLASS_NAMES} for s in ["train", "valid", "test"]}

    with zipfile.ZipFile(ARCHIVE_PATH, "r") as z:
        all_files = z.namelist()
        
        for split in ["train", "valid", "test"]:
            split_txts = [f for f in all_files if f.startswith(f"{split}/labels/") and f.endswith(".txt")]
            print(f"Processing {split} split ({len(split_txts)} samples)...")
            
            for txt_path in split_txts:
                # Find matching image
                base_name = Path(txt_path).stem
                img_path = f"{split}/images/{base_name}.jpg"
                
                if img_path not in all_files:
                    continue
                
                # Read class ID from first entry in label file
                content = z.read(txt_path).decode("utf-8").strip()
                if not content:
                    continue
                
                first_line = content.split("\n")[0]
                parts = first_line.split()
                if not parts:
                    continue
                
                try:
                    cls_id = int(parts[0])
                    if 0 <= cls_id < len(CLASS_NAMES):
                        cls_name = CLASS_NAMES[cls_id]
                        dest_file = OUTPUT_DIR / split / cls_name / f"{base_name}.jpg"
                        
                        # Extract image file directly to target destination
                        with z.open(img_path) as source, open(dest_file, "wb") as target:
                            shutil.copyfileobj(source, target)
                        
                        counts[split][cls_name] += 1
                except ValueError:
                    continue

    print("\nDataset preparation complete! Extracted counts:")
    for split in ["train", "valid", "test"]:
        print(f"\n[{split.upper()} SPLIT]")
        total_split = 0
        for cls_name in CLASS_NAMES:
            cnt = counts[split][cls_name]
            total_split += cnt
            print(f"  {cls_name}: {cnt} images")
        print(f"  Total: {total_split} images")

if __name__ == "__main__":
    main()
