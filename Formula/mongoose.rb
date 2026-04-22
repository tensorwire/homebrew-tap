class Mongoose < Formula
  desc "GPU compute library for Go — CUDA, Metal, WebGPU, CPU"
  homepage "https://github.com/open-ai-org/mongoose"
  url "https://github.com/open-ai-org/mongoose/archive/v0.1.0.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "MIT"
  head "https://github.com/open-ai-org/mongoose.git", branch: "main"

  depends_on "go" => :build
  depends_on xcode: :build  # for Metal/Swift

  def install
    # Install Go library source (for `go get` users this is redundant,
    # but having it in Cellar helps with discoverability)
    libexec.install Dir["*.go"]
    libexec.install "go.mod", "go.sum"

    # Build Metal binary on macOS
    if OS.mac?
      cd "metal" do
        system "swiftc", "-O",
               "-o", "mongoose-metal",
               "mongoose_metal.swift",
               "-framework", "Metal",
               "-framework", "MetalPerformanceShaders"
        bin.install "mongoose-metal"
      end
    end

    # Install CUDA kernel source (user compiles with nvcc if they have it)
    (share/"mongoose/kernels").install "kernels/mongoose.cu"
    (share/"mongoose/kernels").install "kernels/Makefile"

    # Install docs
    doc.install "README.md", "INSTALL.md"
  end

  def caveats
    <<~EOS
      Mongoose is a Go library. To use it in your project:

        go get github.com/open-ai-org/mongoose

      The Metal GPU binary has been installed to:
        #{bin}/mongoose-metal

      For NVIDIA CUDA support, compile the kernels:
        cd #{share}/mongoose/kernels && make

      Benchmark your GPU:
        echo -ne '\\x04' | mongoose-metal
    EOS
  end

  test do
    if OS.mac?
      assert_predicate bin/"mongoose-metal", :exist?
    end
  end
end
