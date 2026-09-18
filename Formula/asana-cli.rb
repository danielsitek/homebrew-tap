class AsanaCli < Formula
  desc "Command-line interface for safe Asana task workflows"
  homepage "https://github.com/danielsitek/asana-cli"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.6.1/asana-cli-v0.6.1-darwin-arm64.tar.gz"
      sha256 "58ce7b9d69d144b23c5a352519dcfa52155848cb87cfe6ae0eabba4878cd2fae"
    end
    on_intel do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.6.1/asana-cli-v0.6.1-darwin-x64.tar.gz"
      sha256 "cc1c195c8ed1e3796049760b05b1426717970c6e9d2695a3d4e382b62119a12e"
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
