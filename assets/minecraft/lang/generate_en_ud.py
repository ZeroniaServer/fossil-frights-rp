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
    leading_spaces = 0
    for i, c in enumerate(string):
        if (c == " "):
            leading_spaces += 1
        else:
            break
    string = string[leading_spaces:]

    components = [""]

    formatting_codes_present = False
    color = None
    obfuscated = False
    bold = False
    strikethrough = False
    underlined = False
    italic = False

    i = 0
    while i < len(string):
        c = string[i]

        if c == "%":
            if string[i+1] == "%":
                components.insert(0,"%%")
                i += 1
            elif (string[i+1] == "s"):
                components.insert(0,"%s")
                i += 1
            elif (string[i+1] in "0123456789") and (string[i+2] == "$") and (string[i+3] == "s"):
                components.insert(0,string[i:i+4])
                i += 3
            elif (string[i+1] in "0123456789") and (string[i+2] in "0123456789") and (string[i+3] == "$") and (string[i+4] == "s"):
                components.insert(0,string[i:i+5])
                i += 4
            else:
                raise Exception(f"Error while handling % character in {string}")

        elif c == "§":
            if not formatting_codes_present:
                components.append("§r")
                formatting_codes_present = True

            components.insert(0,"§r")
            if color != None:
                components[0] += "§"+color
            if obfuscated:
                components[0] += "§k"
            if bold:
                components[0] += "§l"
            if strikethrough:
                components[0] += "§m"
            if underlined:
                components[0] += "§n"
            if italic:
                components[0] += "§o"

            code = ord(string[i+1]) - ord("0")

            if (0 <= code <= 9) or (49 <= code <= 54):
                color = c
                obfuscated = False
                bold = False
                strikethrough = False
                underlined = False
                italic = False
            elif code == 59:
                obfuscated = True
            elif code == 60:
                bold = True
            elif code == 61:
                strikethrough = True
            elif code == 62:
                underlined = True
            elif code == 63:
                italic = True
            elif code == 66:
                color = None
                obfuscated = False
                bold = False
                strikethrough = False
                underlined = False
                italic = False

            i+=1
            
        else:
            if (c not in CHAR_MAP.keys()):
                print(f"Ignored character  {c}  in {translation_key}  {string}")
            components.insert(0, CHAR_MAP.get(c, c) )
        
        i += 1

    if formatting_codes_present:
        components.insert(0,"")
        if color != None:
            components[0] += "§"+color
        if obfuscated:
            components[0] += "§k"
        if bold:
            components[0] += "§l"
        if strikethrough:
            components[0] += "§m"
        if underlined:
            components[0] += "§n"
        if italic:
            components[0] += "§o"

    return " "*leading_spaces + "".join(components)

with open(f"en_us.json","r",encoding="utf-8") as file:
    contents = json.load(file)

for key, value in contents.items():
    contents[key] = make_upside_down(value, key)

with open(f"en_ud.json","w",encoding="utf-8") as file:
    json.dump(contents,file,indent="  ",ensure_ascii=False)
    file.write("\n")
