/**
 * Generate favicon set for public/ from the white brand wordmark.
 * Crops to the eL mark so 16px stays legible; navy #00133C background.
 */
import sharp from "sharp";
import { writeFileSync } from "node:fs";
import { join } from "node:path";

const ROOT = process.cwd();
const PUB = join(ROOT, "public");
const SRC = join(PUB, "images/brand/elessons-logo-white.png");
const NAVY = { r: 0, g: 19, b: 60, alpha: 1 }; // #00133C

async function makeMark(size, { inset = 1, padRatio = 0.14 } = {}) {
  const meta = await sharp(SRC).metadata();
  const h = meta.height;
  // Left crop covering e + large L only (avoid trailing "essons" fragment)
  const cropW = Math.round(h * 0.72);
  const cropBuf = await sharp(SRC)
    .extract({ left: 0, top: 0, width: Math.min(cropW, meta.width), height: h })
    .png()
    .toBuffer();

  const canvas = size;
  const safe = Math.round(canvas * inset);
  const pad = Math.round(safe * padRatio);
  const maxInner = Math.max(1, safe - pad * 2);

  const resized = await sharp(cropBuf)
    .resize({
      width: maxInner,
      height: maxInner,
      fit: "contain",
      background: { r: 0, g: 0, b: 0, alpha: 0 },
    })
    .png()
    .toBuffer({ resolveWithObject: true });

  const left = Math.round((canvas - resized.info.width) / 2);
  const top = Math.round((canvas - resized.info.height) / 2);

  return sharp({
    create: { width: canvas, height: canvas, channels: 4, background: NAVY },
  })
    .composite([{ input: resized.data, left, top }])
    .png()
    .toBuffer();
}

function pngToIco(pngBuffers, sizes) {
  // Minimal multi-image ICO writer (PNG-compressed entries — Vista+)
  const count = pngBuffers.length;
  const headerSize = 6 + count * 16;
  let offset = headerSize;
  const entries = [];
  for (let i = 0; i < count; i++) {
    const size = sizes[i];
    const data = pngBuffers[i];
    const w = size >= 256 ? 0 : size;
    const h = size >= 256 ? 0 : size;
    entries.push({ w, h, size: data.length, offset, data });
    offset += data.length;
  }
  const buf = Buffer.alloc(offset);
  buf.writeUInt16LE(0, 0);
  buf.writeUInt16LE(1, 2);
  buf.writeUInt16LE(count, 4);
  let entryAt = 6;
  for (const e of entries) {
    buf.writeUInt8(e.w, entryAt);
    buf.writeUInt8(e.h, entryAt + 1);
    buf.writeUInt8(0, entryAt + 2);
    buf.writeUInt8(0, entryAt + 3);
    buf.writeUInt16LE(1, entryAt + 4);
    buf.writeUInt16LE(32, entryAt + 6);
    buf.writeUInt32LE(e.size, entryAt + 8);
    buf.writeUInt32LE(e.offset, entryAt + 12);
    e.data.copy(buf, e.offset);
    entryAt += 16;
  }
  return buf;
}

const svg = `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" role="img" aria-label="G-TEC eLessons">
  <rect width="64" height="64" fill="#00133C"/>
  <text x="8" y="46" font-family="Georgia, 'Times New Roman', serif" font-size="36" font-weight="700" fill="#FFFFFF">e</text>
  <text x="26" y="52" font-family="Georgia, 'Times New Roman', serif" font-size="48" font-weight="700" fill="#FFFFFF">L</text>
</svg>
`;

async function main() {
  const out = {
    "apple-touch-icon.png": await makeMark(180, { padRatio: 0.16 }),
    "icon-192.png": await makeMark(192, { padRatio: 0.14 }),
    "icon-512.png": await makeMark(512, { padRatio: 0.14 }),
    "icon-512-maskable.png": await makeMark(512, { inset: 1, padRatio: 0.1 }), // ~80% safe zone
    "favicon-32.png": await makeMark(32, { padRatio: 0.12 }),
  };

  for (const [name, buf] of Object.entries(out)) {
    writeFileSync(join(PUB, name), buf);
    console.log("wrote", name, buf.length);
  }

  const icoSizes = [16, 32, 48];
  const icoPngs = [];
  for (const s of icoSizes) {
    icoPngs.push(await makeMark(s, { padRatio: 0.1 }));
  }
  const ico = pngToIco(icoPngs, icoSizes);
  writeFileSync(join(PUB, "favicon.ico"), ico);
  console.log("wrote favicon.ico", ico.length);

  writeFileSync(join(PUB, "favicon.svg"), svg);
  console.log("wrote favicon.svg", svg.length);

  const manifest = {
    name: "G-TEC eLessons.net",
    short_name: "eLessons",
    icons: [
      { src: "/icon-192.png", sizes: "192x192", type: "image/png", purpose: "any" },
      { src: "/icon-512.png", sizes: "512x512", type: "image/png", purpose: "any" },
      {
        src: "/icon-512-maskable.png",
        sizes: "512x512",
        type: "image/png",
        purpose: "maskable",
      },
    ],
    theme_color: "#00133C",
    background_color: "#00133C",
    display: "standalone",
    start_url: "/",
  };
  writeFileSync(join(PUB, "site.webmanifest"), JSON.stringify(manifest, null, 2) + "\n");
  console.log("wrote site.webmanifest");
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
