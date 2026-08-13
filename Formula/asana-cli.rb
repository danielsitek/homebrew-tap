class AsanaCli < Formula
  desc "Command-line interface for safe Asana task workflows"
  homepage "https://github.com/danielsitek/asana-cli"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.3.1/asana-cli-v0.3.1-darwin-arm64.tar.gz"
      sha256 "316ba2726311588420a1e52d3723163f85b259d2790e11aefda6bb5f0eed4d45"
    end
    on_intel do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.3.1/asana-cli-v0.3.1-darwin-x64.tar.gz"
      sha256 "d342a218a5eede515c9938e54cd81a004994aaca8d99e41d7c6f78b32fa23de0"
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
