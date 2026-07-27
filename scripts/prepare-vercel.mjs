import { cpSync, mkdirSync, rmSync, existsSync, writeFileSync, readFileSync } from "node:fs";
import { join } from "node:path";

const root = process.cwd();
const pub = join(root, "public");
const out = join(root, ".vercel-out");

if (existsSync(out)) rmSync(out, { recursive: true, force: true });
mkdirSync(out, { recursive: true });
cpSync(pub, out, { recursive: true });

// Ensure index.html is the entry
const index = join(out, "index.html");
if (!existsSync(index)) {
  const home = join(out, "homepage.html");
  if (existsSync(home)) cpSync(home, index);
}

writeFileSync(join(out, ".vercel-ready"), `elessons v23 ${new Date().toISOString()}\n`);
console.log("Prepared static output at .vercel-out");
