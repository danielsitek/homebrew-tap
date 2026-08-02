class AsanaCli < Formula
  desc "Command-line interface for safe Asana task workflows"
  homepage "https://github.com/danielsitek/asana-cli"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.1.0/asana-cli-v0.1.0-darwin-arm64.tar.gz"
      sha256 "073285b09b07693d9799259abe163d1121b7b17c98e8e4ddd1f52b1ca3ea85de"
    end
    on_intel do
      url "https://github.com/danielsitek/asana-cli/releases/download/v0.1.0/asana-cli-v0.1.0-darwin-x64.tar.gz"
      sha256 "c00183bb647e7855e386d85af15719a973ed46274e1f2c85d68c07161a421d9d"
    end
  end

  def install
    bin.install "asana-cli"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/asana-cli --version")
    output = shell_output("#{bin}/asana-cli tasks get invalid 2>&1", 2)
    assert_match '"code":"invalid_usage"', output
  end
end
