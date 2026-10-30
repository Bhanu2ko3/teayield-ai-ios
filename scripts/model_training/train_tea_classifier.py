#!/usr/bin/env python3
"""
TeaYield AI - On-Device Leaf Shoot Maturity Classifier Training & CoreML Export
Trains MobileNetV3-Small on the 4-class tea maturity dataset and exports
TeaShootClassifier.mlmodel for Apple Silicon Neural Engine edge execution.

Author: Bhanuka Bandara (Student ID: 082 | Coventry ID: 16604375)
Module: iOS Application Development (BSCCOMP25.1P)
Target Framework: Apple Core ML (NeuralNetwork / iOS 14.0+)
"""

import os
import sys
import time
from pathlib import Path

import torch
import torch.nn as nn
import torch.optim as optim
from torchvision import datasets, transforms, models
import coremltools as ct

# Paths
PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
DATA_DIR = PROJECT_ROOT / "dataset/tea_classification"
OUTPUT_MODEL_DIR = PROJECT_ROOT / "TeaYieldAI/Models/CoreML"
OUTPUT_MODEL_PATH = OUTPUT_MODEL_DIR / "TeaShootClassifier.mlmodel"

# Hyperparameters
NUM_CLASSES = 4
BATCH_SIZE = 32
EPOCHS = 5
LEARNING_RATE = 0.001
IMAGE_SIZE = 224

CLASS_LABELS = [
    "1-2 Days",
    "3-4 Days",
    "5-7 Days",
    "7+ Days"
]

def main():
    print("=" * 70)
    print("TeaYield AI - MobileNetV3 Shoot Maturity Classifier Training")
    print("=" * 70)
    
    if not (DATA_DIR / "train").exists():
        print(f"Error: Training dataset not found at {DATA_DIR / 'train'}")
        print("Please run scripts/prepare_dataset.py first.")
        sys.exit(1)

    OUTPUT_MODEL_DIR.mkdir(parents=True, exist_ok=True)

    # 1. Image Preprocessing & Augmentation Pipelines
    print("\n[1/5] Configuring data augmentations and data loaders...")
    train_transforms = transforms.Compose([
        transforms.Resize((256, 256)),
        transforms.RandomCrop(IMAGE_SIZE),
        transforms.RandomHorizontalFlip(),
        transforms.RandomRotation(15),
        transforms.ColorJitter(brightness=0.1, contrast=0.1, saturation=0.1),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ])

    val_transforms = transforms.Compose([
        transforms.Resize((256, 256)),
        transforms.CenterCrop(IMAGE_SIZE),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ])

    train_dataset = datasets.ImageFolder(DATA_DIR / "train", transform=train_transforms)
    val_dataset = datasets.ImageFolder(DATA_DIR / "valid", transform=val_transforms)
    test_dataset = datasets.ImageFolder(DATA_DIR / "test", transform=val_transforms)

    train_loader = torch.utils.data.DataLoader(train_dataset, batch_size=BATCH_SIZE, shuffle=True, num_workers=2)
    val_loader = torch.utils.data.DataLoader(val_dataset, batch_size=BATCH_SIZE, shuffle=False, num_workers=2)
    test_loader = torch.utils.data.DataLoader(test_dataset, batch_size=BATCH_SIZE, shuffle=False, num_workers=2)

    print(f"Train samples: {len(train_dataset)} | Validation: {len(val_dataset)} | Test: {len(test_dataset)}")
    print(f"Detected class mappings: {train_dataset.classes}")

    # 2. Model Initialization (MobileNetV3-Small)
    print("\n[2/5] Initializing MobileNetV3-Small backbone with pretrained ImageNet weights...")
    model = models.mobilenet_v3_small(weights=models.MobileNet_V3_Small_Weights.DEFAULT)

    # Replace classifier head for 4 maturity classes
    in_features = model.classifier[3].in_features
    model.classifier[3] = nn.Linear(in_features, NUM_CLASSES)

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Execution compute device: {device}")
    model = model.to(device)

    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=LEARNING_RATE)

    # 3. Training Loop
    print("\n[3/5] Starting Transfer Learning fine-tuning for 5 epochs...")
    start_time = time.time()

    for epoch in range(1, EPOCHS + 1):
        model.train()
        running_loss = 0.0
        correct = 0
        total = 0

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

        epoch_loss = running_loss / total
        epoch_acc = (correct / total) * 100.0

        # Validation
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
        print(f"Epoch [{epoch}/{EPOCHS}] - Train Loss: {epoch_loss:.4f} | Train Acc: {epoch_acc:.2f}% | Val Acc: {val_acc:.2f}%")

    elapsed = time.time() - start_time
    print(f"Training completed in {elapsed:.1f} seconds.")

    # 4. Final Evaluation on Unseen Test Split
    print("\n[4/5] Evaluating final accuracy on unseen Test split...")
    model.eval()
    test_correct = 0
    test_total = 0
    with torch.no_grad():
        for inputs, labels in test_loader:
            inputs, labels = inputs.to(device), labels.to(device)
            outputs = model(inputs)
            _, predicted = outputs.max(1)
            test_total += labels.size(0)
            test_correct += predicted.eq(labels).sum().item()

    test_acc = (test_correct / test_total) * 100.0
    print(f"Test Accuracy across 218 test images: {test_acc:.2f}%")

    # 5. CoreML Model Conversion & Export
    print(f"\n[5/5] Exporting model to Apple Core ML format ({OUTPUT_MODEL_PATH})...")
    model.eval()
    model.cpu()

    # Create TorchScript trace
    example_input = torch.rand(1, 3, IMAGE_SIZE, IMAGE_SIZE)
    traced_model = torch.jit.trace(model, example_input)

    # CoreML Image Input Preprocessing (matches PyTorch ImageNet normalization)
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

    # Metadata specification for Xcode & Academic Viva
    mlmodel.author = "Bhanuka Bandara (Student ID: 082 | Coventry ID: 16604375)"
    mlmodel.license = "MIT - Academic Coursework (BSCCOMP25.1P)"
    mlmodel.short_description = "On-device tea shoot maturity classification model for Ceylon tea plucking quality evaluation."
    mlmodel.version = "1.0.0"

    mlmodel.input_description["image"] = "Live camera frame or photo library tea shoot photograph (224x224 RGB)"
    for out in mlmodel.get_spec().description.output:
        if out.name == "classLabel":
            mlmodel.output_description["classLabel"] = "Top predicted maturity class (1-2 Days, 3-4 Days, 5-7 Days, 7+ Days)"
        else:
            mlmodel.output_description[out.name] = "Probability distribution across all 4 maturity classes"

    mlmodel.save(str(OUTPUT_MODEL_PATH))
    model_size_mb = os.path.getsize(OUTPUT_MODEL_PATH) / (1024 * 1024)

    print("=" * 70)
    print(f"CoreML Export SUCCESS: {OUTPUT_MODEL_PATH}")
    print(f"Model File Size: {model_size_mb:.2f} MB")
    print(f"Class Labels: {CLASS_LABELS}")
    print("Apple Silicon Neural Engine (NPU) Ready!")
    print("=" * 70)

if __name__ == "__main__":
    main()
