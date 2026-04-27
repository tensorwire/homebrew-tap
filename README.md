# open-ai.org Homebrew Tap

> **This project has moved to [github.com/tensorwire/homebrew-tap](https://github.com/tensorwire/homebrew-tap).** Updates will be published under [github.com/tensorwire](https://github.com/tensorwire). Code remaining in open-ai-org is unmaintained.

```bash
brew tap open-ai-org/tap
```

## Packages

### ai — GPU-Accelerated ML CLI

```bash
brew install open-ai-org/tap/ai
```

Train, infer, quantize, and serve LLMs. Zero Python, one binary. 99 tok/s inference, 608 steps/s training.

```bash
ai pull Qwen/Qwen2.5-0.5B
ai chat Qwen2.5-0.5B
ai serve Qwen2.5-0.5B
```

https://github.com/open-ai-org/ai

### Mongoose — GPU Compute for Go

```bash
brew install open-ai-org/tap/mongoose
```

Cross-platform GPU compute library. CUDA, Metal 4, WebGPU/Vulkan, CPU. Fused graph dispatch for training. Faster than PyTorch.

https://github.com/open-ai-org/mongoose

### Agent Neo — A.I. Recon

```bash
brew install open-ai-org/tap/neo
```

Automated Intelligent Reconnaissance for your infrastructure. You don't need to think about air — it's just there, keeping everything alive. Just like Neo.

https://github.com/open-ai-org/agent-neo
