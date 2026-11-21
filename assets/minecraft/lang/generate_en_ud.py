import os
import json

CHAR_MAP = {
    " ": " ",
    "\n": "\n",
    ",": "'",
    '"': ",,",
    "'": ",",
    ".": "˙",
    "?": "¿",
    "!": "¡",
    ":": ":",
    ";": "⸵",
    "+": "+",
    "-": "-",
    "–": "–",
    "=": "=",
    "/": "/",
    "\\": "\\",
    "(": ")",
    ")": "(",
    "[": "]",
    "]": "[",
    "{": "}",
    "}": "{",
    "<": ">",
    ">": "<",
    "§": "§",
    "$": "$",
    "&": "⅋",
    "@": "@",
    "|": "|",
    "#": "#",
    "●": "●",
    "_": "¯",
    "°": "⚬",
    "…": "˙˙˙",
    "≈": "≈",
    "~": "~",
    "↓": "↑",
    "↑": "↓",
    "₂": "ᘔ",
    "*": "⁎",
    "”": ",,",
    "“": ",,",
    "^": "v",
    "→": "→",
    "™": "W⟘ ",
    "⭐": "⭐",

    "0": "0",
    "1": "⥝",
    "2": "ᘔ",
    "3": "Ɛ",
    "4": "߈",
    "5": "ϛ",
    "6": "9",
    "7": "ㄥ",
    "8": "8",
    "9": "6",

    "A": "Ɐ",
    "B": "ᗺ",
    "C": "Ɔ",
    "D": "ᗡ",
    "E": "Ǝ",
    "F": "Ⅎ",
    "G": "⅁",
    "H": "H",
    "I": "I",
    "J": "Ր",
    "K": "Ʞ",
    "L": "Ꞁ",
    "M": "W",
    "N": "N",
    "O": "O",
    "P": "Ԁ",
    "Q": "Ꝺ",
    "R": "ᴚ",
    "S": "S",
    "T": "⟘",
    "U": "∩",
    "V": "Ʌ",
    "W": "M",
    "X": "X",
    "Y": "⅄",
    "Z": "Z",

    "a": "ɐ",
    "b": "q",
    "c": "ɔ",
    "d": "p",
    "e": "ǝ",
    "f": "ɟ",
    "g": "ᵷ",
    "h": "ɥ",
    "i": "ᴉ",
    "j": "ɾ",
    "k": "ʞ",
    "l": "ꞁ",
    "m": "ɯ",
    "n": "u",
    "o": "o",
    "p": "d",
    "q": "b",
    "r": "ɹ",
    "s": "s",
    "t": "ʇ",
    "u": "n",
    "v": "ʌ",
    "w": "ʍ",
    "x": "x",
    "y": "ʎ",
    "z": "z",
}

def make_upside_down(string: str, translation_key) -> str:
    result = ""

    leading_spaces = 0
    for i, c in enumerate(string):
        if (c == " "):
            leading_spaces += 1
        else:
            break
    string = string[leading_spaces:]

    i = 0
    while i < len(string):
        c = string[i]

        if c == "%":
            if string[i+1] == "%":
                result = "%%" + result
                i += 1
            elif (string[i+1] == "s"):
                result = "%s" + result
                i += 1
            elif (string[i+1] in "0123456789") and (string[i+2] == "$") and (string[i+3] == "s"):
                result = string[i:i+4] + result
                i += 3
            elif (string[i+1] in "0123456789") and (string[i+2] in "0123456789") and (string[i+3] == "$") and (string[i+4] == "s"):
                result = string[i:i+4] + result
                i += 4
            else:
                raise Exception(f"Error while handling % character in {string}")
        else:
            if (c not in CHAR_MAP.keys()):
                print(f"Ignored character  {c}  in {translation_key}  {string}")
            result = CHAR_MAP.get(c, c) + result
        
        i += 1

    return " "*leading_spaces + result

with open(f"en_us.json","r",encoding="utf-8") as file:
    contents = json.load(file)

for key, value in contents.items():
    contents[key] = make_upside_down(value, key)

with open(f"en_ud.json","w",encoding="utf-8") as file:
    json.dump(contents,file,indent="  ",ensure_ascii=False)
    file.write("\n")
