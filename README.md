# sdball's dotfiles

These dotfiles are my home directory.

Seriously. Check out the .gitignore file. Anything look familiar?

## WTF why?

Because it's easy! If *anything* changes or creates a new dotfile or
subdirectory in my home directory it's extremely easy for me to see what
changed and how much.

Before I did this I was always annoyed with scripts and installations that
helpfully modified my files. I'd always forget exactly what was my
configuration and what was generated.

## WTF security?

For sure. Since the entire home directory is inside the git repo you have to be extra double sure that you don't push anything sensitive.

In practice, that means adding lots to the .gitignore file that you don't want to be included as part of the dotfiles repo.

I also maintain a .local_zshrc file on each machine since I invariably have machine specific settings.

## Want!

If you'd like to try this out:

1. `git init` in your home directory
2. `git add .`
3. Loop between `git st` and editing .gitignore until you are satisfied
4. Commit!
4. Push up the repo wherever: or just maintain a local git repo if you only have one machine.

### Second, etc. machines with dotfiles you DON'T care about

1. `git init` the home directory
2. `git remote add origin path/to/repo` OR `git remote add readonly path/to/readonly`
3. `git fetch origin` (or `git fetch readonly`)
4. `git reset --hard origin/master` (or `git reset --hard readonly/master`)

I use "readonly" when I'm on a machine just I just want to configure.

### Second, etc. machines with dotfiles you DO care about

Basically: setup the repo, create a branch for the machine, commit the
dotfiles, pull down the "master" dotfiles, and merge them with the local
dotfiles.

1. `git init` the home directory.
2. `git co -b machine-name`
3. Do the `git st` and .gitignore loop.
4. Commit!
5. `git co master`
6. `git remote add origin path/to/repo`
7. `git fetch origin`
8. `git reset --hard origin/master`
9. `git co machine-name`
10. `git rebase master`
11. Fix any conflicts.
12. `git co master`
13. `git merge --no-ff machine-name`

