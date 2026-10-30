#!/usr/bin/env python3
"""
TeaYield AI - On-Device Leaf Shoot Maturity Classifier v2 (Optimized)
Trains MobileNetV3-Small with Cosine Annealing, Label Smoothing, and
Spatial-Photometric Augmentations on 4-class tea maturity dataset.
Exports TeaShootClassifier_v2.mlmodel for Apple Silicon Neural Engine edge execution.

Author: Bhanuka Bandara (Student ID: 082 | Coventry ID: 16604375)
Module: iOS Application Development (BSCCOMP25.1P)
Target Framework: Apple Core ML (NeuralNetwork / iOS 14.0+)
"""

import os
import sys
import time
import copy
from pathlib import Path

import torch
import torch.nn as nn
import torch.optim as optim
from torchvision import datasets, transforms, models
import coremltools as ct

# Workspace Paths
PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
DATA_DIR = PROJECT_ROOT / "dataset/tea_classification"
OUTPUT_MODEL_DIR = PROJECT_ROOT / "TeaYieldAI/Models/CoreML"
OUTPUT_MODEL_PATH = OUTPUT_MODEL_DIR / "TeaShootClassifier_v2.mlmodel"

# Hyperparameters (Optimized v2 Pipeline)
NUM_CLASSES = 4
BATCH_SIZE = 32
EPOCHS = 10
INITIAL_LR = 0.0008
WEIGHT_DECAY = 1e-4
LABEL_SMOOTHING = 0.1
IMAGE_SIZE = 224

CLASS_LABELS = [
    "1-2 Days",
    "3-4 Days",
    "5-7 Days",
    "7+ Days"
]

