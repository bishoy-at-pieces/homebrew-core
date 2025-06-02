class Whistle < Formula
  desc "HTTP, HTTP2, HTTPS, Websocket debugging proxy"
  homepage "https://github.com/avwo/whistle"
  url "https://registry.npmjs.org/whistle/-/whistle-2.9.99.tgz"
  sha256 "ee6c285e2d6a36a018b6bdd30ac4027e864d457e6aa008b78c82f080d19b47a9"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "c0de5233a6fbbf508637af294b958271b8bb327e11afb966e767598bdf527fcc"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    (testpath/"package.json").write('{"name": "test"}')
    system bin/"whistle", "start"
    system bin/"whistle", "stop"
  end
end
