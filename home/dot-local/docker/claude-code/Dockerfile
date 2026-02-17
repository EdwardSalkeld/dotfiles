FROM debian:trixie-slim

RUN apt-get update && apt-get install -y git curl sudo gh && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash claude && echo "claude ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/claude

USER claude
RUN curl -fsSL https://claude.ai/install.sh | bash

ENV PATH="/home/claude/.local/bin:$PATH"

ENTRYPOINT ["/home/claude/.local/bin/claude"]
