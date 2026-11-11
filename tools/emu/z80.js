// Coeur Z80 (interpreteur) pour l'emulateur de test sans fenetre (tools/emu/).
// Jeu d'instructions complet (y compris IXh/IXl, DDCB, blocs ED). Timing a l'instruction.
'use strict';

const SZ = new Uint8Array(256), SZP = new Uint8Array(256);
for (let i = 0; i < 256; i++) {
  SZ[i] = (i & 0x80) | (i === 0 ? 0x40 : 0) | (i & 0x28);
  let p = i; p ^= p >> 4; p ^= p >> 2; p ^= p >> 1;
  SZP[i] = SZ[i] | ((p & 1) ? 0 : 0x04);
}
const CYC = [
  4,10,7,6,4,4,7,4,4,11,7,6,4,4,7,4, 8,10,7,6,4,4,7,4,12,11,7,6,4,4,7,4,
  7,10,16,6,4,4,7,4,7,11,16,6,4,4,7,4, 7,10,13,6,11,11,10,4,7,11,13,6,4,4,7,4,
  4,4,4,4,4,4,7,4,4,4,4,4,4,4,7,4, 4,4,4,4,4,4,7,4,4,4,4,4,4,4,7,4,
  4,4,4,4,4,4,7,4,4,4,4,4,4,4,7,4, 7,7,7,7,7,7,4,7,4,4,4,4,4,4,7,4,
  4,4,4,4,4,4,7,4,4,4,4,4,4,4,7,4, 4,4,4,4,4,4,7,4,4,4,4,4,4,4,7,4,
  4,4,4,4,4,4,7,4,4,4,4,4,4,4,7,4, 4,4,4,4,4,4,7,4,4,4,4,4,4,4,7,4,
  5,10,10,10,10,11,7,11,5,10,10,0,10,17,7,11, 5,10,10,11,10,11,7,11,5,4,10,11,10,0,7,11,
  5,10,10,19,10,11,7,11,5,4,10,4,10,0,7,11, 5,10,10,4,10,11,7,11,5,6,10,4,10,0,7,11];

