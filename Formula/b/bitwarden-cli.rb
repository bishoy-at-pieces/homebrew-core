class BitwardenCli < Formula
  desc "Secure and free password manager for all of your devices"
  homepage "https://bitwarden.com/"
  url "https://github.com/bitwarden/clients/archive/refs/tags/cli-v2025.5.0.tar.gz"
  sha256 "247ca881c8a9f407c494977f7e8555fe11beff017d0cfda6a6d437ec0c0978d6"
  license "GPL-3.0-only"

  livecheck do
    url :stable
    regex(/^cli[._-]v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256                               arm64_sequoia: "8135a07ebdcea3d1f7ded32a9c3c3f2e44d36149a28ebbfaa3f1a36f9442a9b6"
    sha256                               arm64_sonoma:  "b3e3d00aead0feb9093f8824643bb3bd386bd514bf353744557570d0c1112acf"
    sha256                               arm64_ventura: "081a5a6d709da2f18ead6b1f72a40157016b0e7053ed5d702a20f459dc02319f"
    sha256                               sonoma:        "85b5bf952cf8bc3af074eb591ac3aa23cec31fc51b04fd0e0e89713c6a2a28bc"
    sha256                               ventura:       "a636e9b2000aa701f0458536699da75198acdc202ebab30708285553939b2667"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "f3ab609bea3ee40e18d0886a20d622791afa6de1bcb48f463f3017f665ef16af"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "db9064f3684fe40c5090a3e47cec50fdc6f6418581d26cdd4da3065d93e28013"
  end

  depends_on "node"

  def install
    system "npm", "ci", "--ignore-scripts"

    # Fix to build error with xcode 16.3 for `argon2`
    # Issue ref:
    # - https://github.com/bitwarden/clients/issues/15000
    # - https://github.com/ranisalt/node-argon2/issues/448
    inreplace "package.json", '"argon2": "0.41.1"', '"argon2": "0.43.0"'
    inreplace "apps/cli/package.json", '"argon2": "0.41.1"', '"argon2": "0.43.0"'

    # Fix to Error: Cannot find module 'semver'
    # PR ref: https://github.com/bitwarden/clients/pull/15005
    system "npm", "install", "semver", "argon2", *std_npm_args

    cd buildpath/"apps/cli" do
      # The `oss` build of Bitwarden is a GPL backed build
      system "npm", "run", "build:oss:prod", "--ignore-scripts"
      cd "./build" do
        # Fix to Error: Cannot find module 'semver'
        # PR ref: https://github.com/bitwarden/clients/pull/15005
        system "npm", "install", "semver", "argon2", *std_npm_args
        bin.install_symlink Dir[libexec/"bin/*"]
      end
    end

    # Remove incompatible pre-built `argon2` binaries
    os = OS.kernel_name.downcase
    arch = Hardware::CPU.intel? ? "x64" : Hardware::CPU.arch.to_s
    base = (libexec/"lib/node_modules")
    universals = "{@microsoft/signalr/node_modules/utf-8-validate,bufferutil,utf-8-validate}"
    universal_archs = "{darwin-x64+arm64,linux-x64}"
    base.glob("@bitwarden/clients/node_modules/#{universals}/prebuilds/#{universal_archs}/*.node").each(&:unlink)
    base.glob("{lib,@bitwarden/cli,@bitwarden/clients}/node_modules/argon2/prebuilds") do |path|
      path.glob("**/*.musl.node").each(&:unlink)
      path.children.each { |dir| rm_r(dir) if dir.directory? && dir.basename.to_s != "#{os}-#{arch}" }
    end

    generate_completions_from_executable(bin/"bw", "completion", shells: [:zsh], shell_parameter_format: :arg)
  end

  test do
    assert_equal 10, shell_output("#{bin}/bw generate --length 10").chomp.length

    output = pipe_output("#{bin}/bw encode", "Testing", 0)
    assert_equal "VGVzdGluZw==", output.chomp
  end
end
