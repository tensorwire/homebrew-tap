class Ai < Formula
  desc "GPU-accelerated ML CLI — train, infer, quantize, serve LLMs"
  homepage "https://github.com/tensorwire/ai"
  url "https://github.com/tensorwire/ai/archive/refs/tags/v1.5.2.tar.gz"
  sha256 "f7bc049df2b3d098f76ed1b9124077d3f7c332346c50fbf14ed48e800826060a"
  license "Apache-2.0"
  head "https://github.com/tensorwire/ai.git", branch: "main"

  depends_on "go" => :build

  resource "mongoose" do
    url "https://github.com/tensorwire/mongoose.git", branch: "main", using: :git
  end

  def install
    resource("mongoose").stage(buildpath/"../mongoose")

    system "go", "build", *std_go_args(ldflags: "-s -w"), "-o", bin/"ai", "."

    if OS.mac?
      kernels_dir = buildpath/"../mongoose/kernels"

      %w[gemm_metal4.metallib fused_train.metallib infer.metallib].each do |lib|
        prebuilt = kernels_dir/lib
        if prebuilt.exist?
          cp prebuilt, bin/lib
        else
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
  end
end
