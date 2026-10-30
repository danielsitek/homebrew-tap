class AsanaCli < Formula
  desc "Command-line interface for safe Asana task workflows"
  homepage "https://github.com/danielsitek/asana-cli"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.10.2/asana-cli-v0.10.2-darwin-arm64.tar.gz"
      sha256 "c70b474bfd340dee54d04994c031834d120e30af8155fcfc699df7c082dfff7b"
    end
    on_intel do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.10.2/asana-cli-v0.10.2-darwin-x64.tar.gz"
      sha256 "a8bc49571c5ee08aa41dc22388c693fc6c17bf2ed2719bc80ddf865bfb90fa3e"
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
