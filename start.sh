#!/usr/bin/env bash

set -e

# Initialize rbenv if installed
if command -v rbenv >/dev/null 2>&1; then
    eval "$(rbenv init -)"
    
    # Read the required Ruby version from .ruby-version
    if [ -f .ruby-version ]; then
        REQUIRED_RUBY=$(cat .ruby-version)
        echo "> Ensuring Ruby $REQUIRED_RUBY is installed..."
        rbenv install -s
    fi
fi

# Make sure bundler is installed for this Ruby instance
if ! command -v bundle >/dev/null 2>&1; then
    echo "> Installing Bundler..."
    gem install bundler
fi

# Install dependencies 
echo "> Ensuring dependencies are installed..."
bundle install

# Start the server
echo "> Starting local server..."
bash tools/run.sh "$@"
