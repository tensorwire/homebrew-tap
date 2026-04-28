class Ai < Formula
  desc "GPU-accelerated ML CLI — train, infer, quantize, serve LLMs"
  homepage "https://github.com/tensorwire/ai"
  url "https://github.com/tensorwire/ai/archive/refs/tags/v1.5.0.tar.gz"
  sha256 "0777521d1bd57b5d95ed09bf654bb91b236290e508af42df45660a5f1e83bf02"
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
