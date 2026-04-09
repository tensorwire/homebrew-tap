class Neo < Formula
  desc "Agent Neo — A.I. Recon (Automated Intelligent Reconnaissance)"
  homepage "https://open-ai.org"
  url "https://github.com/open-ai-org/agent-neo/archive/v0.1.0.tar.gz"
  sha256 "64acb6e61cdd0d4ac24344e74fe73185991144307e3d34f79bfb6b62e49facdb"
  license "Apache-2.0"
  head "https://github.com/open-ai-org/agent-neo.git", branch: "main"

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X main.version=#{version}
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/neo/"
  end

  test do
    assert_match "Agent Neo", shell_output("#{bin}/neo version")
  end
end
