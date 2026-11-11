"""Encodage du texte (numeros de tuiles de la police).

Codes de controle (moteur $68B7) : $00 = fin, $0D = nouvelle ligne, $1F = espace.
Table EN etablie sur les chaines : A-Z = $70-$89, a-z = $8A-$A3 (ponctuation partielle,
a completer avec la police en PNG). Les codes inconnus s'ecrivent {XX}.
Textes : SMS EN -> banque 32 (table de pointeurs en $8000) ; GG JP -> banque 28.
"""

TEXT_BANK = {"sms_en": 32, "gg_jp": 28}

EN = {0x1F: " ", 0x0D: "\\n", 0xA4: "!", 0xA5: ",", 0xA6: ".", 0xA7: "?", 0xA8: "(", 0xA9: ")",
      0xAA: "-", 0xAB: "'", 0xAC: "”", 0xB3: "“", 0xAD: ":"}
for i in range(10):
    EN[0x60 + i] = str(i)
# ponctuation deduite du contexte des phrases (a confirmer avec la police en PNG)
for i in range(26):
    EN[0x70 + i] = chr(ord("A") + i)
    EN[0x8A + i] = chr(ord("a") + i)


def decode(data, ver):
    table = EN if ver == "sms_en" else {0x1F: " ", 0x0D: "\\n"}
    return "".join(table.get(b, "{%02X}" % b) for b in data)


def load_strings(rom, ver, max_strings=512):
    """Liste des chaines de la banque de texte (pour les commentaires des scripts)."""
    b = TEXT_BANK[ver]
    base = b * 0x4000
    if base + 0x4000 > len(rom):
        return []
    bank = rom[base:base + 0x4000]
    w = lambda o: bank[o] | (bank[o + 1] << 8)
    first = w(0)
    if not 0x8000 <= first < 0xC000:
        return []
    out = []
    for i in range(min(max_strings, (first - 0x8000) // 2)):
        p = w(2 * i)
        if not 0x8000 <= p < 0xC000:
            out.append("?")
            continue
        o = p - 0x8000
        e = bank.find(b"\x00", o)
        out.append(decode(bank[o:e if e >= 0 else o + 64][:80], ver))
    return out
