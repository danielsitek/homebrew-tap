class AsanaCli < Formula
  desc "Command-line interface for safe Asana task workflows"
  homepage "https://github.com/danielsitek/asana-cli"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.12.0/asana-cli-v0.12.0-darwin-arm64.tar.gz"
      sha256 "e2b8dccfaa76f5322adcee974507895c89f03d2298abbf8b26ae172054349e1f"
    end
    on_intel do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.12.0/asana-cli-v0.12.0-darwin-x64.tar.gz"
      sha256 "2bb40c65bf0967293b8a479f55e493732eadb555aafe6a6dfbe1d189a3b47de6"
    end
  end

  def install
    bin.install "asana-cli"
    generate_completions_from_executable bin/"asana-cli", "completion"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/asana-cli --version")
    output = shell_output("#{bin}/asana-cli tasks get invalid --json 2>&1", 2)
    assert_match '"code":"invalid_usage"', output
  end
end
