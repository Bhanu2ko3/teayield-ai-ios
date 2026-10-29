#!/usr/bin/env python3
"""
Registers Component 5 files and synchronizes all project build phases in TeaYieldAI.xcodeproj/project.pbxproj
"""

import sys
from pathlib import Path
import re

PBX_PATH = Path("TeaYieldAI.xcodeproj/project.pbxproj")

with open(PBX_PATH, "r", encoding="utf-8") as f:
    content = f.read()

# 1. Component 5 Files Definition
# (BuildFileID, FileRefID, Filename, GroupID, Target: 'app' | 'test')
comp5_files = [
    ("74ABCA02308D0E0000E22417", "74ABCA01308D0E0000E22417", "YieldAnalyticsItem.swift", "74ABC7A2308D053100E22417", "app"),
    ("74ABCA04308D0E0000E22417", "74ABCA03308D0E0000E22417", "HapticFeedback.swift", "74ABC7B1308D053100E22417", "app"),
    ("74ABCA06308D0E0000E22417", "74ABCA05308D0E0000E22417", "YieldComparisonChartView.swift", "74ABC849308D090100E22417", "app"),
    ("74ABCA08308D0E0000E22417", "74ABCA07308D0E0000E22417", "NDVITrendChartView.swift", "74ABC849308D090100E22417", "app"),
    ("74ABCA0A308D0E0000E22417", "74ABCA09308D0E0000E22417", "FactoryCapacityChartView.swift", "74ABC849308D090100E22417", "app"),
    ("74ABCA0C308D0E0000E22417", "74ABCA0B308D0E0000E22417", "ManagerAnalyticsDashboardView.swift", "74ABC848308D090100E22417", "app"),
    ("74ABCA0E308D0E0000E22417", "74ABCA0D308D0E0000E22417", "ManagerExecutiveSuiteView.swift", "74ABC848308D090100E22417", "app"),
    ("74ABCA10308D0E0000E22417", "74ABCA0F308D0E0000E22417", "YieldAnalyticsTests.swift", "74ABC9E1308D0D0000E22417", "test"),
]

# Add PBXBuildFile entries if not present
bf_anchor = "/* Begin PBXBuildFile section */\n"
bf_entries = ""
for bf_id, fr_id, fn, gid, target in comp5_files:
    entry = f"\t\t{bf_id} /* {fn} in Sources */ = {{isa = PBXBuildFile; fileRef = {fr_id} /* {fn} */; }};\n"
    if bf_id not in content:
        bf_entries += entry

content = content.replace(bf_anchor, bf_anchor + bf_entries)

# Add PBXFileReference entries if not present
fr_anchor = "/* Begin PBXFileReference section */\n"
fr_entries = ""
for bf_id, fr_id, fn, gid, target in comp5_files:
    entry = f"\t\t{fr_id} /* {fn} */ = {{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = {fn}; sourceTree = \"<group>\"; }};\n"
    if fr_id not in content:
        fr_entries += entry

content = content.replace(fr_anchor, fr_anchor + fr_entries)

# Add to Groups
for bf_id, fr_id, fn, gid, target in comp5_files:
    ref_str = f"\t\t\t\t{fr_id} /* {fn} */,\n"
    if ref_str not in content:
        # locate group
        group_pattern = rf"({gid} /\* [^*]+ \*/ = {{\n\s*isa = PBXGroup;\n\s*children = \(\n)"
        match = re.search(group_pattern, content)
        if match:
            content = content[:match.end()] + ref_str + content[match.end():]
        else:
            print(f"Warning: Group {gid} not found for {fn}")

# Now add missing sources to 74ABC75A308D036400E22417 (Main App Sources)
main_sources_anchor = "74ABC75A308D036400E22417 /* Sources */ = {\n\t\t\tisa = PBXSourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n"

