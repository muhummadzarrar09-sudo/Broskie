#!/usr/bin/env python3
"""Broskie stage-theme generator — pure code, zero samples.

Synthesizes one looping chiptune per campaign stage straight from math:
square-wave bassline, detuned lead arp, sine-drop kick, noise hats/snare.
Run:  python3 tools/make_chiptunes.py
Output: assets/audio/stage{1..4}_*.wav  (44.1kHz 16-bit mono)
"""
import math
import os
import random
import struct
import wave

SR = 44100
random.seed(7)

OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "audio")


def midi(m):
    return 440.0 * 2 ** ((m - 69) / 12)


def square(phase):
    return 1.0 if phase < 0.5 else -1.0


def render(path, bpm, bass_prog, lead_prog, lead_density=1.0, drive=1.0):
    beat = 60.0 / bpm
    bar = beat * 4
    bars = 8
    total = bar * bars
    n = int(total * SR)
    out = [0.0] * n

    # ── Bass: square, 8th notes riding the progression ────────────────────
    step = beat / 2  # 8th note
    per_bar = 8
    pattern = [0, 0, 7, 0, 0, 12, 7, 0]  # semitone offsets, x<0 = rest
    for b in range(bars):
        root = bass_prog[b % len(bass_prog)]
        for i in range(per_bar):
            off = pattern[i % len(pattern)]
            if off is None:
                continue
            f = midi(root + off)
            start = int((b * bar + i * step) * SR)
            dur = int(step * 0.9 * SR)
            for k in range(dur):
                t = k / SR
                env = min(1.0, k / (0.004 * SR)) * (1.0 - 0.4 * (k / max(1, dur)))
                idx = start + k
                if idx < n:
                    out[idx] += square((f * t) % 1.0) * 0.22 * env

    # ── Lead: detuned double-square arp, 16th-ish ─────────────────────────
    lstep = step / 2
    for b in range(bars):
        chord = lead_prog[b % len(lead_prog)]
        for i, off in enumerate(chord):
            if random.random() > lead_density:
                continue
            f = midi(off)
            start = int((b * bar + (i % 8) * lstep * 2) * SR)
            dur = int(lstep * 1.8 * SR)
            for k in range(dur):
                t = k / SR
                env = (1.0 - k / max(1, dur)) ** 1.6
                idx = start + k
                if idx < n:
                    v = square((f * t) % 1.0) + 0.5 * square((f * 1.005 * t) % 1.0)
                    out[idx] += v * 0.085 * env

    # ── Drums: kick on quarters, hat on 8ths, snare on 2 & 4 ─────────────
    for b in range(bars):
        for q in range(4):
            start = int((b * bar + q * beat) * SR)
            dur = int(0.12 * SR)
            for k in range(dur):
                t = k / SR
                f = 120 * math.exp(-t * 22) + 45
                idx = start + k
                if idx < n:
                    out[idx] += math.sin(2 * math.pi * f * t) * 0.42 * math.exp(-t * 18)
        for h in range(8):
            start = int((b * bar + h * step) * SR)
            dur = int(0.03 * SR)
            for k in range(dur):
                idx = start + k
                if idx < n:
                    out[idx] += random.uniform(-1, 1) * 0.05 * math.exp(-k / (dur * 0.35))
        for s in (1, 3):
            start = int((b * bar + s * beat) * SR)
            dur = int(0.09 * SR)
            for k in range(dur):
                idx = start + k
                if idx < n:
                    out[idx] += random.uniform(-1, 1) * 0.14 * math.exp(-(k / SR) * 32)

    # ── Master: soft clip + write ─────────────────────────────────────────
    peak = max(1e-9, max(abs(v) for v in out))
    gain = min(0.95 / peak, drive)
    frames = bytearray()
    for v in out:
        v = math.tanh(v * gain * 1.3)
        frames += struct.pack("<h", int(v * 32767))
    os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(bytes(frames))
    print(f"wrote {path}  ({n / SR:.1f}s, {len(frames) / 1024:.0f} KiB)")


A = 57  # A4 midi reference helper

# Stage 1 — Grey Zone: chill Am bounce
am_bass = [45, 45, 41, 43]  # A2 A2 F2 G2
am_lead = [[69, 72, 76, 72, 77, 76, 72, 69], [65, 69, 72, 69, 77, 74, 72, 69],
           [67, 71, 74, 71, 76, 74, 71, 67], [69, 72, 76, 79, 76, 72, 69, 67]]
render(os.path.join(OUT, "stage1_groove.wav"), 92, am_bass, am_lead, lead_density=0.7)

# Stage 2 — Neon Slums: darker Em, faster, wetter hats
em_bass = [40, 40, 43, 38]
em_lead = [[64, 67, 71, 67, 74, 71, 67, 64], [62, 67, 70, 67, 74, 70, 67, 62],
           [64, 67, 71, 76, 71, 67, 64, 62], [65, 69, 72, 76, 72, 69, 65, 62]]
render(os.path.join(OUT, "stage2_slums.wav"), 112, em_bass, em_lead, lead_density=0.8)

# Stage 3 — Stock Exchange: driving C#m hustle
cm_bass = [37, 37, 41, 42]
cm_lead = [[61, 64, 68, 64, 73, 68, 64, 61], [61, 64, 68, 71, 68, 64, 61, 58],
           [62, 66, 69, 73, 69, 66, 62, 59], [61, 64, 68, 71, 74, 71, 68, 64]]
render(os.path.join(OUT, "stage3_exchange.wav"), 128, cm_bass, cm_lead, lead_density=0.9, drive=1.1)

# Stage 4 — Executive Arena: tense harmonic-minor sprint
hm_bass = [45, 44, 45, 40]
hm_lead = [[69, 72, 76, 80, 76, 72, 69, 68], [69, 72, 76, 81, 76, 72, 68, 64],
           [69, 72, 76, 80, 83, 80, 76, 72], [68, 71, 75, 80, 75, 71, 68, 64]]
render(os.path.join(OUT, "stage4_core.wav"), 140, hm_bass, hm_lead, lead_density=1.0, drive=1.15)

print("done.")
