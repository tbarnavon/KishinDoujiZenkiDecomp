// Emulateur Master System sans fenetre, pour tester le projet sans interface graphique.
// Z80 (z80.js) + mapper Sega + VDP mode 4 (rendu ligne par ligne, effets raster) + manette.
// Le son (PSG) est ignore.
//
// Usage : node tools/emu/sms.js <rom.sms> <script.txt> [dossier_sortie]
// Script (une commande par ligne, '#' = commentaire) :
//   run N                 avance de N trames sans toucher la manette
//   hold TOUCHES N        maintient des touches N trames (UP,DOWN,LEFT,RIGHT,B1,B2 separees par ',')
//   pause                 appuie sur Pause (NMI), equivalent du Start GG
//   shot NOM              ecrit NOM.png (256x192, ecran complet)
//   save NOM / load NOM   etat de la machine (NOM.state)
//   peek ADR [N]          affiche N octets de memoire a l'adresse (hex)
//   poke ADR V1 V2...     ecrit des octets en RAM (hex)
//   check on|gg|off       verifie le decor a chaque trame : ecran SMS (on, ROM WIDE=1) ou
//                         fenetre GG seule (gg, toute ROM) ; bilan a off
//   checkbg               verifie le decor de la vue elargie (WIDE=1) sur la trame courante
//   prof LO HI BANQUE     mesure les cycles passes dans [LO,HI) ; 'prof off' affiche le bilan
//   audit on|off          ecritures VRAM trop rapides (< 26 cycles) ou hors tilemap (bilan a off)
//   ramuse on|off         liste les plages de RAM jamais ecrites entre on et off
//   trace ADR [NOM]       signale chaque passage du PC en ADR (trame, ligne)
//   regs                  affiche les registres VDP et le mapper
'use strict';
const fs = require('fs');
const path = require('path');
const zlib = require('zlib');
const { Z80 } = require('./z80');

const LINES = 262, CYCLES_PER_LINE = 228;
const KEYS = { UP: 1, DOWN: 2, LEFT: 4, RIGHT: 8, B1: 16, B2: 32 };

