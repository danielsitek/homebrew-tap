class AsanaCli < Formula
  desc "Command-line interface for safe Asana task workflows"
  homepage "https://github.com/danielsitek/asana-cli"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.6.0/asana-cli-v0.6.0-darwin-arm64.tar.gz"
      sha256 "28aebccfdeb79716d0239f3b3b8357a0280b965607120d80e73b64a1da43c170"
    end
    on_intel do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.6.0/asana-cli-v0.6.0-darwin-x64.tar.gz"
      sha256 "a357fdf1b56e77754dcd2d1a5484cda6fb1207a917ff244e4c2d0270c47aab57"
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
