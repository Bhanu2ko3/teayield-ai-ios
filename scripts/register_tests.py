#!/usr/bin/env python3
"""
Registers Unit Test Mocks and Test Suites into TeaYieldAI.xcodeproj/project.pbxproj
under the TeaYieldAITests native target.
"""

import sys
from pathlib import Path

PBX_PATH = Path("TeaYieldAI.xcodeproj/project.pbxproj")

with open(PBX_PATH, "r", encoding="utf-8") as f:
    content = f.read()

if "LeafScannerViewModelTests.swift" in content:
    print("Test files already registered in project.pbxproj.")
    sys.exit(0)

# Mocks (BuildFileID, FileRefID, Filename)
mocks = [
    ("74ABC900308D0D0000E22417", "74ABC901308D0D0000E22417", "MockAPIService.swift"),
    ("74ABC902308D0D0000E22417", "74ABC903308D0D0000E22417", "MockAuthService.swift"),
    ("74ABC904308D0D0000E22417", "74ABC905308D0D0000E22417", "MockCameraService.swift"),
    ("74ABC906308D0D0000E22417", "74ABC907308D0D0000E22417", "MockFieldRepository.swift"),
    ("74ABC908308D0D0000E22417", "74ABC909308D0D0000E22417", "MockHarvestRepository.swift"),
    ("74ABC90A308D0D0000E22417", "74ABC90B308D0D0000E22417", "MockNDVIRepository.swift"),
    ("74ABC90C308D0D0000E22417", "74ABC90D308D0D0000E22417", "MockLocationService.swift"),
    ("74ABC90E308D0D0000E22417", "74ABC90F308D0D0000E22417", "MockSyncManager.swift"),
    ("74ABC910308D0D0000E22417", "74ABC911308D0D0000E22417", "MockVisionLeafClassifier.swift"),
    ("74ABC912308D0D0000E22417", "74ABC913308D0D0000E22417", "MockNetworkMonitor.swift"),
]

# Tests (BuildFileID, FileRefID, Filename)
tests = [
    ("74ABC920308D0D0000E22417", "74ABC921308D0D0000E22417", "LeafScannerViewModelTests.swift"),
    ("74ABC922308D0D0000E22417", "74ABC923308D0D0000E22417", "FieldMapViewModelTests.swift"),
    ("74ABC924308D0D0000E22417", "74ABC925308D0D0000E22417", "TodayTasksViewModelTests.swift"),
    ("74ABC926308D0D0000E22417", "74ABC927308D0D0000E22417", "HarvestWeighingViewModelTests.swift"),
    ("74ABC928308D0D0000E22417", "74ABC929308D0D0000E22417", "LocationServiceTests.swift"),
    ("74ABC92A308D0D0000E22417", "74ABC92B308D0D0000E22417", "GeoJSONParserTests.swift"),
    ("74ABC92C308D0D0000E22417", "74ABC92D308D0D0000E22417", "OfflineSyncManagerTests.swift"),
    ("74ABC92E308D0D0000E22417", "74ABC92F308D0D0000E22417", "DomainModelAndDTOTests.swift"),
]

all_files = mocks + tests

# 1. PBXBuildFile Section
build_file_entries = ""
for bf_id, fr_id, fn in all_files:
    build_file_entries += f"\t\t{bf_id} /* {fn} in Sources */ = {{isa = PBXBuildFile; fileRef = {fr_id} /* {fn} */; }};\n"

build_files_anchor = "/* Begin PBXBuildFile section */\n"
content = content.replace(build_files_anchor, build_files_anchor + build_file_entries)

# 2. PBXFileReference Section
file_ref_entries = ""
for bf_id, fr_id, fn in all_files:
    file_ref_entries += f"\t\t{fr_id} /* {fn} */ = {{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = {fn}; sourceTree = \"<group>\"; }};\n"

file_refs_anchor = "/* Begin PBXFileReference section */\n"
content = content.replace(file_refs_anchor, file_refs_anchor + file_ref_entries)

# 3. Create Mocks and Tests PBXGroups
mocks_group_id = "74ABC9E0308D0D0000E22417"
tests_group_id = "74ABC9E1308D0D0000E22417"

mocks_children = "\n".join([f"\t\t\t\t{fr_id} /* {fn} */," for _, fr_id, fn in mocks])
tests_children = "\n".join([f"\t\t\t\t{fr_id} /* {fn} */," for _, fr_id, fn in tests])

new_groups = f"""\t\t{mocks_group_id} /* Mocks */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{mocks_children}
\t\t\t);
\t\t\tpath = Mocks;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{tests_group_id} /* Tests */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{tests_children}
\t\t\t);
\t\t\tpath = Tests;
\t\t\tsourceTree = "<group>";
\t\t}};
"""

# Place new groups before TeaYieldAITests group definition
target_anchor = "74ABC771308D036800E22417 /* TeaYieldAITests */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n"
updated_target_group = f"""{new_groups}\t\t74ABC771308D036800E22417 /* TeaYieldAITests */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{mocks_group_id} /* Mocks */,
\t\t\t\t{tests_group_id} /* Tests */,
"""
content = content.replace(target_anchor, updated_target_group)

# 4. Add to TeaYieldAITests Sources Build Phase (74ABC76A308D036800E22417)
sources_anchor = "74ABC76A308D036800E22417 /* Sources */ = {\n\t\t\tisa = PBXSourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n"
test_sources_entries = "".join([f"\t\t\t\t{bf_id} /* {fn} in Sources */,\n" for bf_id, _, fn in all_files])
content = content.replace(sources_anchor, sources_anchor + test_sources_entries)

with open(PBX_PATH, "w", encoding="utf-8") as f:
    f.write(content)

print(f"project.pbxproj successfully updated with {len(all_files)} test files across Mocks and Tests subgroups.")
