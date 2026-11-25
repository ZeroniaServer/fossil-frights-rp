#!/usr/bin/env python3
"""Run: python3 generate.py <width> <height> <depth>"""
import json
import math
import sys
from pathlib import Path


def case(w, h, d):
    parts = []
    q = math.sqrt(0.5)
    identity = [0, 0, 0, 1]

    # select tile borders
    def edge(index, count, first, last):
        if count == 1:
            return 'both'
        if index == 0:
            return first
        if index == count - 1:
            return last
        return 'middle'

    def plane(cols, rows, center, axis):
        for col in range(cols):
            for row in range(rows):
                x = edge(col, cols, 'left', 'right')
                y = edge(row, rows, 'top', 'bottom')
                u, v = (col - (cols - 1) / 2) / 16, ((rows - 1) / 2 - row) / 16
                # position tiles and cull faces
                if axis == 'xy':
                    pos, rot, face = [u, v, center / 16], identity, 'north' if center < 0 else 'south'
                elif axis == 'zy':
                    pos, rot, face = [center / 16 + 1 / 16, v, u], [0, -q, 0, q], 'south' if center < 0 else 'north'
                else:
                    pos, rot, face = [u, center / 16, -v + 1 / 16], [-q, 0, 0, q], 'south'
                parts.append({
                    'type': 'minecraft:model',
                    'model': f'fossil_frights:display/general/cases/tile_{x}_{y}_{face}',
                    'transformation': {
                        'translation': pos,
                        'left_rotation': rot,
                        'scale': [1 / 16] * 3,
                        'right_rotation': identity,
                    },
                })

    # build case faces
    plane(w, h, -d / 2, 'xy')
    plane(w, h, d / 2, 'xy')
    plane(d, h, -w / 2, 'zy')
    plane(d, h, w / 2, 'zy')
    plane(w, d, h / 2, 'xz')
    # center bottom on origin
    return {'model': {
        'type': 'minecraft:composite',
        'models': parts,
        'transformation': {
            'translation': [0.46875, 0.46875 + h / 32, 0.46875],
            'left_rotation': identity,
            'scale': [1, 1, 1],
            'right_rotation': identity,
        },
    }}


if __name__ == '__main__':
    # read dimensions
    if len(sys.argv) != 4 or any(not s.isdecimal() or int(s) < 1 or int(s) > 48 for s in sys.argv[1:]):
        sys.exit('usage: python3 generate.py <x> <y> <z> (1-48)')
    w, h, d = map(int, sys.argv[1:])
    path = Path(__file__).with_name(f'{w}x{h}x{d}.json')
    try:
        with path.open('x') as file:
            json.dump(case(w, h, d), file, indent=2)
            file.write('\n')
    except FileExistsError:
        sys.exit(f'{path.name} already exists')
    print(f'created {path.name}')
    print(f'/give @s minecraft:glass[minecraft:item_model="fossil_frights:display/general/cases/{path.stem}"]')
