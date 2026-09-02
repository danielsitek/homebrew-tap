class AsanaCli < Formula
  desc "Command-line interface for safe Asana task workflows"
  homepage "https://github.com/danielsitek/asana-cli"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.5.0/asana-cli-v0.5.0-darwin-arm64.tar.gz"
      sha256 "60c655d7260cad99648d2dc49ec7b2cdf1ce10aab3879e235de14481465aa6b5"
    end
    on_intel do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.5.0/asana-cli-v0.5.0-darwin-x64.tar.gz"
      sha256 "400eb88b1772946e3daef4cdff6a93f696b3e91aea964dc90103caf38a689af1"
    end
  end

  def install
    bin.install "asana-cli"
    generate_completions_from_executable bin/"asana-cli", "completion"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/asana-cli --version")
    output = shell_output("#{bin}/asana-cli tasks get invalid 2>&1", 2)
    assert_match '"code":"invalid_usage"', output
  end
end
