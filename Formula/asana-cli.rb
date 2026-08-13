class AsanaCli < Formula
  desc "Command-line interface for safe Asana task workflows"
  homepage "https://github.com/danielsitek/asana-cli"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.3.0/asana-cli-v0.3.0-darwin-arm64.tar.gz"
      sha256 "25167befb5dceb1d4859a14b993f5235f7b1d99b8f50daac848e12ab1cc8745b"
    end
    on_intel do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.3.0/asana-cli-v0.3.0-darwin-x64.tar.gz"
      sha256 "6d6ba8a7c94699be4da0c5b546432d775161d1b792ac08311be50be7ae22af55"
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
