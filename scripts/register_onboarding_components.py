#!/usr/bin/env python3
"""
Registers the Multi-Tenant Onboarding components and tests in TeaYieldAI.xcodeproj/project.pbxproj
"""

import sys
from pathlib import Path
import re

PBX_PATH = Path("TeaYieldAI.xcodeproj/project.pbxproj")

with open(PBX_PATH, "r", encoding="utf-8") as f:
    content = f.read()

# Files definition: (BuildFileID, FileRefID, Filename, PathInGroup, GroupID, BuildPhaseID)
MAIN_SOURCES = "74ABC75A308D036400E22417"
TEST_SOURCES = "74ABC76A308D036800E22417"

new_files = [
    # 1. DistrictPickerField.swift
    ("74ABCB01308D0E0000E22417", "74ABCB02308D0E0000E22417", "DistrictPickerField.swift", "Components/DistrictPickerField.swift", "74ABC806308D070100E22417", MAIN_SOURCES),
    # 2. EstateOnboardingViewModel.swift
    ("74ABCB03308D0E0000E22417", "74ABCB04308D0E0000E22417", "EstateOnboardingViewModel.swift", "EstateOnboardingViewModel.swift", "74ABC7BC308D053100E22417", MAIN_SOURCES),
    # 3. EstateOnboardingView.swift
    ("74ABCB05308D0E0000E22417", "74ABCB06308D0E0000E22417", "EstateOnboardingView.swift", "EstateOnboardingView.swift", "74ABC806308D070100E22417", MAIN_SOURCES),
    # 4. ForcePasswordChangeViewModel.swift
    ("74ABCB07308D0E0000E22417", "74ABCB08308D0E0000E22417", "ForcePasswordChangeViewModel.swift", "ForcePasswordChangeViewModel.swift", "74ABC7BC308D053100E22417", MAIN_SOURCES),
    # 5. ForcePasswordChangeView.swift
    ("74ABCB09308D0E0000E22417", "74ABCB0A308D0E0000E22417", "ForcePasswordChangeView.swift", "ForcePasswordChangeView.swift", "74ABC7C1308D053100E22417", MAIN_SOURCES),
    # 6. InviteSupervisorViewModel.swift
    ("74ABCB0B308D0E0000E22417", "74ABCB0C308D0E0000E22417", "InviteSupervisorViewModel.swift", "InviteSupervisorViewModel.swift", "74ABC7BC308D053100E22417", MAIN_SOURCES),
    # 7. InviteSupervisorSheetView.swift
    ("74ABCB0D308D0E0000E22417", "74ABCB0E308D0E0000E22417", "InviteSupervisorSheetView.swift", "InviteSupervisorSheetView.swift", "74ABC849308D090100E22417", MAIN_SOURCES),
    # 8. MultiTenantOnboardingTests.swift
    ("74ABCB0F308D0E0000E22417", "74ABCB10308D0E0000E22417", "MultiTenantOnboardingTests.swift", "MultiTenantOnboardingTests.swift", "74ABC9E1308D0D0000E22417", TEST_SOURCES),
]

# 1. PBXBuildFile section
bf_anchor = "/* Begin PBXBuildFile section */\n"
bf_entries = ""
for bf_id, fr_id, fn, pth, gid, bp_id in new_files:
    entry = f"\t\t{bf_id} /* {fn} in Sources */ = {{isa = PBXBuildFile; fileRef = {fr_id} /* {fn} */; }};\n"
    if bf_id not in content:
        bf_entries += entry

content = content.replace(bf_anchor, bf_anchor + bf_entries)

# 2. PBXFileReference section
fr_anchor = "/* Begin PBXFileReference section */\n"
fr_entries = ""
for bf_id, fr_id, fn, pth, gid, bp_id in new_files:
    entry = f"\t\t{fr_id} /* {fn} */ = {{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = {pth}; sourceTree = \"<group>\"; }};\n"
    if f"{fr_id} /* {fn} */ = {{isa = PBXFileReference" not in content:
        fr_entries += entry

content = content.replace(fr_anchor, fr_anchor + fr_entries)

# 3. Add to respective PBXGroups
for bf_id, fr_id, fn, pth, gid, bp_id in new_files:
    ref_str = f"\t\t\t\t{fr_id} /* {fn} */,\n"
    if ref_str not in content:
        group_pattern = rf"({gid} /\* [^*]+ \*/ = {{\n\s*isa = PBXGroup;\n\s*children = \(\n)"
        match = re.search(group_pattern, content)
        if match:
            content = content[:match.end()] + ref_str + content[match.end():]
        else:
            print(f"Warning: Group {gid} not found for {fn}")

# 4. Add to Main App and Test PBXSourcesBuildPhase
for bf_id, fr_id, fn, pth, gid, bp_id in new_files:
    entry = f"\t\t\t\t{bf_id} /* {fn} in Sources */,\n"
    if entry not in content:
        phase_pattern = rf"({bp_id} /\* Sources \*/ = {{\n\s*isa = PBXSourcesBuildPhase;\n\s*buildActionMask = 2147483647;\n\s*files = \(\n)"
        match = re.search(phase_pattern, content)
        if match:
            content = content[:match.end()] + entry + content[match.end():]
        else:
            print(f"Warning: Build phase {bp_id} not found for {fn}")

with open(PBX_PATH, "w", encoding="utf-8") as f:
    f.write(content)

print(f"Successfully registered {len(new_files)} onboarding component and test files in project.pbxproj")

