class AsanaCli < Formula
  desc "Command-line interface for safe Asana task workflows"
  homepage "https://github.com/danielsitek/asana-cli"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.7.0/asana-cli-v0.7.0-darwin-arm64.tar.gz"
      sha256 "6901c1eed6693a118d7ba9cec1a4eb7efb80c808afc154b523671deb8e700f75"
    end
    on_intel do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.7.0/asana-cli-v0.7.0-darwin-x64.tar.gz"
      sha256 "4518c6286ea72e22a0f1f3c57d3e1f647d24a7c527cb750423e1e5ab5693e414"
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