class SMS {
  constructor(rom) {
    this.rom = rom;
    this.nbanks = Math.max(1, rom.length >> 14);
    this.ram = new Uint8Array(0x2000);
    this.vram = new Uint8Array(0x4000);
    this.cram = new Uint8Array(32);
    this.reg = new Uint8Array(16);
    this.mapper = [0, 0, 1, 2];   // FFFC, FFFD, FFFE, FFFF
    this.latch = 0; this.latchFull = false; this.code = 0; this.addr = 0; this.buffer = 0;
    this.status = 0; this.linePending = false; this.lineCounter = 0xFF; this.line = 0;
    this.vscrollLatch = 0;
    this.keys = 0;
    this.frame = new Uint8Array(256 * 192 * 3);
    this.frameCount = 0;
    const self = this;
    this.cpu = new Z80({
      read: a => self.read(a), write: (a, v) => self.write(a, v),
      in: p => self.portIn(p & 0xFF), out: (p, v) => self.portOut(p & 0xFF, v),
    });
  }
  // --- memoire
  read(a) {
    if (a < 0x0400) return this.rom[a];
    if (a < 0x4000) return this.rom[(this.mapper[1] % this.nbanks) * 0x4000 + a];
    if (a < 0x8000) return this.rom[(this.mapper[2] % this.nbanks) * 0x4000 + (a - 0x4000)];
    if (a < 0xC000) return this.rom[(this.mapper[3] % this.nbanks) * 0x4000 + (a - 0x8000)];
    return this.ram[a & 0x1FFF];
  }
  write(a, v) {
    if (a < 0xC000) return;
    if (this.ramTouched) this.ramTouched[a & 0x1FFF] = 1;
    this.ram[a & 0x1FFF] = v;
    if (a >= 0xFFFC) this.mapper[a - 0xFFFC] = v;
  }
  // --- ports
  portIn(p) {
    if (p < 0x40) return 0xFF;
    if (p < 0x80) {
      if (p & 1) return 0x80;   // compteur H (approximatif)
      const l = this.line; return l <= 0xDA ? l : l - 6;
    }
    if (p < 0xC0) {
      this.latchFull = false;
      if (p & 1) {
        const s = this.status | 0x1F; this.status = 0; this.linePending = false; this.updateIrq(); return s;
      }
      const v = this.buffer; this.buffer = this.vram[this.addr]; this.addr = (this.addr + 1) & 0x3FFF; return v;
    }
    if (p & 1) return 0xFF;
    return (~this.keys) & 0xFF;
  }
  portOut(p, v) {
    if (p < 0x80 || p >= 0xC0) return;
    if (p & 1) {
      if (!this.latchFull) { this.latch = v; this.latchFull = true; this.addr = (this.addr & 0x3F00) | v; return; }
      this.latchFull = false;
      this.code = v >> 6; this.addr = ((v & 0x3F) << 8) | this.latch;
      if (this.code === 0) { this.buffer = this.vram[this.addr]; this.addr = (this.addr + 1) & 0x3FFF; }
      else if (this.code === 2) { this.reg[v & 0x0F] = this.latch; this.updateIrq(); }
      return;
    }
    this.latchFull = false;
    if (this.audit) this.auditWrite();
    if (this.code === 3) this.cram[this.addr & 0x1F] = v & 0x3F;
    else this.vram[this.addr] = v;
    this.buffer = v;
    this.addr = (this.addr + 1) & 0x3FFF;
  }
  // audit des ecritures VRAM : intervalle < 26 cycles pendant l'affichage actif, et
  // ecritures du code de la vue elargie (banque 10, $BCBA-$BFFF) hors du tilemap $3800-$3EFF
  auditWrite() {
    const A = this.audit, c = this.cpu.cycles, pc = (this.cpu.pc - 1) & 0xFFFF;
    const key = pc.toString(16) + (pc >= 0x8000 ? '/b' + this.mapper[3] : '');
    if (this.line < 192 && (this.reg[1] & 0x40) && c - A.last < 26) A.fast.set(key, (A.fast.get(key) || 0) + 1);
    A.last = c;
    if (this.code !== 3 && pc >= 0xBCBA && this.mapper[3] === 10 && (this.addr < 0x3800 || this.addr >= 0x3F00))
      A.outside.set(key + '@' + this.addr.toString(16), (A.outside.get(key + '@' + this.addr.toString(16)) || 0) + 1);
  }
  updateIrq() {
    this.cpu.irqLine = !!(((this.status & 0x80) && (this.reg[1] & 0x20)) || (this.linePending && (this.reg[0] & 0x10)));
  }
  // --- rendu d'une ligne
  renderLine(ln) {
    const out = this.frame, base = ln * 256 * 3, r = this.reg, vram = this.vram;
    const pix = new Int16Array(256);   // index couleur (0-31) ; +64 = priorite fond opaque
    if (!(r[1] & 0x40)) { this.blit(base, null, 16 + (r[7] & 15)); return; }
    const nt = (r[2] & 0x0E) << 10;
    let hs = r[8]; if ((r[0] & 0x40) && ln < 16) hs = 0;
    for (let x = 0; x < 256; x++) {
      const vs = ((r[0] & 0x80) && x >= 192) ? 0 : this.vscrollLatch;
      const row = (ln + vs) % 224, tx = ((x - hs) & 255);
      const e = nt + (((row >> 3) * 32 + (tx >> 3)) << 1);
      const ent = vram[e] | (vram[e + 1] << 8);
      const tile = ent & 0x1FF, fy = (ent & 0x400) ? 7 - (row & 7) : (row & 7);
      const bit = (ent & 0x200) ? (tx & 7) : 7 - (tx & 7);
      const pa = (tile * 32 + fy * 4) & 0x3FFF;
      const c = ((vram[pa] >> bit) & 1) | (((vram[pa + 1] >> bit) & 1) << 1) |
        (((vram[pa + 2] >> bit) & 1) << 2) | (((vram[pa + 3] >> bit) & 1) << 3);
      pix[x] = ((ent & 0x800) ? 16 : 0) + c + ((ent & 0x1000) && c ? 64 : 0);
    }
    // sprites
    const sat = (r[5] & 0x7E) << 7, h = (r[1] & 2) ? 16 : 8, sp = new Uint8Array(256);
    let n = 0;
    for (let i = 0; i < 64; i++) {
      let y = vram[sat + i];
      if (y === 0xD0) break;
      if (y > 0xD0) y -= 256;
      const dy = ln - y - 1;
      if (dy < 0 || dy >= h) continue;
      if (++n > 8) { this.status |= 0x40; break; }
      let sx = vram[sat + 0x80 + i * 2], t = vram[sat + 0x81 + i * 2];
      if (r[0] & 8) sx -= 8;
      if (h === 16) t &= 0xFE;
      if (r[6] & 4) t |= 0x100;
      const pa = t * 32 + dy * 4;
      for (let b = 0; b < 8; b++) {
        const x = sx + b; if (x < 0 || x > 255) continue;
        const bit = 7 - b;
        const c = ((vram[pa] >> bit) & 1) | (((vram[pa + 1] >> bit) & 1) << 1) |
          (((vram[pa + 2] >> bit) & 1) << 2) | (((vram[pa + 3] >> bit) & 1) << 3);
        if (!c) continue;
        if (sp[x]) { this.status |= 0x20; continue; }
        sp[x] = 1;
        if (!(pix[x] & 64)) pix[x] = 16 + c;
      }
    }
    if (r[0] & 0x20) for (let x = 0; x < 8; x++) pix[x] = 16 + (r[7] & 15);
    this.blit(base, pix, 0);
  }
  blit(base, pix, fill) {
    for (let x = 0; x < 256; x++) {
      const v = this.cram[pix ? pix[x] & 31 : fill];
      const o = base + x * 3;
      this.frame[o] = (v & 3) * 85; this.frame[o + 1] = ((v >> 2) & 3) * 85; this.frame[o + 2] = ((v >> 4) & 3) * 85;
    }
  }
  // --- une trame
  runFrame() {
    const cpu = this.cpu;
    for (let ln = 0; ln < LINES; ln++) {
      this.line = ln;
      if (ln === 0) this.vscrollLatch = this.reg[9];
      if (ln < 192) this.renderLine(ln);
      if (ln <= 192) {
        if (this.lineCounter === 0) { this.lineCounter = this.reg[10]; this.linePending = true; }
        else this.lineCounter = (this.lineCounter - 1) & 0xFF;
      } else this.lineCounter = this.reg[10];
      if (ln === 193) this.status |= 0x80;
      this.updateIrq();
      const end = cpu.cycles + CYCLES_PER_LINE;
      if (this.prof) {
        const P = this.prof;
        while (cpu.cycles < end) {
          const pc = cpu.pc, c = cpu.step();
          if (pc >= P.lo && pc < P.hi && (pc < 0x8000 || this.mapper[3] === P.bank)) P.cur += c;
        }
      } else if (this.traces) {
        while (cpu.cycles < end) {
          const t = this.traces.get(cpu.pc);
          if (t !== undefined && !cpu.halted) console.log(`  trace ${t} : trame ${this.frameCount} ligne ${ln} cycles ${cpu.cycles} pile ${cpu.rw(cpu.sp).toString(16)},${cpu.rw(cpu.sp + 2).toString(16)},${cpu.rw(cpu.sp + 4).toString(16)} slot2 ${this.mapper[3]}`);
          cpu.step();
        }
      } else while (cpu.cycles < end) cpu.step();
    }
    this.frameCount++;
    if (this.prof) { const P = this.prof; P.tot += P.cur; P.n++; if (P.cur > P.max) P.max = P.cur; if (P.cur > 0) { P.nz++; P.list.push(P.cur); } P.cur = 0; }
  }
  // --- etat
  saveState() {
    const c = this.cpu, regs = {};
    for (const k of ['a', 'f', 'b', 'c', 'd', 'e', 'h', 'l', 'a_', 'f_', 'b_', 'c_', 'd_', 'e_', 'h_', 'l_',
      'ix', 'iy', 'sp', 'pc', 'i', 'r', 'iff1', 'iff2', 'im', 'halted', 'eiDelay', 'cycles', 'irqLine']) regs[k] = c[k];
    const b64 = a => Buffer.from(a).toString('base64');
    return JSON.stringify({
      regs, ram: b64(this.ram), vram: b64(this.vram), cram: b64(this.cram), reg: b64(this.reg),
      mapper: this.mapper, vdp: [this.latch, this.latchFull, this.code, this.addr, this.buffer, this.status,
        this.linePending, this.lineCounter], frameCount: this.frameCount,
    });
  }
  loadState(s) {
    const o = JSON.parse(s), u = x => new Uint8Array(Buffer.from(x, 'base64'));
    Object.assign(this.cpu, o.regs);
    this.ram = u(o.ram); this.vram = u(o.vram); this.cram = u(o.cram); this.reg = u(o.reg);
    this.mapper = o.mapper;
    [this.latch, this.latchFull, this.code, this.addr, this.buffer, this.status, this.linePending, this.lineCounter] = o.vdp;
    this.frameCount = o.frameCount;
  }
}