# The 19 files from earlier components plus the 7 new comp 5 app files
sources_to_inject = [
    # Comp 5 app sources
    ("74ABCA02308D0E0000E22417", "YieldAnalyticsItem.swift"),
    ("74ABCA04308D0E0000E22417", "HapticFeedback.swift"),
    ("74ABCA06308D0E0000E22417", "YieldComparisonChartView.swift"),
    ("74ABCA08308D0E0000E22417", "NDVITrendChartView.swift"),
    ("74ABCA0A308D0E0000E22417", "FactoryCapacityChartView.swift"),
    ("74ABCA0C308D0E0000E22417", "ManagerAnalyticsDashboardView.swift"),
    ("74ABCA0E308D0E0000E22417", "ManagerExecutiveSuiteView.swift"),
    # Comp 3 Phase A, B, C, D, E app sources
    ("74ABC890308D0C0100E22417", "LocationServiceProtocol.swift"),
    ("74ABC892308D0C0100E22417", "LocationService.swift"),
    ("74ABC880308D0B0100E22417", "GeoJSONParser.swift"),
    ("74ABC882308D0B0100E22417", "TeaFieldMapItem.swift"),
    ("74ABC884308D0B0100E22417", "FieldMapViewModel.swift"),
    ("74ABC886308D0B0100E22417", "InteractiveMapView.swift"),
    ("74ABC888308D0B0100E22417", "FieldDetailBottomSheetView.swift"),
    ("74ABC88A308D0B0100E22417", "FieldMapView.swift"),
    ("74ABC860308D0A0100E22417", "LeafQualityAssessment.swift"),
    ("74ABC862308D0A0100E22417", "CameraServiceProtocol.swift"),
    ("74ABC864308D0A0100E22417", "VisionLeafClassifierProtocol.swift"),
    ("74ABC866308D0A0100E22417", "CameraService.swift"),
    ("74ABC868308D0A0100E22417", "VisionLeafClassifier.swift"),
    ("74ABC86A308D0A0100E22417", "LeafScannerViewModel.swift"),
    ("74ABC86C308D0A0100E22417", "LeafScannerView.swift"),
    ("74ABC86E308D0A0100E22417", "CameraPreviewView.swift"),
    ("74ABC870308D0A0100E22417", "ScannerHudOverlayView.swift"),
    ("74ABC872308D0A0100E22417", "TeaShootClassifier_v2.mlmodel"),
    ("74ABC874308D0A0100E22417", "TeaShootClassifier.mlmodel"),
]

main_sources_entries = ""
for bf_id, fn in sources_to_inject:
    entry = f"\t\t\t\t{bf_id} /* {fn} in Sources */,\n"
    if entry not in content:
        main_sources_entries += entry

content = content.replace(main_sources_anchor, main_sources_anchor + main_sources_entries)

# Resources for Main App: 74ABC75C308D036400E22417
main_resources_anchor = "74ABC75C308D036400E22417 /* Resources */ = {\n\t\t\tisa = PBXResourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n"
resources_to_inject = [
    ("74ABC876308D0A0100E22417", "sample_fine_shoot.jpg"),
    ("74ABC878308D0A0100E22417", "sample_coarse_leaf.jpg"),
]
main_resources_entries = ""
for bf_id, fn in resources_to_inject:
    entry = f"\t\t\t\t{bf_id} /* {fn} in Resources */,\n"
    if entry not in content:
        main_resources_entries += entry

content = content.replace(main_resources_anchor, main_resources_anchor + main_resources_entries)

# Test Target Sources: 74ABC76A308D036800E22417
test_sources_anchor = "74ABC76A308D036800E22417 /* Sources */ = {\n\t\t\tisa = PBXSourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n"
test_entry = "\t\t\t\t74ABCA10308D0E0000E22417 /* YieldAnalyticsTests.swift in Sources */,\n"
if test_entry not in content:
    content = content.replace(test_sources_anchor, test_sources_anchor + test_entry)

with open(PBX_PATH, "w", encoding="utf-8") as f:
    f.write(content)

print("project.pbxproj successfully synchronized with Component 5 and all previous build phases.")
