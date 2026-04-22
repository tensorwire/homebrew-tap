class Ai < Formula
  desc "GPU-accelerated ML CLI — train, infer, quantize, serve LLMs"
  homepage "https://github.com/open-ai-org/ai"
  license "MIT"
  head "https://github.com/open-ai-org/ai.git", branch: "master"

  depends_on "go" => :build

  # Dependencies — cloned alongside for local replace directives
  resource "mongoose" do
    url "https://github.com/open-ai-org/mongoose.git", branch: "master", using: :git
  end

  resource "helix" do
    url "https://github.com/open-ai-org/helix.git", branch: "master", using: :git
  end

  resource "needle" do
    url "https://github.com/open-ai-org/needle.git", branch: "master", using: :git
  end

  resource "gguf" do
    url "https://github.com/open-ai-org/gguf.git", branch: "master", using: :git
  end

  resource "tokenizer" do
    url "https://github.com/open-ai-org/tokenizer.git", branch: "master", using: :git
  end

  def install
    # Clone dependencies alongside for go.mod replace directives
    %w[mongoose helix needle gguf tokenizer].each do |dep|
      resource(dep).stage(buildpath/"../#{dep}")
    end

    system "go", "build", *std_go_args(ldflags: "-s -w"), "-o", bin/"ai", "."

    # Install pre-compiled Metal kernels if on macOS
    %w[gemm_metal4.metallib fused_train.metallib].each do |lib|
      path = buildpath/"../mongoose/kernels/#{lib}"
      ln_sf path, bin/lib if path.exist?
    end
  end

  def caveats
    <<~EOS
      Quick start:
        ai pull Qwen/Qwen2.5-0.5B
        ai chat Qwen2.5-0.5B
        ai train --dim 512 --data corpus.txt

      Models stored in ~/.ai/models/
    EOS
  end

  test do
    assert_match "train", shell_output("#{bin}/ai --help")
  end
end
