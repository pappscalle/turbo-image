## Template usage & submodules

This repository was created from a template.

You are free to update submodules independently.
Doing so will intentionally diverge from the template.


### External dependncies

This project uses external Turbo Pascal Unit (`.tpu`) files, includes via a Git submodule.

The submodule is lcated at `src/external/src/units`

### Creating a new repository from this template

After creating a new repository from this template, clone it **with submodules**:
```
git clone --recurse-submodules git@github.com:pappscalle/my-cloned-repo.git
```
### Initializing or syncing submodules

If the submodule is not downloaded, or if you want to sync to the version pinned to the template:
```
git submodule update --init --recursive
```
### Updating the submodule to the latest version
If you want the newest version of the submodule, you may update it
manually. This will intentionally diverge from the template:
```
git submodule update --remote --merge
git add src/external
git commit -m "Update submodule"
```
