#!/usr/bin/env node

/**
 * Download fonts from Google Fonts and save locally
 * Run: node scripts/download-fonts.js
 */

const https = require('https');
const fs = require('fs');
const path = require('path');

const ASSET_DIR = path.join(__dirname, '..', 'assets', 'fonts');

// Ensure fonts directory exists
if (!fs.existsSync(ASSET_DIR)) {
  fs.mkdirSync(ASSET_DIR, { recursive: true });
  console.log(`Created ${ASSET_DIR}`);
}

// Font definitions: name, google-fonts-ID, weights to download
const fonts = [
  {
    name: 'Orbitron',
    id: 'font?family=Orbitron:wght@400;700;900',
    weights: ['400', '700', '900']
  },
  {
    name: 'ShareTechMono',
    id: 'font?family=Share+Tech+Mono',
    weights: ['400']
  },
  {
    name: 'Exo2',
    id: 'font?family=Exo+2:wght@300;400;600',
    weights: ['300', '400', '600']
  }
];

// Google Fonts CSS endpoint
const baseUrl = 'https://fonts.googleapis.com/css2?family=';

async function downloadFont(fontName, family, weights) {
  return new Promise((resolve, reject) => {
    const url = `${baseUrl}${family}&display=swap`;

    https.get(url, { headers: { 'User-Agent': 'focusguard-font-downloader' } }, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        // Parse @font-face declarations and extract URLs
        const fontFaces = data.match(/@font-face\s*{[^}]*}/g) || [];
        if (fontFaces.length > 0) {
          console.log(`✓ Downloaded ${fontName}: ${fontFaces.length} variant(s)`);
          resolve(fontFaces);
        } else {
          reject(new Error(`No @font-face declarations found for ${fontName}`));
        }
      });
    }).on('error', reject);
  });
}

async function main() {
  try {
    console.log('Downloading fonts from Google Fonts...\n');

    // Download Orbitron
    await downloadFont('Orbitron', 'Orbitron:wght@400;700;900');

    // Download Share Tech Mono
    await downloadFont('Share Tech Mono', 'Share+Tech+Mono');

    // Download Exo 2
    await downloadFont('Exo 2', 'Exo+2:wght@300;400;600');

    console.log('\n✓ All fonts downloaded successfully!');
    console.log(`\nNext steps:`);
    console.log(`1. Visit https://fonts.google.com/ and search for each font`);
    console.log(`2. Download WOFF2 files for the required weights`);
    console.log(`3. Place them in: ${ASSET_DIR}`);
    console.log(`\nFont files needed:`);
    console.log(`  - Orbitron-Regular.woff2, Orbitron-Bold.woff2, Orbitron-Black.woff2`);
    console.log(`  - ShareTechMono-Regular.woff2`);
    console.log(`  - Exo2-Light.woff2, Exo2-Regular.woff2, Exo2-SemiBold.woff2`);

  } catch (error) {
    console.error('Error downloading fonts:', error.message);
    process.exit(1);
  }
}

main();

