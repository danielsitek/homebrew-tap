class AsanaCli < Formula
  desc "Command-line interface for safe Asana task workflows"
  homepage "https://github.com/danielsitek/asana-cli"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.9.1/asana-cli-v0.9.1-darwin-arm64.tar.gz"
      sha256 "7a75939778dbe1eb1eb9e724c20b9964bcb2e681da9e617d0d2f2d65d27a33c8"
    end
    on_intel do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.9.1/asana-cli-v0.9.1-darwin-x64.tar.gz"
      sha256 "4a97b1184fbafd064e28a1e6fd45d56e1c1fa55e1c013a8b26238f74f6ee15b4"
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
