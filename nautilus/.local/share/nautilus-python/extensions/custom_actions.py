from gi.repository import Nautilus, GObject
import subprocess
import shlex
import os


class CustomActions(GObject.GObject, Nautilus.MenuProvider):
    def _paths_to_open(self, files):
        paths = []
        for file in files:
            location = file.get_location() if file.is_directory() else file.get_parent_location()
            path = location.get_path()
            if path and path not in paths:
                paths.append(path)
        return paths if len(paths) <= 10 else []

    # --- Open in Tmux ---
    def _open_in_tmux(self, _menu, paths):
        for path in paths:
            result = subprocess.run(['tmux', 'list-sessions'], capture_output=True)
            if result.returncode == 0:
                subprocess.Popen(['tmux', 'new-window', '-c', path])
            else:
                subprocess.Popen(['foot', '--working-directory', path, '-e', 'tmux', 'new-session'])

    # --- Open in Terminal ---
    def _open_in_terminal(self, _menu, paths):
        for path in paths:
            subprocess.Popen(['foot', '--working-directory', path, '-e', 'zsh'])

    # --- Copy File Name ---
    def _copy_file_name(self, _menu, files):
        names = [os.path.basename(f.get_location().get_path()) for f in files if f.get_location().get_path()]
        if names:
            subprocess.Popen(['wl-copy', '\n'.join(names)])

    # --- Copy File Path ---
    def _copy_file_path(self, _menu, files):
        paths = [f.get_location().get_path() for f in files if f.get_location().get_path()]
        if paths:
            subprocess.Popen(['wl-copy', '\n'.join(paths)])

    # --- Copy Image to Clipboard ---
    def _copy_image_to_clipboard(self, _menu, files):
        path = files[0].get_location().get_path()
        if path:
            subprocess.Popen(
                f'magick {shlex.quote(path)} png:- | wl-copy --type image/png',
                shell=True,
            )

    def get_file_items(self, *args):
        files = args[0] if len(args) == 1 else args[1]
        if not files:
            return []

        items = []
        paths = self._paths_to_open(files)

        if paths:
            tmux = Nautilus.MenuItem(name='Custom::open_tmux', label='Open in Tmux', icon='utilities-terminal')
            tmux.connect('activate', self._open_in_tmux, paths)
            items.append(tmux)

            terminal = Nautilus.MenuItem(name='Custom::open_terminal', label='Open in Terminal', icon='utilities-terminal')
            terminal.connect('activate', self._open_in_terminal, paths)
            items.append(terminal)

        name_item = Nautilus.MenuItem(name='Custom::copy_name', label='Copy File Name', icon='edit-copy')
        name_item.connect('activate', self._copy_file_name, files)
        items.append(name_item)

        path_item = Nautilus.MenuItem(name='Custom::copy_path', label='Copy File Path', icon='edit-copy')
        path_item.connect('activate', self._copy_file_path, files)
        items.append(path_item)

        if len(files) == 1 and (files[0].get_mime_type() or '').startswith('image/'):
            img_item = Nautilus.MenuItem(name='Custom::copy_image', label='Copy Image to Clipboard', icon='edit-copy')
            img_item.connect('activate', self._copy_image_to_clipboard, files)
            items.append(img_item)

        return items

    def get_background_items(self, *args):
        file = args[0] if len(args) == 1 else args[1]
        paths = self._paths_to_open([file])
        if not paths:
            return []

        tmux = Nautilus.MenuItem(name='Custom::open_tmux_bg', label='Open in Tmux', icon='utilities-terminal')
        tmux.connect('activate', self._open_in_tmux, paths)

        terminal = Nautilus.MenuItem(name='Custom::open_terminal_bg', label='Open in Terminal', icon='utilities-terminal')
        terminal.connect('activate', self._open_in_terminal, paths)

        return [tmux, terminal]
