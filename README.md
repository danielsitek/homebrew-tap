# Homebrew Tap

Homebrew formulae maintained by Daniel Sitek.

## Asana CLI

```sh
brew install danielsitek/homebrew-tap/asana-cli
```

Project documentation: [danielsitek/asana-cli](https://github.com/danielsitek/asana-cli)

## Automated updates

The [Update formulas workflow](.github/workflows/update-formulas.yml) runs after an
`upstream_release` repository dispatch, on a daily schedule, or manually. It
fetches the published GitHub release, checks `SHA256SUMS` and asset names,
generates a candidate, and tests `brew install` and `brew test` on macOS ARM
and Intel. Only then does it commit a newer formula to `main`. Pull requests
run the same checks without publishing. Repeated and older releases leave the
current formula unchanged.

To retry, open **Actions → Update formulas → Run workflow** and enter the
allowed `owner/repository` and release tag (for example,
`danielsitek/asana-cli` and `v0.6.0`). Leave the tag empty to use the latest
published release; leave both fields empty to reconcile every configured
project. You can also run `ruby scripts/update.rb plan` locally to generate
candidates for inspection. The updater uses only Ruby's standard library.

To add a project, add its repository, formula name, tag prefix, checksum asset,
and exact archive names to [config/releases.json](config/releases.json). Add a
formula renderer under `lib/renderers/` and register it in
`lib/tap_update.rb`; keep project-specific formula text out of shared release
validation. The manifest must list every configured archive exactly once as
`<sha256><two spaces><filename>`. Add renderer tests before enabling the new
entry. The workflow matrix will test and publish each configured formula.

The upstream repository should dispatch `upstream_release` to this tap with
`client_payload` containing `repository` and `tag`. This tap must already have
the workflow on its default branch. The source repository needs a credential
authorized to send repository dispatch events to this tap; its ordinary
`GITHUB_TOKEN` does not grant access to another repository. The scheduled run
also recovers updates missed by dispatch.
