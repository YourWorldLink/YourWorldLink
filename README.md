# YourWorldLink

<picture>
  <source
    media="(prefers-color-scheme: dark)"
    srcset="https://raw.githubusercontent.com/YourWorldLink/YourWorldLink/output/github-contribution-grid-snake-dark.svg"
  />
  <source
    media="(prefers-color-scheme: light)"
    srcset="https://raw.githubusercontent.com/YourWorldLink/YourWorldLink/output/github-contribution-grid-snake.svg"
  />
  <img
    alt="github contribution grid snake animation"
    src="https://raw.githubusercontent.com/YourWorldLink/YourWorldLink/output/github-contribution-grid-snake.svg"
  />
</picture>

A snake eating its way through my GitHub contribution grid. The animation above is regenerated every day by this repository, and the code that produces it lives here as well.

## What this repository is

This repository is a deployment of [snk](https://github.com/platane/snk) **3.5.0** — a generator that turns a GitHub user contribution grid into a snake game animation (svg or gif) — wired up for the `YourWorldLink` account:

- `.github/workflows/snake.yml` renders the snake from **my** contribution grid every day (and on every push to `main`), then publishes the images to the `output` branch.
- The images are served straight from `raw.githubusercontent.com`, so the README above always shows the latest contribution data.
- `.github/workflows/ci.yml` type-checks, lints and tests the library, the cli and the `svg-only` action.
- `.github/workflows/manual-run.yml` is a manual end-to-end check of both actions, including the gif pipeline.

## Using the action

Two entry points, both self-contained in this repository.

**svg only** (fast, plain node action — recommended for profile readmes):

```yaml
- uses: YourWorldLink/YourWorldLink/svg-only@main
  with:
    github_user_name: ${{ github.repository_owner }}
    outputs: |
      dist/github-contribution-grid-snake.svg
      dist/github-contribution-grid-snake-dark.svg?palette=github-dark
      dist/ocean.svg?color_snake=orange&color_dots=#bfd6f6,#8dbdff,#64a1f4,#4b91f1,#3c7dd9
```

**svg and gif** (docker action, built from the [`Dockerfile`](./Dockerfile) on first run — slower, needed for gif output):

```yaml
- uses: YourWorldLink/YourWorldLink@main
  with:
    github_user_name: ${{ github.repository_owner }}
    outputs: |
      dist/github-contribution-grid-snake.svg
      dist/github-contribution-grid-snake.gif
      dist/dark.gif?palette=github-dark
```

### Output options

Each line of `outputs` is a file to generate. The query string customizes it:

| option             | meaning                                                                                                         |
| ------------------ | --------------------------------------------------------------------------------------------------------------- |
| `palette`          | preset colors, one of `github`, `github-dark`, `github-light`                                                   |
| `color_snake`      | snake color                                                                                                     |
| `color_dots`       | 5 comma separated colors, from `0` contributions to the highest, e.g. `#bfd6f6,#8dbdff,#64a1f4,#4b91f1,#3c7dd9` |
| `color_background` | background color, `gif` only                                                                                    |

Changing the animation shown above is a matter of editing the `outputs:` block in [`.github/workflows/snake.yml`](./.github/workflows/snake.yml) and pushing to `main`.

## Local usage

Requires [bun](https://bun.sh) (the repository pins `1.3.12` in the workflows).

```sh
bun install

# interactive demo, http://localhost:5173
npm run dev:demo

# type check / lint / tests
npm run type
npm run lint
bun test

# build the svg-only action bundle into svg-only/dist
npm run build:action
```

## Repository layout

| path                                        | content                                                      |
| ------------------------------------------- | ------------------------------------------------------------ |
| `packages/generate-snake-animation`         | library and cli, entry point of the whole thing              |
| `packages/action`                           | sources of the docker action (`action.yml` at the root)      |
| `svg-only/`                                 | prebuilt node action, svg output only (`dist/` is committed) |
| `packages/solver`                           | snake path solver                                            |
| `packages/draw`, `packages/svg-creator`     | rendering of the grid, the dots and the snake                |
| `packages/gif-creator`                      | gif encoding                                                 |
| `packages/github-user-contribution`         | contribution grid fetching from the GitHub api               |
| `packages/demo`                             | the interactive browser demo                                 |
| `packages/github-user-contribution-service` | the cloudflare worker used by the demo                       |
| `packages/types`                            | shared types                                                 |

## Credits

The generator, the solver and the rendering are the work of [Platane](https://github.com/platane) and the contributors of [platane/snk](https://github.com/platane/snk). This repository redistributes version 3.5.0 with the deployment configuration adapted to this account. Respect the upstream project's [contribution policy](https://github.com/platane/snk#contribution-policy) — the upstream does not accept pull requests, and no license file is published upstream, so treat the code as all rights reserved.
