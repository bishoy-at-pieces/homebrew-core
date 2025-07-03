class SoftServe < Formula
  desc "Mighty, self-hostable Git server for the command-line"
  homepage "https://github.com/charmbracelet/soft-serve"
  url "https://github.com/charmbracelet/soft-serve/archive/refs/tags/v0.9.0.tar.gz"
  sha256 "110e0cc80f5357b4c4352b900f9af7670591cffc5ed52fa04d6f5664298d7e88"
  license "MIT"
  head "https://github.com/charmbracelet/soft-serve.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d89338a0132682d796a9a2da0048e3bd1fe99a3ef2ab4be94252b8bc7df71e33"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "109d924ca9f0c99d61809875c38adc91eef9a4eb32009b8d7fbace9ed323966f"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "7a0f8246eb5333a79806dd80ea192c25b6887f160d5a0c13611fec759d917b5a"
    sha256 cellar: :any_skip_relocation, sonoma:        "310fd7f17c0168b861a6b5cf4d5f6061c70bb476fb0f41b6c64c6ded090a4442"
    sha256 cellar: :any_skip_relocation, ventura:       "291ab0287c0258feebe938a12f2d999a45418a68bdb9c9e282e1e0cae92d1a70"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "1fa85c0043c5cded505120bc5fd65d883b0e55019d7d4306b5c1752a3c0452d8"
  end

  depends_on "go" => :build

  def install
    ldflags = "-s -w -X main.Version=#{version} -X main.CommitSHA=#{tap.user} -X main.CommitDate=#{time.iso8601}"
    system "go", "build", *std_go_args(ldflags:, output: bin/"soft"), "./cmd/soft"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/soft --version")

    pid = spawn bin/"soft", "serve"
    sleep 1
    Process.kill("TERM", pid)
    assert_path_exists testpath/"data/soft-serve.db"
    assert_path_exists testpath/"data/hooks/update.sample"
  end
end
