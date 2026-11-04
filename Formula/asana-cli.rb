class AsanaCli < Formula
  desc "Command-line interface for safe Asana task workflows"
  homepage "https://github.com/danielsitek/asana-cli"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.11.0/asana-cli-v0.11.0-darwin-arm64.tar.gz"
      sha256 "f22fb2fa396b26edec6dee2faa11c842eab42fcbf2a856dd0db12006a441df6f"
    end
    on_intel do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.11.0/asana-cli-v0.11.0-darwin-x64.tar.gz"
      sha256 "eea2103d80f379f7bc1f8660a1c6cacf60a01b56cc769510399808583944d66f"
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
