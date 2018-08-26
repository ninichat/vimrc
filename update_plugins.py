try:
    import concurrent.futures as futures
except ImportError:
    try:
        import futures
    except ImportError:
        futures = None

import zipfile
import shutil
import tempfile
import requests

from os import path

#--- Globals ----------------------------------------------
FILE_PLUGINS = """
bufexplorer https://github.com/corntrace/bufexplorer
ctrlp.vim https://github.com/ctrlpvim/ctrlp.vim
mru.vim https://github.com/vim-scripts/mru.vim
nerdtree https://github.com/scrooloose/nerdtree
"""

MOTION_PLUGINS = """
auto-pairs https://github.com/jiangmiao/auto-pairs
comfortable-motion.vim https://github.com/yuttie/comfortable-motion.vim
tabular https://github.com/godlygeek/tabular
vim-commentary https://github.com/tpope/vim-commentary
vim-expand-region https://github.com/terryma/vim-expand-region
vim-indent-object https://github.com/michaeljsmith/vim-indent-object
vim-markdown https://github.com/tpope/vim-markdown
vim-surround https://github.com/tpope/vim-surround
"""

GIT_PLUGINS = """
vim-fugitive https://github.com/tpope/vim-fugitive
vim-gitgutter https://github.com/airblade/vim-gitgutter
"""

INTERFACE_PLUGINS = """
lightline-ale https://github.com/maximbaz/lightline-ale
lightline.vim https://github.com/itchyny/lightline.vim
"""

LANGUAGE_PLUGINS = """
ale https://github.com/w0rp/ale
nginx.vim https://github.com/chr4/nginx.vim
rust.vim https://github.com/rust-lang/rust.vim
vim-flake8 https://github.com/nvie/vim-flake8
vim-go https://github.com/fatih/vim-go
vim-markdown https://github.com/plasticboy/vim-markdown
"""

HELPER_PLUGINS = """
ack.vim https://github.com/mileszs/ack.vim
tlib https://github.com/vim-scripts/tlib
vim-addon-mw-utils https://github.com/MarcWeber/vim-addon-mw-utils
"""

UTILITIES_PLUGINS = """
open_file_under_cursor.vim https://github.com/amix/open_file_under_cursor.vim
snipmate-snippets https://github.com/scrooloose/snipmate-snippets
vim-repeat https://github.com/tpope/vim-repeat
vim-snipmate https://github.com/garbas/vim-snipmate
vim-snippets https://github.com/honza/vim-snippets
vim-yankstack https://github.com/maxbrunsfeld/vim-yankstack
"""

MISC_PLUGINS = """
goyo.vim https://github.com/junegunn/goyo.vim
gruvbox https://github.com/morhetz/gruvbox
vim-zenroom2 https://github.com/amix/vim-zenroom2
"""

PLUGINS = (FILE_PLUGINS +
          MOTION_PLUGINS +
          GIT_PLUGINS +
          INTERFACE_PLUGINS +
          LANGUAGE_PLUGINS +
          HELPER_PLUGINS +
          UTILITIES_PLUGINS +
          MISC_PLUGINS).strip()

GITHUB_ZIP = '%s/archive/master.zip'

SOURCE_DIR = path.join(path.dirname(__file__), 'sources_non_forked')


def download_extract_replace(plugin_name, zip_path, temp_dir, source_dir):
    temp_zip_path = path.join(temp_dir, plugin_name)

    # Download and extract file in temp dir
    req = requests.get(zip_path)
    open(temp_zip_path, 'wb').write(req.content)

    zip_f = zipfile.ZipFile(temp_zip_path)
    zip_f.extractall(temp_dir)

    plugin_temp_path = path.join(temp_dir,
                                 path.join(temp_dir, '%s-master' % plugin_name))

    # Remove the current plugin and replace it with the extracted
    plugin_dest_path = path.join(source_dir, plugin_name)

    try:
        shutil.rmtree(plugin_dest_path)
    except OSError:
        pass

    shutil.move(plugin_temp_path, plugin_dest_path)
    print('Updated {0}'.format(plugin_name))


def update(plugin):
    name, github_url = plugin.split(' ')
    zip_path = GITHUB_ZIP % github_url
    download_extract_replace(name, zip_path,
                             temp_directory, SOURCE_DIR)


if __name__ == '__main__':
    temp_directory = tempfile.mkdtemp()

    try:
        if futures:
            with futures.ThreadPoolExecutor(16) as executor:
                executor.map(update, PLUGINS.splitlines())
        else:
            [update(x) for x in PLUGINS.splitlines()]
    finally:
        shutil.rmtree(temp_directory)