class Z80 {
  constructor(bus) {
    this.bus = bus;   // {read(a), write(a,v), in(p), out(p,v)}
    this.reset();
  }
  reset() {
    this.a = 0xFF; this.f = 0xFF; this.b = this.c = this.d = this.e = this.h = this.l = 0;
    this.a_ = this.f_ = this.b_ = this.c_ = this.d_ = this.e_ = this.h_ = this.l_ = 0;
    this.ix = this.iy = 0xFFFF; this.sp = 0xDFF0; this.pc = 0; this.i = 0; this.r = 0;
    this.iff1 = this.iff2 = 0; this.im = 0; this.halted = false; this.eiDelay = false;
    this.cycles = 0; this.irqLine = false; this.nmiPending = false;
  }
  // --- memoire
  rb(a) { return this.bus.read(a & 0xFFFF); }
  wb(a, v) { this.bus.write(a & 0xFFFF, v & 0xFF); }
  rw(a) { return this.rb(a) | (this.rb(a + 1) << 8); }
  ww(a, v) { this.wb(a, v); this.wb(a + 1, v >> 8); }
  fetch() { const v = this.rb(this.pc); this.pc = (this.pc + 1) & 0xFFFF; return v; }
  fetchw() { const v = this.rw(this.pc); this.pc = (this.pc + 2) & 0xFFFF; return v; }
  push(v) { this.sp = (this.sp - 2) & 0xFFFF; this.ww(this.sp, v); }
  pop() { const v = this.rw(this.sp); this.sp = (this.sp + 2) & 0xFFFF; return v; }
  // --- paires
  get bc() { return (this.b << 8) | this.c; } set bc(v) { this.b = (v >> 8) & 0xFF; this.c = v & 0xFF; }
  get de() { return (this.d << 8) | this.e; } set de(v) { this.d = (v >> 8) & 0xFF; this.e = v & 0xFF; }
  get hl() { return (this.h << 8) | this.l; } set hl(v) { this.h = (v >> 8) & 0xFF; this.l = v & 0xFF; }
  get af() { return (this.a << 8) | this.f; } set af(v) { this.a = (v >> 8) & 0xFF; this.f = v & 0xFF; }
  // registre 16 bits "HL" selon le prefixe (0 = HL, 1 = IX, 2 = IY)
  getHL(x) { return x === 0 ? this.hl : x === 1 ? this.ix : this.iy; }
  setHL(x, v) { v &= 0xFFFF; if (x === 0) this.hl = v; else if (x === 1) this.ix = v; else this.iy = v; }
  getRP(p, x) { switch (p) { case 0: return this.bc; case 1: return this.de; case 2: return this.getHL(x); default: return this.sp; } }
  setRP(p, v, x) { v &= 0xFFFF; switch (p) { case 0: this.bc = v; break; case 1: this.de = v; break; case 2: this.setHL(x, v); break; default: this.sp = v; } }
  getRP2(p, x) { return p === 3 ? this.af : this.getRP(p, x); }
  setRP2(p, v, x) { if (p === 3) this.af = v & 0xFFFF; else this.setRP(p, v, x); }
  // registre 8 bits ; r=6 => (HL)/(IX+d) avec adresse precalculee this.ea
  getR(r, x) {
    switch (r) {
      case 0: return this.b; case 1: return this.c; case 2: return this.d; case 3: return this.e;
      case 4: return x === 0 ? this.h : x === 1 ? this.ix >> 8 : this.iy >> 8;
      case 5: return x === 0 ? this.l : x === 1 ? this.ix & 0xFF : this.iy & 0xFF;
      case 6: return this.rb(this.ea);
      default: return this.a;
    }
  }
  setR(r, v, x) {
    v &= 0xFF;
    switch (r) {
      case 0: this.b = v; break; case 1: this.c = v; break; case 2: this.d = v; break; case 3: this.e = v; break;
      case 4: if (x === 0) this.h = v; else if (x === 1) this.ix = (this.ix & 0xFF) | (v << 8); else this.iy = (this.iy & 0xFF) | (v << 8); break;
      case 5: if (x === 0) this.l = v; else if (x === 1) this.ix = (this.ix & 0xFF00) | v; else this.iy = (this.iy & 0xFF00) | v; break;
      case 6: this.wb(this.ea, v); break;
      default: this.a = v;
    }
  }
  calcEA(x) {   // adresse de (HL) ou (IX+d)
    if (x === 0) this.ea = this.hl;
    else { const d = this.fetch(); this.ea = (this.getHL(x) + ((d ^ 0x80) - 0x80)) & 0xFFFF; }
  }
  cond(y) {
    const f = this.f;
    switch (y) {
      case 0: return !(f & 0x40); case 1: return !!(f & 0x40); case 2: return !(f & 1); case 3: return !!(f & 1);
      case 4: return !(f & 4); case 5: return !!(f & 4); case 6: return !(f & 0x80); default: return !!(f & 0x80);
    }
  }
  // --- ALU
  alu(op, v) {
    const a = this.a; let r;
    switch (op) {
      case 0: case 1: {   // ADD / ADC
        const c = op === 1 ? (this.f & 1) : 0; r = a + v + c;
        this.f = SZ[r & 0xFF] | (r > 0xFF ? 1 : 0) | ((a ^ v ^ r) & 0x10) | (((a ^ ~v) & (a ^ r) & 0x80) ? 4 : 0);
        this.a = r & 0xFF; return;
      }
      case 2: case 3: case 7: {   // SUB / SBC / CP
        const c = op === 3 ? (this.f & 1) : 0; r = a - v - c;
        const f = (SZ[r & 0xFF] & 0xD7) | 2 | (r < 0 ? 1 : 0) | ((a ^ v ^ r) & 0x10) | (((a ^ v) & (a ^ r) & 0x80) ? 4 : 0);
        if (op === 7) { this.f = f | (v & 0x28); return; }
        this.f = f | (r & 0x28); this.a = r & 0xFF; return;
      }
      case 4: this.a = a & v; this.f = SZP[this.a] | 0x10; return;
      case 5: this.a = a ^ v; this.f = SZP[this.a]; return;
      default: this.a = a | v; this.f = SZP[this.a]; return;
    }
  }
  inc8(v) { const r = (v + 1) & 0xFF; this.f = (this.f & 1) | SZ[r] | ((r & 0x0F) === 0 ? 0x10 : 0) | (r === 0x80 ? 4 : 0); return r; }
  dec8(v) { const r = (v - 1) & 0xFF; this.f = (this.f & 1) | SZ[r] | 2 | ((r & 0x0F) === 0x0F ? 0x10 : 0) | (r === 0x7F ? 4 : 0); return r; }
  add16(a, b) {
    const r = a + b;
    this.f = (this.f & 0xC4) | (r > 0xFFFF ? 1 : 0) | (((a ^ b ^ r) >> 8) & 0x10) | ((r >> 8) & 0x28);
    return r & 0xFFFF;
  }
  adc16(b) {
    const a = this.hl, c = this.f & 1, r = a + b + c;
    this.f = ((r >> 8) & 0xA8) | ((r & 0xFFFF) === 0 ? 0x40 : 0) | (r > 0xFFFF ? 1 : 0) | (((a ^ b ^ r) >> 8) & 0x10) |
      (((a ^ ~b) & (a ^ r) & 0x8000) ? 4 : 0);
    this.hl = r & 0xFFFF;
  }
  sbc16(b) {
    const a = this.hl, c = this.f & 1, r = a - b - c;
    this.f = ((r >> 8) & 0xA8) | ((r & 0xFFFF) === 0 ? 0x40 : 0) | (r < 0 ? 1 : 0) | 2 | (((a ^ b ^ r) >> 8) & 0x10) |
      (((a ^ b) & (a ^ r) & 0x8000) ? 4 : 0);
    this.hl = r & 0xFFFF;
  }
  rot(y, v) {   // CB x=0
    let c, r;
    switch (y) {
      case 0: c = v >> 7; r = ((v << 1) | c) & 0xFF; break;            // RLC
      case 1: c = v & 1; r = (v >> 1) | (c << 7); break;                // RRC
      case 2: c = v >> 7; r = ((v << 1) | (this.f & 1)) & 0xFF; break;  // RL
      case 3: c = v & 1; r = (v >> 1) | ((this.f & 1) << 7); break;     // RR
      case 4: c = v >> 7; r = (v << 1) & 0xFF; break;                   // SLA
      case 5: c = v & 1; r = (v >> 1) | (v & 0x80); break;              // SRA
      case 6: c = v >> 7; r = ((v << 1) | 1) & 0xFF; break;             // SLL
      default: c = v & 1; r = v >> 1;                                   // SRL
    }
    this.f = SZP[r] | c; return r;
  }
  // --- interruptions
  interrupt() {
    if (this.nmiPending) {
      this.nmiPending = false; this.halted = false;
      this.iff2 = this.iff1; this.iff1 = 0; this.push(this.pc); this.pc = 0x66; this.cycles += 11; return;
    }
    if (this.irqLine && this.iff1 && !this.eiDelay) {
      this.halted = false; this.iff1 = this.iff2 = 0;
      this.push(this.pc);
      if (this.im === 2) { this.pc = this.rw((this.i << 8) | 0xFF); this.cycles += 19; }
      else { this.pc = 0x38; this.cycles += 13; }
    }
  }
  // execute une instruction, retourne les cycles
  step() {
    const c0 = this.cycles;
    this.interrupt();
    if (this.halted) { this.cycles += 4; this.r = (this.r & 0x80) | ((this.r + 1) & 0x7F); return this.cycles - c0; }
    this.eiDelay = false;
    let op = this.fetch(), x = 0;
    this.r = (this.r & 0x80) | ((this.r + 1) & 0x7F);
    while (op === 0xDD || op === 0xFD) { x = op === 0xDD ? 1 : 2; op = this.fetch(); this.cycles += 4; }
    if (op === 0xCB) { this.execCB(x); return this.cycles - c0; }
    if (op === 0xED) { this.execED(); return this.cycles - c0; }
    this.cycles += CYC[op];
    this.exec(op, x);
    return this.cycles - c0;
  }
  exec(op, x) {
    const X = op >> 6, y = (op >> 3) & 7, z = op & 7, p = y >> 1, q = y & 1;
    if (X === 1) {
      if (op === 0x76) { this.halted = true; return; }
      if (y === 6) { this.calcEA(x); if (x) this.cycles += 8; this.setR(6, this.getR(z, 0), 0); return; }
      if (z === 6) { this.calcEA(x); if (x) this.cycles += 8; this.setR(y, this.getR(6, 0), 0); return; }
      this.setR(y, this.getR(z, x), x); return;
    }
    if (X === 2) {
      if (z === 6) { this.calcEA(x); if (x) this.cycles += 8; }
      this.alu(y, this.getR(z, x)); return;
    }
    if (X === 0) {
      switch (z) {
        case 0:
          switch (y) {
            case 0: return;
            case 1: { let t = this.a; this.a = this.a_; this.a_ = t; t = this.f; this.f = this.f_; this.f_ = t; return; }
            case 2: { const d = this.fetch(); this.b = (this.b - 1) & 0xFF; if (this.b) { this.pc = (this.pc + ((d ^ 0x80) - 0x80)) & 0xFFFF; this.cycles += 5; } return; }
            case 3: { const d = this.fetch(); this.pc = (this.pc + ((d ^ 0x80) - 0x80)) & 0xFFFF; return; }
            default: { const d = this.fetch(); if (this.cond(y - 4)) { this.pc = (this.pc + ((d ^ 0x80) - 0x80)) & 0xFFFF; this.cycles += 5; } return; }
          }
        case 1:
          if (q === 0) this.setRP(p, this.fetchw(), x);
          else this.setHL(x, this.add16(this.getHL(x), this.getRP(p, x)));
          return;
        case 2:
          switch (y) {
            case 0: this.wb(this.bc, this.a); return;
            case 1: this.a = this.rb(this.bc); return;
            case 2: this.wb(this.de, this.a); return;
            case 3: this.a = this.rb(this.de); return;
            case 4: this.ww(this.fetchw(), this.getHL(x)); return;
            case 5: this.setHL(x, this.rw(this.fetchw())); return;
            case 6: this.wb(this.fetchw(), this.a); return;
            default: this.a = this.rb(this.fetchw()); return;
          }
        case 3: this.setRP(p, this.getRP(p, x) + (q ? -1 : 1), x); return;
        case 4: case 5:
          if (y === 6) { this.calcEA(x); if (x) this.cycles += 8; }
          this.setR(y, z === 4 ? this.inc8(this.getR(y, x)) : this.dec8(this.getR(y, x)), x); return;
        case 6:
          if (y === 6) { this.calcEA(x); if (x) this.cycles += 5; }
          this.setR(y, this.fetch(), x); return;
        default:
          switch (y) {
            case 0: { const c = this.a >> 7; this.a = ((this.a << 1) | c) & 0xFF; this.f = (this.f & 0xC4) | c | (this.a & 0x28); return; }
            case 1: { const c = this.a & 1; this.a = (this.a >> 1) | (c << 7); this.f = (this.f & 0xC4) | c | (this.a & 0x28); return; }
            case 2: { const c = this.a >> 7; this.a = ((this.a << 1) | (this.f & 1)) & 0xFF; this.f = (this.f & 0xC4) | c | (this.a & 0x28); return; }
            case 3: { const c = this.a & 1; this.a = (this.a >> 1) | ((this.f & 1) << 7); this.f = (this.f & 0xC4) | c | (this.a & 0x28); return; }
            case 4: {   // DAA
              let a = this.a, corr = 0, c = this.f & 1;
              if ((this.f & 0x10) || (a & 0x0F) > 9) corr = 6;
              if (c || a > 0x99) { corr |= 0x60; c = 1; }
              const n = this.f & 2;
              const r = n ? (a - corr) & 0xFF : (a + corr) & 0xFF;
              const h = n ? ((this.f & 0x10) && (a & 0x0F) < 6 ? 0x10 : 0) : ((a & 0x0F) > 9 ? 0x10 : 0);
              this.a = r; this.f = SZP[r] | c | n | h; return;
            }
            case 5: this.a ^= 0xFF; this.f = (this.f & 0xC5) | 0x12 | (this.a & 0x28); return;
            case 6: this.f = (this.f & 0xC4) | 1 | (this.a & 0x28); return;
            default: this.f = ((this.f & 0xC5) | ((this.f & 1) << 4) | (this.a & 0x28)) ^ 1; return;
          }
      }
    }
    // X === 3
    switch (z) {
      case 0: if (this.cond(y)) { this.pc = this.pop(); this.cycles += 6; } return;
      case 1:
        if (q === 0) { this.setRP2(p, this.pop(), x); return; }
        switch (p) {
          case 0: this.pc = this.pop(); return;
          case 1: {   // EXX
            let t;
            t = this.b; this.b = this.b_; this.b_ = t; t = this.c; this.c = this.c_; this.c_ = t;
            t = this.d; this.d = this.d_; this.d_ = t; t = this.e; this.e = this.e_; this.e_ = t;
            t = this.h; this.h = this.h_; this.h_ = t; t = this.l; this.l = this.l_; this.l_ = t; return;
          }
          case 2: this.pc = this.getHL(x); return;
          default: this.sp = this.getHL(x); return;
        }
      case 2: { const a = this.fetchw(); if (this.cond(y)) this.pc = a; return; }
      case 3:
        switch (y) {
          case 0: this.pc = this.fetchw(); return;
          case 2: this.bus.out(this.fetch(), this.a); return;
          case 3: this.a = this.bus.in(this.fetch()) & 0xFF; return;
          case 4: { const t = this.rw(this.sp); this.ww(this.sp, this.getHL(x)); this.setHL(x, t); return; }
          case 5: { const t = this.de; this.de = this.hl; this.hl = t; return; }
          case 6: this.iff1 = this.iff2 = 0; return;
          case 7: this.iff1 = this.iff2 = 1; this.eiDelay = true; return;
          default: return;
        }
      case 4: { const a = this.fetchw(); if (this.cond(y)) { this.push(this.pc); this.pc = a; this.cycles += 7; } return; }
      case 5:
        if (q === 0) { this.push(this.getRP2(p, x)); return; }
        if (p === 0) { const a = this.fetchw(); this.push(this.pc); this.pc = a; }
        return;
      case 6: this.alu(y, this.fetch()); return;
      default: this.push(this.pc); this.pc = y * 8; return;
    }
  }
  execCB(x) {
    let r, op;
    if (x) { this.calcEA(x); op = this.fetch(); this.cycles += 19; r = 6; }
    else { op = this.fetch(); r = op & 7; if (r === 6) this.ea = this.hl; this.cycles += r === 6 ? 15 : 8; }
    this.r = (this.r & 0x80) | ((this.r + 1) & 0x7F);
    const X = op >> 6, y = (op >> 3) & 7, z = op & 7;
    const v = this.getR(r, 0);
    let res;
    if (X === 0) res = this.rot(y, v);
    else if (X === 1) {
      const b = v & (1 << y);
      this.f = (this.f & 1) | 0x10 | (b ? (b & 0x80) : 0x44) | (v & 0x28);
      if (r === 6) this.cycles -= 3;
      return;
    } else if (X === 2) res = v & ~(1 << y);
    else res = v | (1 << y);
    this.setR(r, res, 0);
    if (x && z !== 6) this.setR(z, res, 0);   // non documente : copie dans le registre
  }
  execED() {
    const op = this.fetch();
    this.r = (this.r & 0x80) | ((this.r + 1) & 0x7F);
    const X = op >> 6, y = (op >> 3) & 7, z = op & 7, p = y >> 1, q = y & 1;
    if (X === 1) {
      switch (z) {
        case 0: { const v = this.bus.in(this.c) & 0xFF; if (y !== 6) this.setR(y, v, 0); this.f = (this.f & 1) | SZP[v]; this.cycles += 12; return; }
        case 1: this.bus.out(this.c, y === 6 ? 0 : this.getR(y, 0)); this.cycles += 12; return;
        case 2: if (q === 0) this.sbc16(this.getRP(p, 0)); else this.adc16(this.getRP(p, 0)); this.cycles += 15; return;
        case 3: { const a = this.fetchw(); if (q === 0) this.ww(a, this.getRP(p, 0)); else this.setRP(p, this.rw(a), 0); this.cycles += 20; return; }
        case 4: { const v = this.a; this.a = 0; this.alu(2, v); this.cycles += 8; return; }
        case 5: this.iff1 = this.iff2; this.pc = this.pop(); this.cycles += 14; return;
        case 6: this.im = [0, 0, 1, 2, 0, 0, 1, 2][y]; this.cycles += 8; return;
        default:
          switch (y) {
            case 0: this.i = this.a; this.cycles += 9; return;
            case 1: this.r = this.a; this.cycles += 9; return;
            case 2: this.a = this.i; this.f = (this.f & 1) | SZ[this.a] | (this.iff2 ? 4 : 0); this.cycles += 9; return;
            case 3: this.a = this.r; this.f = (this.f & 1) | SZ[this.a] | (this.iff2 ? 4 : 0); this.cycles += 9; return;
            case 4: { const m = this.rb(this.hl); this.wb(this.hl, ((m >> 4) | (this.a << 4)) & 0xFF); this.a = (this.a & 0xF0) | (m & 0x0F); this.f = (this.f & 1) | SZP[this.a]; this.cycles += 18; return; }
            case 5: { const m = this.rb(this.hl); this.wb(this.hl, ((m << 4) | (this.a & 0x0F)) & 0xFF); this.a = (this.a & 0xF0) | (m >> 4); this.f = (this.f & 1) | SZP[this.a]; this.cycles += 18; return; }
            default: this.cycles += 8; return;
          }
      }
    }
    if (X === 2 && z <= 3 && y >= 4) {
      const inc = (y & 1) ? -1 : 1, rep = y >= 6;
      switch (z) {
        case 0: {   // LDI/LDD
          const v = this.rb(this.hl); this.wb(this.de, v);
          this.hl = (this.hl + inc) & 0xFFFF; this.de = (this.de + inc) & 0xFFFF; this.bc = (this.bc - 1) & 0xFFFF;
          const n = (v + this.a) & 0xFF;
          this.f = (this.f & 0xC1) | (this.bc ? 4 : 0) | (n & 8) | ((n & 2) << 4);
          if (rep && this.bc) { this.pc = (this.pc - 2) & 0xFFFF; this.cycles += 21; } else this.cycles += 16;
          return;
        }
        case 1: {   // CPI/CPD
          const v = this.rb(this.hl), r = (this.a - v) & 0xFF;
          this.hl = (this.hl + inc) & 0xFFFF; this.bc = (this.bc - 1) & 0xFFFF;
          this.f = (this.f & 1) | (SZ[r] & 0xC0) | 2 | ((this.a ^ v ^ r) & 0x10) | (this.bc ? 4 : 0);
          if (rep && this.bc && r !== 0) { this.pc = (this.pc - 2) & 0xFFFF; this.cycles += 21; } else this.cycles += 16;
          return;
        }
        case 2: {   // INI/IND
          const v = this.bus.in(this.c) & 0xFF; this.wb(this.hl, v);
          this.hl = (this.hl + inc) & 0xFFFF; this.b = (this.b - 1) & 0xFF;
          this.f = SZ[this.b] | 2 | (this.f & 1);
          if (rep && this.b) { this.pc = (this.pc - 2) & 0xFFFF; this.cycles += 21; } else this.cycles += 16;
          return;
        }
        default: {  // OUTI/OUTD
          const v = this.rb(this.hl); this.b = (this.b - 1) & 0xFF; this.bus.out(this.c, v);
          this.hl = (this.hl + inc) & 0xFFFF;
          this.f = SZ[this.b] | 2 | (this.f & 1);
          if (rep && this.b) { this.pc = (this.pc - 2) & 0xFFFF; this.cycles += 21; } else this.cycles += 16;
          return;
        }
      }
    }
    this.cycles += 8;   // NOP ED
  }
}

module.exports = { Z80 };
