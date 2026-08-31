#!/usr/bin/env python3
import os
import sys

extensions = (
    '.sh', '.py', '.js', '.ts', '.vue', '.json', '.md', '.txt',
    '.desktop', '.conf', '.rules', '.service', '.list', '.yml', '.yaml',
    '.css', '.html', '.directory', '.menu', '.ini', '.lua', '.example'
)
special_names = {'build-iso.sh', 'build-wsl.sh', 'check_urls.sh', 'LICENSE', 'Dockerfile', '.gitignore', '.gitattributes'}

base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
count = 0

for root, dirs, files in os.walk(base_dir):
    # skip .git, node_modules, dist, .output, and worktrees
    dirs[:] = [d for d in dirs if d not in ('.git', 'node_modules', '.output', 'dist', '.nuxt')]
    for f in files:
        if f.endswith(extensions) or f in special_names:
            p = os.path.join(root, f)
            try:
                with open(p, 'rb') as fp:
                    content = fp.read()
                if b'\r\n' in content:
                    content = content.replace(b'\r\n', b'\n')
                    with open(p, 'wb') as fp:
                        fp.write(content)
                    count += 1
            except Exception as e:
                print(f"Error {p}: {e}", file=sys.stderr)

print(f"Successfully converted {count} files to LF line endings.")
