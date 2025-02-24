# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t app .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name app app

# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.2.7
FROM ruby:3.2.7-slim AS base

# 必要なパッケージをインストール（libyaml-devを追加）
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    curl \
    git \
    libpq-dev \
    postgresql-client \
    nodejs \
    npm \
    libyaml-dev && \
    npm install -g yarn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 作業ディレクトリを設定
WORKDIR /rails

# Gemfileをコピーして依存関係をインストール
COPY Gemfile Gemfile.lock ./
RUN bundle install

# アプリケーションのソースをコピー
COPY . .

# 本番環境用の設定
ENV RAILS_ENV=production \
    RAILS_SERVE_STATIC_FILES=true

# アセットのプリコンパイル
RUN SECRET_KEY_BASE=dummy bundle exec rails assets:precompile

# ポート3000を公開
EXPOSE 3000

# Railsサーバーを起動
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
