class AsanaCli < Formula
  desc "Command-line interface for safe Asana task workflows"
  homepage "https://github.com/danielsitek/asana-cli"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.14.0/asana-cli-v0.14.0-darwin-arm64.tar.gz"
      sha256 "9ff3ae1059787f3fc511ce9ede74a889ccebdf34623e0eec519871dc8dd55f3c"
    end
    on_intel do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.14.0/asana-cli-v0.14.0-darwin-x64.tar.gz"
      sha256 "706dc3a7e2c9b99d77b147422cd0bd2089cef440d6a1d9588e11c3160a692bd8"
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
