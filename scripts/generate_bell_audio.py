"""Create the reader's original bell strike; no recordings or packages needed."""

import math
from pathlib import Path
import struct
import wave


def generate():
    rate = 44100
    duration = 6
    # Inharmonic modes and individual decays approximate a struck temple bell.
    modes = [(220, 1.0, 1.8), (594, .48, 1.25), (1181, .22, .85),
             (1782, .12, .55), (2633, .07, .3)]
    samples = []
    for index in range(rate * duration):
        time = index / rate
        attack = 1 - math.exp(-time / .002)
        tail = min(1, (duration - time) / .2)
        value = sum(weight * math.exp(-time / decay) *
                    math.sin(2 * math.pi * frequency * time)
                    for frequency, weight, decay in modes)
        samples.append(value * attack * tail)
    scale = .85 * 32767 / max(abs(value) for value in samples)
    output = Path(__file__).resolve().parents[1] / 'client/assets/audio/temple_bell.wav'
    with wave.open(str(output), 'wb') as audio:
        audio.setparams((1, 2, rate, 0, 'NONE', 'not compressed'))
        audio.writeframes(b''.join(struct.pack('<h', round(value * scale))
                                   for value in samples))
    print(f'Created {output.name}: mono PCM, {rate} Hz, {duration} seconds')


if __name__ == '__main__':
    generate()
