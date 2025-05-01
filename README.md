# github-subfolder-to-md 

Simple Bash script to save markdown files from any GitHub repository subfolder and combine them into a single markdown file. Useful for quickly creating markdown documentation context for open-source packages and libraries.

## Installation

```bash
# Install dependencies (macOS)
brew install tree

# Download the script to your home folder
curl -o ~/github-subfolder-to-md.sh https://raw.githubusercontent.com/zueai/github-subfolder-to-md/main/github-subfolder-to-md.sh

# Make it executable
chmod +x ~/github-subfolder-to-md.sh

# Optional: Add to your PATH
echo 'export PATH="$HOME:$PATH"' >> ~/.zshrc  # or ~/.bashrc
source ~/.zshrc  # or source ~/.bashrc
```

## Usage

```bash
~/github-subfolder-to-md.sh https://github.com/username/repo/tree/branch/subfolder-path
```

Example:

```bash
~/github-subfolder-to-md.sh https://github.com/remix-run/react-router/tree/main/docs
```

This creates a combined markdown file named `username-repo-foldername-combined.md` in your current directory.

## Dependencies

- curl
- jq
- unzip
- tree

## License

MIT
