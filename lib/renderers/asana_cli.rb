# frozen_string_literal: true

module TapUpdate
  module Renderers
    module AsanaCli
      def self.render(repository, version, checksums)
        base = "https://github.com/#{repository}/releases/download/v#{version}"
        <<~RUBY
          class AsanaCli < Formula
            desc "Command-line interface for safe Asana task workflows"
            homepage "https://github.com/#{repository}"
            license "MIT"

            on_macos do
              on_arm do
                url "#{base}/asana-cli-v#{version}-darwin-arm64.tar.gz"
                sha256 "#{checksums.fetch('darwin-arm64')}"
              end
              on_intel do
                url "#{base}/asana-cli-v#{version}-darwin-x64.tar.gz"
                sha256 "#{checksums.fetch('darwin-x64')}"
              end
            end

            def install
              bin.install "asana-cli"
              generate_completions_from_executable bin/"asana-cli", "completion"
            end

            test do
              assert_match version.to_s, shell_output("\#{bin}/asana-cli --version")
              output = shell_output("\#{bin}/asana-cli tasks get invalid 2>&1", 2)
              assert_match '"code":"invalid_usage"', output
            end
          end
        RUBY
      end
    end
  end
end