def main():
    print("=" * 75)
    print("TeaYield AI - Leaf Shoot Maturity Classifier Training (v2.0 Optimized)")
    print("=" * 75)
    
    if not (DATA_DIR / "train").exists():
        print(f"Error: Training dataset not found at {DATA_DIR / 'train'}")
        print("Please run scripts/model_training/prepare_dataset.py first.")
        sys.exit(1)

    OUTPUT_MODEL_DIR.mkdir(parents=True, exist_ok=True)

    # 1. Enhanced Data Augmentation Pipeline
    # Plucked tea shoots in harvest baskets or sorting trays exhibit rotational symmetry
    # and variable field illumination (direct sun, morning mist, shaded canopy).
    print("\n[1/6] Configuring enhanced spatial and photometric augmentations...")
    train_transforms = transforms.Compose([
        transforms.Resize((256, 256)),
        transforms.RandomResizedCrop(IMAGE_SIZE, scale=(0.8, 1.0), ratio=(0.9, 1.1)),
        transforms.RandomHorizontalFlip(p=0.5),
        transforms.RandomVerticalFlip(p=0.5),
        transforms.RandomRotation(degrees=25),
        transforms.ColorJitter(brightness=0.15, contrast=0.15, saturation=0.15, hue=0.05),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])

    val_transforms = transforms.Compose([
        transforms.Resize((256, 256)),
        transforms.CenterCrop(IMAGE_SIZE),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])

    train_dataset = datasets.ImageFolder(DATA_DIR / "train", transform=train_transforms)
    val_dataset = datasets.ImageFolder(DATA_DIR / "valid", transform=val_transforms)
    test_dataset = datasets.ImageFolder(DATA_DIR / "test", transform=val_transforms)

    train_loader = torch.utils.data.DataLoader(train_dataset, batch_size=BATCH_SIZE, shuffle=True, num_workers=2)
    val_loader = torch.utils.data.DataLoader(val_dataset, batch_size=BATCH_SIZE, shuffle=False, num_workers=2)
    test_loader = torch.utils.data.DataLoader(test_dataset, batch_size=BATCH_SIZE, shuffle=False, num_workers=2)

    print(f"Dataset summary: Train: {len(train_dataset)} | Validation: {len(val_dataset)} | Test: {len(test_dataset)}")
    print(f"Target class mappings: {train_dataset.classes}")

    # 2. Backbone Architecture Initialization (MobileNetV3-Small)
    print("\n[2/6] Loading MobileNetV3-Small backbone with pretrained ImageNet weights...")
    model = models.mobilenet_v3_small(weights=models.MobileNet_V3_Small_Weights.DEFAULT)

    # Adapt classifier head for 4 temporal maturity classes
    in_features = model.classifier[3].in_features
    model.classifier[3] = nn.Linear(in_features, NUM_CLASSES)

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Active training compute device: {device}")
    model = model.to(device)

    # Loss function with Label Smoothing (0.1) to mitigate overconfidence between adjacent maturity days
    criterion = nn.CrossEntropyLoss(label_smoothing=LABEL_SMOOTHING)
    
    # AdamW with weight decay to enforce L2 weight regularization
    optimizer = optim.AdamW(model.parameters(), lr=INITIAL_LR, weight_decay=WEIGHT_DECAY)

    # Cosine Annealing Learning Rate Scheduler for smooth convergence
    scheduler = optim.lr_scheduler.CosineAnnealingLR(optimizer, T_max=EPOCHS, eta_min=1e-5)

    # 3. Training Loop with Best-Validation Checkpointing
    print(f"\n[3/6] Starting 10-epoch training loop with Cosine Annealing & Checkpointing...")
    start_time = time.time()

    best_val_acc = 0.0
    best_model_weights = copy.deepcopy(model.state_dict())

    for epoch in range(1, EPOCHS + 1):
        model.train()
        running_loss = 0.0
        correct = 0
        total = 0

        current_lr = optimizer.param_groups[0]['lr']

        for inputs, labels in train_loader:
            inputs, labels = inputs.to(device), labels.to(device)
            optimizer.zero_grad()
            outputs = model(inputs)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()

            running_loss += loss.item() * inputs.size(0)
            _, predicted = outputs.max(1)
            total += labels.size(0)
            correct += predicted.eq(labels).sum().item()

        scheduler.step()

        epoch_loss = running_loss / total
        epoch_acc = (correct / total) * 100.0

        # Validation Phase
        model.eval()
        val_loss = 0.0
        val_correct = 0
        val_total = 0
        with torch.no_grad():
            for inputs, labels in val_loader:
                inputs, labels = inputs.to(device), labels.to(device)
                outputs = model(inputs)
                loss = criterion(outputs, labels)
                val_loss += loss.item() * inputs.size(0)
                _, predicted = outputs.max(1)
                val_total += labels.size(0)
                val_correct += predicted.eq(labels).sum().item()

        val_acc = (val_correct / val_total) * 100.0
        is_best = val_acc > best_val_acc

        if is_best:
            best_val_acc = val_acc
            best_model_weights = copy.deepcopy(model.state_dict())

        marker = " [NEW BEST]" if is_best else ""
        print(f"Epoch [{epoch:02d}/{EPOCHS:02d}] LR: {current_lr:.6f} | Train Loss: {epoch_loss:.4f} | Train Acc: {epoch_acc:.2f}% | Val Acc: {val_acc:.2f}%{marker}")

    elapsed = time.time() - start_time
    print(f"\nTraining completed in {elapsed:.1f} seconds. Peak validation accuracy: {best_val_acc:.2f}%")

    # Restore optimal model checkpoint
    print("[4/6] Restoring peak validation checkpoint for final evaluation...")
    model.load_state_dict(best_model_weights)
    pth_path = OUTPUT_MODEL_DIR / "TeaShootClassifier_v2.pth"
    torch.save(model.state_dict(), pth_path)
    print(f"Saved PyTorch weights checkpoint to: {pth_path}")

    # 4. Rigorous Unseen Test Split Evaluation & Confusion Matrix
    print("\n[5/6] Performing comprehensive evaluation on 218 unseen test images...")
    model.eval()
    test_correct = 0
    test_total = 0

    confusion_matrix = [[0 for _ in range(NUM_CLASSES)] for _ in range(NUM_CLASSES)]
    all_preds = []
    all_labels = []

    with torch.no_grad():
        for inputs, labels in test_loader:
            inputs, labels = inputs.to(device), labels.to(device)
            outputs = model(inputs)
            _, predicted = outputs.max(1)
            test_total += labels.size(0)
            test_correct += predicted.eq(labels).sum().item()

            for t, p in zip(labels.view(-1), predicted.view(-1)):
                confusion_matrix[t.long()][p.long()] += 1
                all_labels.append(t.item())
                all_preds.append(p.item())

    test_acc = (test_correct / test_total) * 100.0

    print("-" * 75)
    print(f"4-Class Overall Test Accuracy: {test_acc:.2f}% ({test_correct}/{test_total})")
    print("-" * 75)
    print("Confusion Matrix (Rows: Ground Truth, Cols: Predicted):")
    header = f"{'Actual':<16} | " + " | ".join(f"{cls:<10}" for cls in CLASS_LABELS)
    print(header)
    print("-" * len(header))
    for i, row in enumerate(confusion_matrix):
        row_str = " | ".join(f"{val:<10}" for val in row)
        print(f"{CLASS_LABELS[i]:<16} | {row_str}")

    # Per-Class Precision, Recall, and F1
    print("\nPer-Class Performance Metrics:")
    for i in range(NUM_CLASSES):
        tp = confusion_matrix[i][i]
        fp = sum(confusion_matrix[r][i] for r in range(NUM_CLASSES) if r != i)
        fn = sum(confusion_matrix[i][c] for c in range(NUM_CLASSES) if c != i)
        precision = (tp / (tp + fp)) * 100.0 if (tp + fp) > 0 else 0.0
        recall = (tp / (tp + fn)) * 100.0 if (tp + fn) > 0 else 0.0
        f1 = (2 * precision * recall) / (precision + recall) if (precision + recall) > 0 else 0.0
        print(f" - {CLASS_LABELS[i]:<12}: Precision: {precision:5.2f}% | Recall: {recall:5.2f}% | F1-Score: {f1:5.2f}%")

    # Composite Binary Fine Leaf Quality Metric (T1 + T2 vs T3 + T4)
    # T1 (1-2 Days) + T2 (3-4 Days) = Fine Leaf (Acceptable for export auction)
    # T3 (5-7 Days) + T4 (7+ Days) = Coarse Leaf (Downgraded/rejected)
    binary_correct = 0
    for gt, pred in zip(all_labels, all_preds):
        gt_is_fine = (gt in [0, 1])
        pred_is_fine = (pred in [0, 1])
        if gt_is_fine == pred_is_fine:
            binary_correct += 1

    binary_acc = (binary_correct / test_total) * 100.0
    print("-" * 75)
    print(f"Composite Fine Leaf Binary Accuracy (85% Export Auction Benchmark): {binary_acc:.2f}%")
    print(f"Correctly separated Fine Leaf vs Coarse Leaf: {binary_correct}/{test_total}")
    print("-" * 75)

    # 5. CoreML Model Conversion & Export (v2)
    print(f"\n[6/6] Converting and exporting to Apple Core ML format ({OUTPUT_MODEL_PATH})...")
    model.eval()
    model.cpu()

    # Create TorchScript trace
    example_input = torch.rand(1, 3, IMAGE_SIZE, IMAGE_SIZE)
    traced_model = torch.jit.trace(model, example_input)

    # CoreML Image Input Preprocessing matching PyTorch ImageNet normalization
    image_input = ct.ImageType(
        name="image",
        shape=(1, 3, IMAGE_SIZE, IMAGE_SIZE),
        scale=1.0 / (255.0 * 0.226),
        bias=[-0.485 / 0.229, -0.456 / 0.224, -0.406 / 0.225],
        color_layout=ct.colorlayout.RGB
    )

    classifier_config = ct.ClassifierConfig(class_labels=CLASS_LABELS)

    mlmodel = ct.convert(
        traced_model,
        inputs=[image_input],
        classifier_config=classifier_config,
        convert_to="neuralnetwork",
        minimum_deployment_target=ct.target.iOS14
    )

    # Academic & Professional Metadata Specifications
    mlmodel.author = "Bhanuka Bandara (Student ID: 082 | Coventry ID: 16604375)"
    mlmodel.license = "MIT - Academic Coursework (BSCCOMP25.1P)"
    mlmodel.short_description = "TeaYield AI v2.0 - On-device tea shoot maturity classifier with Cosine Annealing and Label Smoothing."
    mlmodel.version = "2.0.0"

    mlmodel.input_description["image"] = "Live camera frame or photo library tea shoot photograph (224x224 RGB)"
    for out in mlmodel.get_spec().description.output:
        if out.name == "classLabel":
            mlmodel.output_description["classLabel"] = "Top predicted maturity class (1-2 Days, 3-4 Days, 5-7 Days, 7+ Days)"
        else:
            mlmodel.output_description[out.name] = "Probability distribution across all 4 maturity classes"

    mlmodel.save(str(OUTPUT_MODEL_PATH))
    model_size_mb = os.path.getsize(OUTPUT_MODEL_PATH) / (1024 * 1024)

    print("=" * 75)
    print(f"CoreML Export SUCCESS: {OUTPUT_MODEL_PATH.name}")
    print(f"Destination: {OUTPUT_MODEL_PATH}")
    print(f"Model File Size: {model_size_mb:.2f} MB")
    print(f"Overall 4-Class Test Accuracy: {test_acc:.2f}%")
    print(f"Composite Fine Leaf Accuracy: {binary_acc:.2f}%")
    print("Apple Silicon Neural Engine (NPU) Ready!")
    print("=" * 75)

if __name__ == "__main__":
    main()
