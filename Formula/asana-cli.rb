class AsanaCli < Formula
  desc "Command-line interface for safe Asana task workflows"
  homepage "https://github.com/danielsitek/asana-cli"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.2.0/asana-cli-v0.2.0-darwin-arm64.tar.gz"
      sha256 "279529495d4d1219859efd5d8e183bda5ecc1dd02b63e3e2363d94ed6b42117b"
    end
    on_intel do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.2.0/asana-cli-v0.2.0-darwin-x64.tar.gz"
      sha256 "2973052e88caafaa4360c4beaf3058289eaec573785c22db0008ab9f5d310959"
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
