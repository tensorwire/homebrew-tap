class Ai < Formula
  desc "GPU-accelerated ML CLI — train, infer, quantize, serve LLMs"
  homepage "https://github.com/open-ai-org/ai"
  url "https://github.com/open-ai-org/ai/archive/refs/tags/v1.3.0.tar.gz"
  sha256 ""
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

    # Install Metal kernels (macOS only)
    if OS.mac?
      kernels_dir = buildpath/"../mongoose/kernels"

      # Use pre-compiled metallibs from the repo
      %w[gemm_metal4.metallib fused_train.metallib infer.metallib].each do |lib|
        prebuilt = kernels_dir/lib
        if prebuilt.exist?
          cp prebuilt, bin/lib
        else
          # Compile from source as fallback
          source = kernels_dir/lib.sub(".metallib", ".metal")
          if source.exist?
            air = kernels_dir/lib.sub(".metallib", ".air")
            system "xcrun", "metal", "-std=metal4.0", "-O2", "-c", source, "-o", air
            system "xcrun", "metallib", "-o", bin/lib, air
          end
        end
      end
    end
  end

  def caveats
    <<~EOS
      Quick start:
        ai train data=corpus.txt
        ai pull Qwen/Qwen2.5-0.5B
        ai chat Qwen2.5-0.5B

      Models stored in ~/.ai/models/
    EOS
  end

  test do
    assert_match "train", shell_output("#{bin}/ai --help")
    assert_match "v1.3.0", shell_output("#{bin}/ai --version")
  end
end
