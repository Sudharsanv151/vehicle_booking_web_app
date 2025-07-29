# syntax = docker/dockerfile:1

# === Base image with Ruby ===
ARG RUBY_VERSION=3.4.1
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim AS base

# Set working directory
WORKDIR /rails

# Set environment variables
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development test"

# === Build Stage ===
FROM base AS build

# Install required packages for gem compilation
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libvips pkg-config nodejs yarn && \
    rm -rf /var/lib/apt/lists/*

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy the application code
COPY . .

# Precompile bootsnap cache for faster boot
RUN bundle exec bootsnap precompile app/ lib/

# === Precompile assets using real master key ===
ARG RAILS_MASTER_KEY
ENV RAILS_MASTER_KEY=$RAILS_MASTER_KEY
RUN ./bin/rails assets:precompile

# === Final Stage ===
FROM base

# Install minimal runtime packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libvips postgresql-client && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives

# Copy built gems & application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Set permissions & create non-root user
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

# Entrypoint
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Expose port
EXPOSE 3000

# Start Rails server by default
CMD ["./bin/rails", "server"]
