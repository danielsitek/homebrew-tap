class AsanaCli < Formula
  desc "Command-line interface for safe Asana task workflows"
  homepage "https://github.com/danielsitek/asana-cli"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.10.0/asana-cli-v0.10.0-darwin-arm64.tar.gz"
      sha256 "b36dd2223eb340b4ae3be2b4b142def6dd2fa89ff9246f392852ebe1507c26b3"
    end
    on_intel do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.10.0/asana-cli-v0.10.0-darwin-x64.tar.gz"
      sha256 "ec0095d81d1f93aa0bda3a1c9999debb11d0108ac491454f5727820da6b9548c"
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
