# workflows — reusable GitHub Actions workflows for every preset.nz code repo.
# Standard verbs: prep, check. No install (nothing to fetch), run or build (nothing runs here).

default:
    @just --list

[group('setup')]
prep:
    @echo "actionlint: $(actionlint --version 2>/dev/null | head -n1 || echo 'MISSING (brew install actionlint)')"
    @echo "zizmor:     $(zizmor --version 2>/dev/null || echo 'MISSING (brew install zizmor)')"
    @echo "lefthook:   $(lefthook version 2>/dev/null || echo 'MISSING (brew install lefthook)')"
    @echo "knope:      $(knope --version 2>/dev/null || echo 'MISSING (cargo binstall knope)')"

# actionlint: syntax, expressions, shellcheck on run steps. zizmor: security (unpinned
# actions, template injection, token permissions); offline, so it needs no token.
[group('quality')]
check:
    actionlint
    zizmor --offline --no-progress .

# Version, changelog, commit and tag from the conventional commits since the last tag
# (knope.toml). Callers pin the tag it creates. Push stays by hand.
[group('build')]
release:
    knope release

# What `release` would do, without touching anything.
[group('build')]
release-preview:
    knope release --dry-run