// --- PNG
const CRC = new Int32Array(256);
for (let n = 0; n < 256; n++) { let c = n; for (let k = 0; k < 8; k++) c = c & 1 ? 0xEDB88320 ^ (c >>> 1) : c >>> 1; CRC[n] = c; }
function crc32(buf) { let c = -1; for (const b of buf) c = CRC[(c ^ b) & 0xFF] ^ (c >>> 8); return (c ^ -1) >>> 0; }
function chunk(type, data) {
  const len = Buffer.alloc(4); len.writeUInt32BE(data.length);
  const td = Buffer.concat([Buffer.from(type), data]);
  const crc = Buffer.alloc(4); crc.writeUInt32BE(crc32(td));
  return Buffer.concat([len, td, crc]);
}
function writePNG(file, rgb, w, h, scale = 2) {
  const W = w * scale, H = h * scale, raw = Buffer.alloc((W * 3 + 1) * H);
  for (let y = 0; y < H; y++) {
    raw[y * (W * 3 + 1)] = 0;
    for (let x = 0; x < W; x++) {
      const s = ((y / scale | 0) * w + (x / scale | 0)) * 3, d = y * (W * 3 + 1) + 1 + x * 3;
      raw[d] = rgb[s]; raw[d + 1] = rgb[s + 1]; raw[d + 2] = rgb[s + 2];
    }
  }
  const ihdr = Buffer.alloc(13); ihdr.writeUInt32BE(W, 0); ihdr.writeUInt32BE(H, 4); ihdr[8] = 8; ihdr[9] = 2;
  fs.writeFileSync(file, Buffer.concat([Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]), chunk('IHDR', ihdr),
    chunk('IDAT', zlib.deflateSync(raw)), chunk('IEND', Buffer.alloc(0))]));
}

