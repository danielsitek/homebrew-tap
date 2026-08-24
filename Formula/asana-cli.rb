class AsanaCli < Formula
  desc "Command-line interface for safe Asana task workflows"
  homepage "https://github.com/danielsitek/asana-cli"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.4.0/asana-cli-v0.4.0-darwin-arm64.tar.gz"
      sha256 "1f3e2e6cb42c92b403ba0010de68b7d4222e111245bd1e9f62add1c3fac8443c"
    end
    on_intel do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.4.0/asana-cli-v0.4.0-darwin-x64.tar.gz"
      sha256 "921cd5b3f5c058e389946f87ed1043ea0a0a1dbb2b4ebba4d0096291ee51a857"
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
