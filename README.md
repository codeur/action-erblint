# GitHub Action: Run erb_lint with reviewdog 🐶

[![](https://img.shields.io/github/license/codeur/action-erblint)](./LICENSE)
[![depup](https://github.com/codeur/action-erblint/workflows/depup/badge.svg)](https://github.com/codeur/action-erblint/actions?query=workflow%3Adepup)
[![release](https://github.com/codeur/action-erblint/workflows/release/badge.svg)](https://github.com/codeur/action-erblint/actions?query=workflow%3Arelease)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/codeur/action-erblint?logo=github&sort=semver)](https://github.com/codeur/action-erblint/releases)
[![action-bumpr supported](https://img.shields.io/badge/bumpr-supported-ff69b4?logo=github&link=https://github.com/haya14busa/action-bumpr)](https://github.com/haya14busa/action-bumpr)

This action runs [erb_lint](https://github.com/Shopify/erb_lint) with
[reviewdog](https://github.com/reviewdog/reviewdog) on pull requests to improve
code review experience.

## Examples

### With `github-pr-check`

By default, with `reporter: github-pr-check` an annotation is added to the line:

![Example comment made by the action, with github-pr-check](examples/example-github-pr-check.png)

### With `github-pr-review`

With `reporter: github-pr-review` a comment is added to the Pull Request Conversation:

![Example comment made by the action, with github-pr-review](examples/example-github-pr-review.png)

## Inputs

### `github_token`

`GITHUB_TOKEN`. Default is `${{ github.token }}`.

### `erblint_version`

Optional. Set erb_lint version.

- empty or omit: install latest version
- `gemfile`: install version from Gemfile (`Gemfile.lock` should be presented, otherwise it will fallback to latest bundler version)
- version (e.g. `0.9.0`): install said version

### `erblint_flags`

Optional. erb_lint flags. (erb_lint --quiet --format tabs --no-exit-on-warn --no-exit-on-error `<erblint_flags>`)

### `tool_name`

Optional. Tool name to use for reviewdog reporter. Useful when running multiple
actions with different config.

### `level`

Optional. Report level for reviewdog [`info`, `warning`, `error`].
It's same as `-level` flag of reviewdog.

### `reporter`

Optional. Reporter of reviewdog command [`github-pr-check`, `github-pr-review`].
The default is `github-pr-check`.

### `filter_mode`

Optional. Filtering mode for the reviewdog command [`added`, `diff_context`, `file`, `nofilter`].
Default is `added`.

### `reviewdog_flags`

Optional. Additional reviewdog flags.

### `workdir`

Optional. The directory from which to look for and run erb_lint. Default `.`.

### `skip_install`

Optional. Do not install erb_lint. Default: `false`.

### `use_bundler`

Optional. Run erb_lint with bundle exec. Default: `false`.

## Example usage

```yml
name: reviewdog
on: [pull_request]
jobs:
  erb_lint:
    name: runner / erb_lint
    runs-on: ubuntu-latest
    steps:
      - name: Check out code
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
      - name: Set up Ruby
        uses: ruby/setup-ruby@1a615958ad9d422dd932dc1d5823942ee002799f # v1.227.0
        with:
          ruby-version: 3.4.5
      - name: erb_lint
        uses: codeur/action-erblint@5083efd49634e26645a0736681b618ccc3fb7f14 # v2.19.2
        with:
          erblint_version: 0.9.0
          reporter: github-pr-review # Default is github-pr-check
```

## License

[MIT](https://choosealicense.com/licenses/mit)
