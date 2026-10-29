#!/usr/bin/env python3
"""
Registers Plucker.swift, PluckerDTOs.swift, and OptimizationDTOs.swift in TeaYieldAI.xcodeproj/project.pbxproj
"""

import sys
from pathlib import Path
import re

PBX_PATH = Path("TeaYieldAI.xcodeproj/project.pbxproj")

with open(PBX_PATH, "r", encoding="utf-8") as f:
    content = f.read()

# Files definition: (BuildFileID, FileRefID, Filename, GroupID)
new_files = [
    ("74ABCA30308D0E0000E22417", "74ABCA31308D0E0000E22417", "Plucker.swift", "74ABC7A2308D053100E22417"), # Domain group
    ("74ABCA32308D0E0000E22417", "74ABCA33308D0E0000E22417", "PluckerDTOs.swift", "74ABC79B308D053100E22417"), # DTOs group
    ("74ABCA34308D0E0000E22417", "74ABCA35308D0E0000E22417", "OptimizationDTOs.swift", "74ABC79B308D053100E22417"), # DTOs group
]

# 1. PBXBuildFile section
bf_anchor = "/* Begin PBXBuildFile section */\n"
bf_entries = ""
for bf_id, fr_id, fn, gid in new_files:
    entry = f"\t\t{bf_id} /* {fn} in Sources */ = {{isa = PBXBuildFile; fileRef = {fr_id} /* {fn} */; }};\n"
    if bf_id not in content:
        bf_entries += entry

content = content.replace(bf_anchor, bf_anchor + bf_entries)

# 2. PBXFileReference section
fr_anchor = "/* Begin PBXFileReference section */\n"
fr_entries = ""
for bf_id, fr_id, fn, gid in new_files:
    entry = f"\t\t{fr_id} /* {fn} */ = {{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = {fn}; sourceTree = \"<group>\"; }};\n"
    if f"{fr_id} /* {fn} */ = {{isa = PBXFileReference" not in content:
        fr_entries += entry

content = content.replace(fr_anchor, fr_anchor + fr_entries)

# 3. Add to PBXGroup
for bf_id, fr_id, fn, gid in new_files:
    ref_str = f"\t\t\t\t{fr_id} /* {fn} */,\n"
    if ref_str not in content:
        group_pattern = rf"({gid} /\* [^*]+ \*/ = {{\n\s*isa = PBXGroup;\n\s*children = \(\n)"
        match = re.search(group_pattern, content)
        if match:
            content = content[:match.end()] + ref_str + content[match.end():]
        else:
            print(f"Warning: Group {gid} not found for {fn}")

# 4. Add to Main App PBXSourcesBuildPhase
main_sources_pattern = r"(74ABC75A308D036400E22417 /\* Sources \*/ = \{\n\s*isa = PBXSourcesBuildPhase;\n\s*buildActionMask = 2147483647;\n\s*files = \(\n)"
sources_entries = ""
for bf_id, fr_id, fn, gid in new_files:
    entry = f"\t\t\t\t{bf_id} /* {fn} in Sources */,\n"
    if entry not in content:
        sources_entries += entry

match = re.search(main_sources_pattern, content)
if match:
    content = content[:match.end()] + sources_entries + content[match.end():]
else:
    print("Warning: Main sources phase not found")

with open(PBX_PATH, "w", encoding="utf-8") as f:
    f.write(content)

print("Successfully registered API update files in project.pbxproj")