// Verification de la vue elargie (WIDE=1) : chaque tuile visible a l'ecran SMS doit
// correspondre a la carte en RAM (bords repetes hors de la carte). Adresses : src/include/ram.inc.
function checkBackground(sms, ggOnly = false) {
  const rd = a => sms.read(a), rw = a => rd(a) | (rd(a + 1) << 8);
  const s16 = v => (v & 0x8000) ? v - 0x10000 : v;
  const abs224 = v => (v >> 8) * 224 + (v & 0xFF);
  if (rd(0xC013) !== 2 || rd(0xC014) >= 0x80 || !(sms.reg[1] & 0x40)) return { bad: 0, total: 0, first: '', cam: 0, camy: 0 };   // hors du mode jeu ou ecran eteint
  const cam = -s16(rw(0xC0AE)), camy = abs224(rw(0xC09B));
  // defilement en cours de traitement (la RAM est en avance sur le VDP) : rien a verifier
  if ((rd(0xC09B) !== sms.reg[9]) || (rd(0xC1BE) !== rd(0xC0AE))) return { bad: 0, total: 0, first: '', cam, camy };
  const W = rd(0xCF18), H = (abs224(rw(0xC19C)) + 144) >> 4, meta = rw(0xD4C9);
  const clamp = (v, n) => Math.max(0, Math.min(n - 1, v));
  const nt = (sms.reg[2] & 0x0E) << 10;
  let bad = 0, total = 0, first = '';
  const m = ggOnly ? [0, 143, 0, 159] : [-24, 167, -40, 207];   // fenetre GG seule ou ecran SMS
  for (let ty = Math.floor((camy + m[0]) / 8); ty <= Math.floor((camy + m[1]) / 8); ty++) {
    for (let tx = Math.floor((cam + m[2]) / 8); tx <= Math.floor((cam + m[3]) / 8); tx++) {
      const mrow = clamp(Math.floor(ty / 2), H), mcol = clamp(Math.floor(tx / 2), W);
      const idx = sms.ram[(0xCF27 + mrow * W + mcol) & 0x1FFF];
      const pa = 10 * 0x4000 + (meta - 0x8000) + idx * 8 + (((ty % 2) + 2) % 2) * 4 + (((tx % 2) + 2) % 2) * 2;
      const want = sms.rom[pa] | (sms.rom[pa + 1] << 8);
      const row = (((3 + ty) % 28) + 28) % 28, col = (6 + tx) & 31;
      const e = nt + (row * 32 + col) * 2, got = sms.vram[e] | (sms.vram[e + 1] << 8);
      total++;
      if (got !== want) { if (!bad) first = `(${tx},${ty}) attendu ${want.toString(16)} obtenu ${got.toString(16)}`; bad++; }
    }
  }
  return { bad, total, first, cam, camy };
}

