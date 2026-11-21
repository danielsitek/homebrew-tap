class AsanaCli < Formula
  desc "Command-line interface for safe Asana task workflows"
  homepage "https://github.com/danielsitek/asana-cli"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.13.0/asana-cli-v0.13.0-darwin-arm64.tar.gz"
      sha256 "8c35735956f52739d19f148a0d2e0810f1c207c6243e26c63d567097cb62b66e"
    end
    on_intel do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.13.0/asana-cli-v0.13.0-darwin-x64.tar.gz"
      sha256 "e47e4ba071c3e9106fed0e41ce0d6f90420d62b03727628f18fe06f2dadf2d11"
    end
  end

  def install
    bin.install "asana-cli"
    generate_completions_from_executable bin/"asana-cli", "completion"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/asana-cli --version")
    output = shell_output("#{bin}/asana-cli tasks get invalid --json 2>&1", 2)
    assert_match '"code":"invalid_usage"', output
  end
end
