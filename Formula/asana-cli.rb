class AsanaCli < Formula
  desc "Command-line interface for safe Asana task workflows"
  homepage "https://github.com/danielsitek/asana-cli"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.9.0/asana-cli-v0.9.0-darwin-arm64.tar.gz"
      sha256 "ac6db83fa5e0f705d0dc98873c382f45e2369da35d644d87e98f69e5d9c0ad50"
    end
    on_intel do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.9.0/asana-cli-v0.9.0-darwin-x64.tar.gz"
      sha256 "cbe45da9723f2f2453f57c7a2b5876bf86d07ca3de357b5257f9863460c4402f"
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