function main() {
  const [romPath, scriptPath, outDir = path.dirname(scriptPath)] = process.argv.slice(2);
  if (!romPath || !scriptPath) { console.error('usage : node sms.js <rom> <script> [sortie]'); process.exit(2); }
  const sms = new SMS(fs.readFileSync(romPath));
  fs.mkdirSync(outDir, { recursive: true });
  const t0 = Date.now();
  let check = false, checkGG = false, checkBad = 0, checkFrames = 0;
  const step = () => {
    sms.runFrame();
    if (!check) return;
    const r = checkBackground(sms, checkGG); if (!r.total) return; checkFrames++;
    if (r.bad) { checkBad++; if (checkBad <= 5) console.log(`  trame ${sms.frameCount} : ${r.bad} tuiles fausses, ${r.first}, cam=${r.cam},${r.camy}`); }
  };
  for (let raw of fs.readFileSync(scriptPath, 'utf8').split(/\r?\n/)) {
    const line = raw.split('#')[0].trim(); if (!line) continue;
    const w = line.split(/\s+/), cmd = w[0];
    if (cmd === 'run') { sms.keys = 0; for (let i = 0; i < +w[1]; i++) step(); }
    else if (cmd === 'hold') {
      sms.keys = w[1].split(',').reduce((m, k) => m | (KEYS[k.toUpperCase()] || 0), 0);
      for (let i = 0; i < +w[2]; i++) step();
      sms.keys = 0;
    } else if (cmd === 'pause') { sms.cpu.nmiPending = true; sms.runFrame(); }
    else if (cmd === 'shot') { writePNG(path.join(outDir, w[1] + '.png'), sms.frame, 256, 192); console.log(`trame ${sms.frameCount} : ${w[1]}.png`); }
    else if (cmd === 'save') fs.writeFileSync(path.join(outDir, w[1] + '.state'), sms.saveState());
    else if (cmd === 'load') sms.loadState(fs.readFileSync(path.join(outDir, w[1] + '.state'), 'utf8'));
    else if (cmd === 'peek') {
      const a = parseInt(w[1], 16), n = +(w[2] || 16), b = [];
      for (let i = 0; i < n; i++) b.push(sms.read((a + i) & 0xFFFF).toString(16).padStart(2, '0'));
      console.log(`$${w[1].toUpperCase()} : ${b.join(' ')}`);
    } else if (cmd === 'poke') {
      const a = parseInt(w[1], 16);
      w.slice(2).forEach((v, i) => sms.write((a + i) & 0xFFFF, parseInt(v, 16)));
    } else if (cmd === 'check') {
      if (w[1] === 'on' || w[1] === 'gg') { check = true; checkGG = w[1] === 'gg'; checkBad = checkFrames = 0; }
      else { check = false; console.log(`check : ${checkBad}/${checkFrames} trames avec des tuiles fausses`); }
    } else if (cmd === 'checkbg') {
      const r = checkBackground(sms);
      console.log(`checkbg trame ${sms.frameCount} : ${r.bad}/${r.total} tuiles fausses` +
        (r.bad ? ` (premiere : monde ${r.first})` : '') + ` cam=${r.cam},${r.camy}`);
    } else if (cmd === 'prof') {   // prof LO HI BANQUE : cycles passes dans [LO,HI) (slot 2 = BANQUE)
      if (w[1] === 'off') { const P = sms.prof; console.log(`prof : ${P.n} trames, ${P.nz} actives, moyenne ${(P.tot / P.n).toFixed(0)} cycles/trame, max ${P.max} (une trame = 59736)`);
        const L = P.list.sort((a, b) => a - b), q = f => L[Math.min(L.length - 1, Math.floor(f * L.length))];
        console.log(`       trames actives : mediane ${q(0.5)}, 90 % ${q(0.9)}, 99 % ${q(0.99)}`); sms.prof = null; }
      else sms.prof = { lo: parseInt(w[1], 16), hi: parseInt(w[2], 16), bank: +w[3], cur: 0, tot: 0, n: 0, nz: 0, max: 0, list: [] };
    } else if (cmd === 'audit') {   // audit on / audit off : ecritures VRAM trop rapides ou hors tilemap
      if (w[1] === 'on') sms.audit = { last: 0, fast: new Map(), outside: new Map() };
      else {
        const A = sms.audit;
        console.log('ecritures trop rapprochees (< 26 cycles, affichage actif) par PC :', [...A.fast].sort((a, b) => b[1] - a[1]).slice(0, 15));
        console.log('ecritures de la vue elargie hors du tilemap :', [...A.outside].slice(0, 15));
        sms.audit = null;
      }
    } else if (cmd === 'ramuse') {   // ramuse on / ramuse off : plages de RAM jamais ecrites
      if (w[1] === 'on') sms.ramTouched = new Uint8Array(0x2000);
      else {
        const t = sms.ramTouched, out = [];
        for (let i = 0; i < 0x2000;) {
          if (t[i]) { i++; continue; }
          let j = i; while (j < 0x2000 && !t[j]) j++;
          if (j - i >= 4) out.push(`$${(0xC000 + i).toString(16)}-$${(0xC000 + j - 1).toString(16)} (${j - i})`);
          i = j;
        }
        console.log('RAM jamais ecrite :', out.join(', '));
      }
    } else if (cmd === 'trace') {   // trace ADR NOM : affiche trame/ligne quand le PC passe par ADR
      if (!sms.traces) sms.traces = new Map();
      sms.traces.set(parseInt(w[1], 16), w[2] || w[1]);
    } else if (cmd === 'regs') {
      console.log('VDP', Array.from(sms.reg.slice(0, 11), v => v.toString(16).padStart(2, '0')).join(' '),
        '| mapper', sms.mapper.join(','), '| pc', sms.cpu.pc.toString(16));
    } else { console.error('commande inconnue : ' + cmd); process.exit(2); }
  }
  console.log(`${sms.frameCount} trames en ${((Date.now() - t0) / 1000).toFixed(1)} s`);
}

if (require.main === module) main();
module.exports = { SMS, writePNG };
