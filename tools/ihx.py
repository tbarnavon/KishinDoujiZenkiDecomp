"""Lecture des fichiers Intel HEX produits par sdldz80 (adresses etendues incluses)."""


def read_ihx(path):
    """Retourne {adresse_lineaire: octet}. Gere les enregistrements 00, 01, 02 et 04."""
    mem = {}
    base = 0
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line.startswith(":"):
                continue
            raw = bytes.fromhex(line[1:])
            n, addr, typ = raw[0], (raw[1] << 8) | raw[2], raw[3]
            data = raw[4:4 + n]
            if (sum(raw) & 0xFF) != 0:
                raise ValueError(f"checksum IHX invalide : {line}")
            if typ == 0:
                for i, b in enumerate(data):
                    a = base + addr + i
                    if a in mem and mem[a] != b:
                        raise ValueError(f"chevauchement IHX a ${a:X}")
                    mem[a] = b
            elif typ == 1:
                break
            elif typ == 2:
                base = ((data[0] << 8) | data[1]) << 4
            elif typ == 4:
                base = ((data[0] << 8) | data[1]) << 16
    return mem
