#!/usr/bin/env node
'use strict';

const fs   = require('fs');
const path = require('path');

const SR  = 44100;
const DIR = path.join(__dirname, '..', 'assets', 'sounds');
if (!fs.existsSync(DIR)) fs.mkdirSync(DIR, { recursive: true });

function wav(samples) {
  const data = samples.length * 2;
  const buf  = Buffer.alloc(44 + data);
  buf.write('RIFF', 0);  buf.writeUInt32LE(36 + data, 4);
  buf.write('WAVE', 8);  buf.write('fmt ', 12);
  buf.writeUInt32LE(16, 16); buf.writeUInt16LE(1, 20);
  buf.writeUInt16LE(1, 22);  buf.writeUInt32LE(SR, 24);
  buf.writeUInt32LE(SR * 2, 28); buf.writeUInt16LE(2, 32);
  buf.writeUInt16LE(16, 34); buf.write('data', 36);
  buf.writeUInt32LE(data, 40);
  for (let i = 0; i < samples.length; i++)
    buf.writeInt16LE(Math.round(Math.max(-1, Math.min(1, samples[i])) * 32767), 44 + i * 2);
  return buf;
}

function env(i, n, attack = 500, release = 500) {
  if (i < attack)       return i / attack;
  if (i > n - release)  return (n - i) / release;
  return 1;
}

function sine(freq, dur, amp = 0.5) {
  const n = Math.round(dur * SR), s = new Float32Array(n);
  for (let i = 0; i < n; i++)
    s[i] = amp * env(i, n) * Math.sin(2 * Math.PI * freq * i / SR);
  return s;
}

function tri(freq, dur, amp = 0.5) {
  const n = Math.round(dur * SR), s = new Float32Array(n);
  for (let i = 0; i < n; i++) {
    const ph = (freq * i / SR) % 1;
    s[i] = amp * env(i, n) * (2 * Math.abs(2 * ph - 1) - 1);
  }
  return s;
}

function sqr(freq, dur, amp = 0.5) {
  const n = Math.round(dur * SR), s = new Float32Array(n);
  for (let i = 0; i < n; i++)
    s[i] = amp * env(i, n, 200, 200) * (Math.sin(2 * Math.PI * freq * i / SR) > 0 ? 1 : -1);
  return s;
}

function sil(dur) { return new Float32Array(Math.round(dur * SR)); }

function cat(...arrs) {
  const n = arrs.reduce((s, a) => s + a.length, 0);
  const out = new Float32Array(n);
  let off = 0;
  for (const a of arrs) { out.set(a, off); off += a.length; }
  return out;
}

// Focus alarm: ascending triangle chimes C5→E5→G5 × 3
const fRep = cat(tri(523.25,0.15,0.55), sil(0.01), tri(659.25,0.15,0.55), sil(0.01), tri(783.99,0.28,0.65), sil(0.87));
fs.writeFileSync(path.join(DIR,'focus_alarm.wav'), wav(cat(fRep,fRep,fRep)));
console.log('✓ focus_alarm.wav');

// Break alarm: descending sine chimes A5→F5→D5 × 3
const bRep = cat(sine(880,0.2,0.5), sil(0.05), sine(698.46,0.2,0.5), sil(0.05), sine(587.33,0.32,0.5), sil(0.68));
fs.writeFileSync(path.join(DIR,'break_alarm.wav'), wav(cat(bRep,bRep,bRep)));
console.log('✓ break_alarm.wav');

// Click: short sine
fs.writeFileSync(path.join(DIR,'click.wav'), wav(sine(440,0.055,0.13)));
console.log('✓ click.wav');

// Countdown tick: short square
fs.writeFileSync(path.join(DIR,'tick.wav'), wav(sqr(900,0.04,0.08)));
console.log('✓ tick.wav');

console.log('\n✓ 4 sounds saved to assets/sounds/');
