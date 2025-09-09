#!/bin/sh -e

if [ -n "${GITHUB_WORKSPACE}" ]
then
    git config --global --add safe.directory "${GITHUB_WORKSPACE}" || exit 1
    git config --global --add safe.directory "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit 1
    cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit 1
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

TEMP_PATH="$(mktemp -d)"
PATH="${TEMP_PATH}:$PATH"

echo '::group::🐶 Installing reviewdog ... https://github.com/reviewdog/reviewdog'
curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/fd59714416d6d9a1c0692d872e38e7f8448df4fc/install.sh | sh -s -- -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}" 2>&1
echo '::endgroup::'

if [ "${INPUT_SKIP_INSTALL}" = "false" ]; then
  echo '::group:: Installing erb_lint with extensions ... https://github.com/Shopify/erb_lint'
  # if 'gemfile' erb_lint version selected
  if [ "$INPUT_ERBLINT_VERSION" = "gemfile" ]; then
    # if Gemfile.lock is here
    if [ -f 'Gemfile.lock' ]; then
      # grep for erb_lint version
      ERBLINT_GEMFILE_VERSION=$(ruby -ne 'print $& if /^\s{4}erb_lint\s\(\K.*(?=\))/' Gemfile.lock)

      # if erb_lint version found, then pass it to the gem install
      # left it empty otherwise, so no version will be passed
      if [ -n "$ERBLINT_GEMFILE_VERSION" ]; then
        ERBLINT_VERSION=$ERBLINT_GEMFILE_VERSION
        else
          printf "Cannot get the erb_lint's version from Gemfile.lock. The latest version will be installed."
      fi
      else
        printf 'Gemfile.lock not found. The latest version will be installed.'
    fi
    else
      # set desired erb_lint version
      ERBLINT_VERSION=$INPUT_ERBLINT_VERSION
  fi

  gem install -N erb_lint --version "${ERBLINT_VERSION}"
  echo '::endgroup::'
fi

if [ "${INPUT_USE_BUNDLER}" = "false" ]; then
  BUNDLE_EXEC=""
else
  BUNDLE_EXEC="bundle exec "
fi

echo '::group:: Running erb_lint with reviewdog 🐶 ...'
ERBLINT_REPORT_FILE="$TEMP_PATH"/erblint_report

# shellcheck disable=SC2086
${BUNDLE_EXEC}erb_lint --lint-all --format compact --allow-no-files --fail-level F --show-linter-names ${INPUT_ERBLINT_FLAGS} > "$ERBLINT_REPORT_FILE"
reviewdog < "$ERBLINT_REPORT_FILE" \
  -efm="%f:%l:%c: %m" \
  -name="${INPUT_TOOL_NAME}" \
  -reporter="${INPUT_REPORTER}" \
  -filter-mode="${INPUT_FILTER_MODE}" \
  -level="${INPUT_LEVEL}" \
  "${INPUT_REVIEWDOG_FLAGS}"

exit_code=$?
echo '::endgroup::'

exit $exit_code
