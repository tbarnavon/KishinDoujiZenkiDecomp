"""Compression RLE planaire du jeu (routines $4667/$467E vers la RAM, $46A1/$46B8 vers la VRAM).

Format d'un bloc :
  octet 0 : N = nombre de flux entrelaces (pas d'ecriture ; 4 pour des tuiles 4 bits)
  puis N flux successifs ; le flux k remplit les octets k, k+N, k+2N... de la sortie.
  Un flux = suite d'octets de controle c :
    c == 0          : fin du flux
    c & 0x80        : copier (c & 0x7F) octets bruts qui suivent
    sinon           : repeter c fois l'octet qui suit
"""


def decompress(data, start=0):
    """Retourne (octets decompresses, longueur compressee lue)."""
    p = start
    n = data[p]
    p += 1
    if not 1 <= n <= 8:
        raise ValueError(f"nombre de flux invalide : {n}")
    streams = []
    for _ in range(n):
        out = bytearray()
        while True:
            c = data[p]
            p += 1
            if c == 0:
                break
            cnt = c & 0x7F
            if c & 0x80:
                out += data[p:p + cnt]
                p += cnt
            else:
                out += bytes([data[p]]) * cnt
                p += 1
        streams.append(out)
    length = max(len(s) for s in streams)
    res = bytearray(length * n)
    for k, s in enumerate(streams):
        for i, b in enumerate(s):
            res[i * n + k] = b
    return bytes(res), p - start


def _compress_stream(s):
    out = bytearray()
    i = 0
    raw = bytearray()

    def flush_raw():
        while raw:
            chunk = raw[:0x7F]
            del raw[:0x7F]
            out.append(0x80 | len(chunk))
            out.extend(chunk)

    while i < len(s):
        j = i
        while j < len(s) and s[j] == s[i] and j - i < 0x7F:
            j += 1
        run = j - i
        if run >= 3 or (run == 2 and not raw):
            flush_raw()
            out += bytes([run, s[i]])
            i = j
        else:
            raw.append(s[i])
            i += 1
            if len(raw) == 0x7F:
                flush_raw()
    flush_raw()
    out.append(0)
    return out


def compress(data, n=4):
    """Compresse `data` (longueur multiple de n) en n flux entrelaces."""
    if len(data) % n:
        raise ValueError("longueur non multiple du nombre de flux")
    out = bytearray([n])
    for k in range(n):
        out += _compress_stream(data[k::n])
    return bytes(out)
