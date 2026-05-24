'use strict';

const { contextBridge, ipcRenderer } = require('electron');

// ── Allowlist of valid IPC channels ──────────────────────────────────────────
const SEND_CHANNELS   = new Set(['timer-state-update', 'session-alarm', 'window-flash', 'update-config']);
const INVOKE_CHANNELS = new Set(['get-platform', 'show-confirm-dialog']);
const RECV_CHANNELS   = new Set(['shortcut']);

// ── Input sanitizer ───────────────────────────────────────────────────────────
function sanitize(val) {
  if (typeof val === 'number' || typeof val === 'boolean') return val;
  if (typeof val === 'string')  return val.replace(/[<>&"'`]/g, '').slice(0, 512);
  if (val && typeof val === 'object') {
    const clean = {};
    for (const [k, v] of Object.entries(val)) {
      const ks = String(k).replace(/[^a-zA-Z0-9_]/g, '').slice(0, 64);
      clean[ks] = sanitize(v);
    }
    return clean;
  }
  return null;
}

// ── Expose ONLY these safe APIs to renderer ───────────────────────────────────
contextBridge.exposeInMainWorld('focusAPI', {

  /** Send a one-way message to main */
  send(channel, data) {
    if (!SEND_CHANNELS.has(channel)) return;
    ipcRenderer.send(channel, sanitize(data));
  },

  /** Invoke a two-way call and get a response */
  async invoke(channel, data) {
    if (!INVOKE_CHANNELS.has(channel)) throw new Error('Blocked channel');
    return ipcRenderer.invoke(channel, sanitize(data));
  },

  /** Subscribe to messages from main process */
  on(channel, callback) {
    if (!RECV_CHANNELS.has(channel)) return;
    const wrapped = (_, ...args) => callback(...args);
    ipcRenderer.on(channel, wrapped);
    // Return unsubscribe function
    return () => ipcRenderer.removeListener(channel, wrapped);
  },

  /** Get OS notification permission (always true in Electron) */
  notificationsEnabled: () => true,
});
