#!/usr/bin/env python3
"""Broskie signature-SFX generator — pure code, zero samples.

Same doctrine as the chiptunes: every sound is synthesized straight from
math (square/sine oscillators + shaped noise + bitcrush), 44.1kHz 16-bit.

    glitch.wav      Data-Broker identity — bitcrushed barcode stutter
    fanfare_s.wav   Gold-record S rank — rising major fanfare sting
    boss_kill.wav   Executive termination — sub boom + crash + fall

Run:  python3 tools/make_sfx.py
"""
import math
import os
import random
import struct
import wave

SR = 44100
random.seed(404)
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "audio")


def midi(m):
    return 440.0 * 2 ** ((m - 69) / 12)


def square(phase):
    return 1.0 if phase < 0.5 else -1.0


def bitcrush(v, levels=6):
    return round(v * levels) / levels


def write(path, samples):
    peak = max(1e-9, max(abs(v) for v in samples))
    gain = 0.92 / peak
    frames = bytearray()
    for v in samples:
        v = math.tanh(v * gain * 1.2)
        frames += struct.pack("<h", int(v * 32767))
    os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(bytes(frames))
    print(f"wrote {os.path.basename(path)}  ({len(samples) / SR:.2f}s)")


def make_glitch():
    """0.42s — machine choking on corrupted data."""
    dur = 0.42
    n = int(dur * SR)
    out = [0.0] * n
    # bitcrushed square chirps stuttering downward in pitch, every 30-60ms
    t0 = 0.0
    f = 1800.0
    while t0 < dur - 0.06:
        chirp = int(random.uniform(0.018, 0.05) * SR)
        start = int(t0 * SR)
        for k in range(chirp):
            t = k / SR
            idx = start + k
            if idx < n:
                out[idx] += bitcrush(square((f * t) % 1.0)) * 0.5 * (1 - k / chirp)
        f *= random.uniform(0.55, 0.85)  # each chunk sinks lower
        t0 += random.uniform(0.03, 0.06)
    # tearing noise under everything
    for i in range(n):
        t = i / SR
        out[i] += random.uniform(-1, 1) * 0.16 * math.exp(-t * 4.5)
    # hard digital clip at the end — the connection drops
    start = int((dur - 0.05) * SR)
    for k in range(int(0.05 * SR)):
        idx = start + k
        if idx < n:
            out[idx] = bitcrush(out[idx], 3) + (1.0 if k % 2 else -1.0) * 0.4 * (1 - k / (0.05 * SR))
    return out


def make_fanfare_s():
    """1.25s — gold record certification. C major, rising, then a stab."""
    bpm = 132
    beat = 60.0 / bpm
    dur = 1.25
    n = int(dur * SR)
    out = [0.0] * n
    # rising major figure: C5 E5 G5 C6 — 16ths into a held stab
    figure = [(72, 0.0), (76, 0.5), (79, 1.0), (84, 1.5)]  # (midi, beat offset)
    for m, off in figure:
        f = midi(m)
        start = int(off * beat * SR)
        d = int(0.14 * SR)
        for k in range(d):
            t = k / SR
            idx = start + k
            if idx < n:
                v = square((f * t) % 1.0) + 0.5 * square((f * 1.004 * t) % 1.0)
                out[idx] += v * 0.22 * (1 - 0.6 * k / d)
    # the stab: C6+E6+G6 chord with a long shimmer decay
    stab_at = 2.0 * beat
    for m in (84, 88, 91):
        f = midi(m)
        start = int(stab_at * SR)
        d = n - start
        for k in range(d):
            t = k / SR
            idx = start + k
            if idx < n:
                env = math.exp(-t * 3.2) * min(1.0, k / (0.004 * SR))
                shimmer = 1.0 + 0.06 * math.sin(2 * math.pi * 6.5 * t)
                out[idx] += square((f * t) % 1.0) * 0.16 * env * shimmer
    # snare fill under the rise
    for h in range(8):
        start = int(h * beat / 2 * SR)
        d = int(0.035 * SR)
        for k in range(d):
            idx = start + k
            if idx < n:
                out[idx] += random.uniform(-1, 1) * 0.09 * math.exp(-k / (d * 0.4))
    # kick punch on the stab
    start = int(stab_at * SR)
    for k in range(int(0.12 * SR)):
        t = k / SR
        idx = start + k
        if idx < n:
            out[idx] += math.sin(2 * math.pi * (150 * math.exp(-t * 20) + 50) * t) * 0.45 * math.exp(-t * 16)
    return out


def make_boss_kill():
    """1.55s — executive termination: sub boom, debris crash, power-down fall."""
    dur = 1.55
    n = int(dur * SR)
    out = [0.0] * n
    # seismic sine-drop boom
    for i in range(int(0.55 * SR)):
        t = i / SR
        f = 90 * math.exp(-t * 6) + 32
        out[i] += math.sin(2 * math.pi * f * t) * 0.6 * math.exp(-t * 3.5)
    # debris: two noise crashes riding out
    for at, amp, decay in ((0.02, 0.30, 3.2), (0.14, 0.22, 4.5)):
        start = int(at * SR)
        for k in range(int(0.8 * SR)):
            t = k / SR
            idx = start + k
            if idx < n:
                out[idx] += random.uniform(-1, 1) * amp * math.exp(-t * decay)
    # power-down: square sweep falls to silence (the signal dies with them)
    start = int(0.45 * SR)
    d = n - start
    phase = 0.0
    for k in range(d):
        t = k / SR
        f = 660 * math.exp(-t * 2.2) + 40
        phase += f / SR
        idx = start + k
        if idx < n:
            out[idx] += bitcrush(square(phase % 1.0), 5) * 0.28 * math.exp(-t * 1.9)
    return out


write(os.path.join(OUT, "glitch.wav"), make_glitch())
write(os.path.join(OUT, "fanfare_s.wav"), make_fanfare_s())
write(os.path.join(OUT, "boss_kill.wav"), make_boss_kill())
print("done.")
