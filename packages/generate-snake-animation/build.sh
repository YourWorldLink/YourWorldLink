#!/usr/bin/env bash
set -euo pipefail

rm -rf dist && mkdir -p dist

bun build ./generateSnakeAnimation.ts --outfile=dist/generateSnakeAnimation.js --target=node --external=canvas --external=gifsicle --external=gif-encoder-2

bun build ./cli.ts --outfile=dist/cli.js --target=node --external=canvas --external=gifsicle --external=gif-encoder-2 --external=./generateSnakeAnimation.js
chmod +x dist/cli.js

# Typescript declaration bundling is opt-in.
# dts-bundle-generator is fetched at build time and declares `typescript: >=5.0.2`,
# which resolves to a major whose api no longer exposes `ts.sys`; under bunx the
# bundling therefore crashes on current runners. The js bundles and the cli do not
# need it, so skip it by default and let `SNK_BUILD_TYPES=1` re-enable it once the
# toolchain works again.
types_entry=''
if [ "${SNK_BUILD_TYPES:-0}" = "1" ]; then
  if bunx dts-bundle-generator --out-file dist/generateSnakeAnimation.d.ts --project tsconfig.json --no-banner --no-check generateSnakeAnimation.ts; then
    types_entry='"types": "./generateSnakeAnimation.d.ts",'
  fi
fi

cat > dist/package.json << EOF
{
  "name": "generate-snake-animation",
  "version": "$(node -p "require('../../package.json').version")",
  "bin": { "generate-snake-animation": "cli.js" },
  "type": "module",
  "main": "./generateSnakeAnimation.js",
  $types_entry
  "peerDependencies": {
    "canvas": "3.2.0",
    "gif-encoder-2": "1.0.5",
    "gifsicle": "5.3.0"
  },
  "peerDependenciesMeta": {
    "canvas": { "optional": true },
    "gif-encoder-2": { "optional": true },
    "gifsicle": { "optional": true }
  }
}
EOF
