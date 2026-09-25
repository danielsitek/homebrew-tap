class AsanaCli < Formula
  desc "Command-line interface for safe Asana task workflows"
  homepage "https://github.com/danielsitek/asana-cli"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.8.0/asana-cli-v0.8.0-darwin-arm64.tar.gz"
      sha256 "53dfb9c0792cf45748034087d3c3bf8d496e264aa9b0b078e74ffca5ecb40331"
    end
    on_intel do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.8.0/asana-cli-v0.8.0-darwin-x64.tar.gz"
      sha256 "3ada290ba9ff3c38d4fd85083652d2c230bd3aee7c7d36f2a2c3171c25c3acec"
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
