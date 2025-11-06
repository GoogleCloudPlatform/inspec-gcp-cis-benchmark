FROM cincproject/auditor:7.0.95

RUN apt-get update && \
    apt-get install -y \
    build-essential \
    ruby-dev \
    zlib1g-dev \
    libssl-dev \
    liblzma-dev \
    && rm -rf /var/lib/apt/lists/*

# Install the bundler gem
RUN gem install bundler --no-document

# Install the rubocop gem
RUN gem install rubocop --no-document

# Default command when the container starts (optional, but good for interactive shells)
CMD ["/bin/bash"]