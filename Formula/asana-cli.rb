class AsanaCli < Formula
  desc "Command-line interface for safe Asana task workflows"
  homepage "https://github.com/danielsitek/asana-cli"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.10.1/asana-cli-v0.10.1-darwin-arm64.tar.gz"
      sha256 "3b50c3117fb3e72bf86dee17222807859665b183fc7432691071607369e80b43"
    end
    on_intel do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.10.1/asana-cli-v0.10.1-darwin-x64.tar.gz"
      sha256 "8297c594d509633b10c23fc599d303262fab0326e2a8655fefc917ea0fc1fe26"
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
