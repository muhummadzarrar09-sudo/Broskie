#!/usr/bin/env python3
"""Broskie static sweep — the zero-SDK sanity net.

Runs in any environment (no Flutter needed) and catches the classics:
  1. unbalanced braces/parens/brackets per Dart file
  2. package:broskie_game and relative imports that don't resolve
  3. UI files using the BROSKIE style kit without importing it
  4. duplicate top-level class/enum/mixin/extension declarations
  5. runtime art paths referenced in code but missing on disk

Run:  python3 tools/static_sweep.py
"""
import os
import re
import sys
from collections import defaultdict

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
LIB = os.path.join(ROOT, "lib")
errors = []

dart_files = []
for base in (os.path.join(ROOT, "lib"), os.path.join(ROOT, "test")):
    for dp, _, fns in os.walk(base):
        for fn in fns:
            if fn.endswith(".dart"):
                dart_files.append(os.path.join(dp, fn))


def strip_comments(text):
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    text = re.sub(r"//[^\n]*", "", text)
    text = re.sub(r"'''(?:[^'\\]|\\.)*?'''", "''", text, flags=re.S)
    text = re.sub(r'"""(?:[^"\\]|\\.)*?"""', '""', text, flags=re.S)
    text = re.sub(r"'(?:[^'\\\n]|\\.)*'", "''", text)
    text = re.sub(r'"(?:[^"\\\n]|\\.)*"', '""', text)
    return text


# ── 1 & 4: brace balance + duplicate declarations ───────────────────────
decls = defaultdict(list)
for f in dart_files:
    rel = os.path.relpath(f, ROOT)
    clean = strip_comments(open(f).read())
    for o, c in (("{", "}"), ("(", ")"), ("[", "]")):
        if clean.count(o) != clean.count(c):
            errors.append(f"{rel}: unbalanced {o}{c}")
    names = set(re.findall(r"(?:^|\n)\s*(?:abstract\s+)?class\s+(\w+)", clean))
    names |= set(re.findall(r"(?:^|\n)\s*enum\s+(\w+)", clean))
    names |= set(re.findall(r"(?:^|\n)\s*mixin\s+(\w+)", clean))
    names |= set(re.findall(r"(?:^|\n)\s*extension\s+(\w+)", clean))
    for n in names:
        decls[n].append(rel)

for name, locs in decls.items():
    if len(locs) > 1:
        errors.append(f"duplicate declaration of {name}: {locs}")

# ── 2: import resolution ────────────────────────────────────────────────
for f in dart_files:
    rel = os.path.relpath(f, ROOT)
    src = open(f).read()
    for imp in re.findall(r"import\s+['\"]([^'\"]+)['\"]", src):
        if imp.startswith("dart:") or (imp.startswith("package:") and not imp.startswith("package:broskie_game/")):
            continue
        if imp.startswith("package:broskie_game/"):
            target = os.path.join(LIB, imp[len("package:broskie_game/"):])
        else:
            target = os.path.normpath(os.path.join(os.path.dirname(f), imp))
        if not os.path.exists(target):
            errors.append(f"{rel}: unresolved import {imp}")

# ── 3: style-kit import law ─────────────────────────────────────────────
KIT = re.compile(r"\b(BroskieColors|broskieHeadline|broskiePanel|broskieOverlayScan"
                 r"|drawBarcode|ScanlinesPainter|PixelHeartPainter|PixelVinylPainter)\b")
for f in dart_files:
    rel = os.path.relpath(f, ROOT)
    if f.endswith("broskie_style.dart"):
        continue
    src = open(f).read()
    if KIT.search(src) and "broskie_style.dart" not in src:
        errors.append(f"{rel}: uses BROSKIE style kit but does not import broskie_style.dart")

# ── 5: art paths referenced in code must exist ──────────────────────────
for f in dart_files:
    rel = os.path.relpath(f, ROOT)
    src = open(f).read()
    for p in set(re.findall(r"runtime/[a-z_0-9]+\.png", src)):
        if not os.path.exists(os.path.join(ROOT, "assets", "images", p)):
            errors.append(f"{rel}: missing art assets/images/{p}")

print(f"swept {len(dart_files)} dart files")
if errors:
    for e in errors:
        print("ERR:", e)
    sys.exit(1)
print("CLEAN — no issues")
