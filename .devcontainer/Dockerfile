FROM ruby:3.4.3

# Install Node.js 20.x for React development
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Install system dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libsqlite3-dev \
    git \
    vim \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install specific Rails version
RUN gem install rails -v 8.0.2

# Install bundler
RUN gem install bundler

# Set working directory
WORKDIR /workspace

# Configure git to trust the workspace directory
RUN git config --global --add safe.directory /workspace
