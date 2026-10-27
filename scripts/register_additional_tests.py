#!/usr/bin/env python3
"""
Registers additional test suites into TeaYieldAI.xcodeproj/project.pbxproj:
- AuthViewModelTests.swift
- HarvestHistoryViewModelTests.swift
- ManagerOverviewViewModelTests.swift
- SupervisorSettingsViewModelTests.swift
- CoreDataRepositoryTests.swift
"""

import sys
from pathlib import Path

PBX_PATH = Path("TeaYieldAI.xcodeproj/project.pbxproj")

with open(PBX_PATH, "r", encoding="utf-8") as f:
    content = f.read()

if "AuthViewModelTests.swift" in content:
    print("Additional test files already registered in project.pbxproj.")
    sys.exit(0)

additional_tests = [
    ("74ABC940308D0D0000E22417", "74ABC941308D0D0000E22417", "AuthViewModelTests.swift"),
    ("74ABC942308D0D0000E22417", "74ABC943308D0D0000E22417", "HarvestHistoryViewModelTests.swift"),
    ("74ABC944308D0D0000E22417", "74ABC945308D0D0000E22417", "ManagerOverviewViewModelTests.swift"),
    ("74ABC946308D0D0000E22417", "74ABC947308D0D0000E22417", "SupervisorSettingsViewModelTests.swift"),
    ("74ABC948308D0D0000E22417", "74ABC949308D0D0000E22417", "CoreDataRepositoryTests.swift"),
]

# 1. PBXBuildFile Section
build_file_entries = ""
for bf_id, fr_id, fn in additional_tests:
    build_file_entries += f"\t\t{bf_id} /* {fn} in Sources */ = {{isa = PBXBuildFile; fileRef = {fr_id} /* {fn} */; }};\n"

build_files_anchor = "/* Begin PBXBuildFile section */\n"
content = content.replace(build_files_anchor, build_files_anchor + build_file_entries)

# 2. PBXFileReference Section
file_ref_entries = ""
for bf_id, fr_id, fn in additional_tests:
    file_ref_entries += f"\t\t{fr_id} /* {fn} */ = {{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = {fn}; sourceTree = \"<group>\"; }};\n"

file_refs_anchor = "/* Begin PBXFileReference section */\n"
content = content.replace(file_refs_anchor, file_refs_anchor + file_ref_entries)

# 3. Add to Tests PBXGroup (74ABC9E1308D0D0000E22417)
tests_group_anchor = "74ABC9E1308D0D0000E22417 /* Tests */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n"
tests_group_entries = "".join([f"\t\t\t\t{fr_id} /* {fn} */,\n" for _, fr_id, fn in additional_tests])
content = content.replace(tests_group_anchor, tests_group_anchor + tests_group_entries)

# 4. Add to TeaYieldAITests Sources Build Phase (74ABC76A308D036800E22417)
sources_anchor = "74ABC76A308D036800E22417 /* Sources */ = {\n\t\t\tisa = PBXSourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n"
sources_entries = "".join([f"\t\t\t\t{bf_id} /* {fn} in Sources */,\n" for bf_id, _, fn in additional_tests])
content = content.replace(sources_anchor, sources_anchor + sources_entries)

with open(PBX_PATH, "w", encoding="utf-8") as f:
    f.write(content)

print(f"project.pbxproj successfully updated with {len(additional_tests)} additional test suites.")
