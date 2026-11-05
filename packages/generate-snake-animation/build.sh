#!/usr/bin/env bash
set -euo pipefail

rm -rf dist && mkdir -p dist

bun build ./generateSnakeAnimation.ts --outfile=dist/generateSnakeAnimation.js --target=node --external=canvas --external=gifsicle --external=gif-encoder-2

bun build ./cli.ts --outfile=dist/cli.js --target=node --external=canvas --external=gifsicle --external=gif-encoder-2 --external=./generateSnakeAnimation.js
chmod +x dist/cli.js

# dts-bundle-generator is fetched at build time. It depends on `typescript: >=5.0.2`,
# which resolves to the latest major, whose api no longer exposes `ts.sys`.
# Keep the declaration bundling best effort so that the js/cli build is not blocked.
types_entry='"types": "./generateSnakeAnimation.d.ts",'
if ! bunx -p typescript@5.9.3 -p dts-bundle-generator@9.5.1 dts-bundle-generator --out-file dist/generateSnakeAnimation.d.ts --project tsconfig.json --no-banner --no-check generateSnakeAnimation.ts; then
  echo "::warning::could not bundle the type declarations, shipping the package without types"
  types_entry=""
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
