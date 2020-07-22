# K8s-Vagrant: Contribute

Thanks for considering a contribution to this repo!

## Spell Checking

To keep things simple and prevent silly errors, you can set up your local git
repo with hooks for spellchecking using a very-slightly modified
[git-spell-check](https://github.com/mprpic/git-spell-check), copied to this
directory.

```sh
# ensure this is executable
ln -s contribute/pre-commit .git/hooks/
```

For this script to work, you'll need to install the following packages (or equivalent
packages for your distro):

```text
aspell
aspell-en
```

Once configured, each time you commit a change to `./labs/`, your contribution
will be spell-checked locally, with a custom dictionary of words you approve saved
to `~/.git-spell-check`.

## TODOs

Want something to do, but don't know where to start? For now, I'm keeping stuff
in [TODO](TODO.md).

