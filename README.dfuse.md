## dfuse Fork of `EOSIO` (`nodeos` client)

This is our private instrumented fork of [eosio/eos](https://github.com/eosio/eos) repository. In this README, you will find instructions about how to work with this repository, which uses submodules and for
which we also have a private submodule for one of the dependencies

### Initialization

The tooling and other instructions expect the following project
structure, it's easier to work with the dfuse fork when you use
the same names and settings.

    cd ~/work
    git clone --branch="deep-mind" --recursive git@github.com:eoscanada/eosio-eos-private.git
    cd eosio-eos-private

    git remote rename origin eoscanada-private
    git remote add origin https://github.com/EOSIO/eos
    git fetch origin

    cd libraries/fc
    git checkout deep-mind
    git remote rename origin eoscanada-private
    git remote add origin https://github.com/EOSIO/FC
    git fetch origin

This will clone our own fork as well as initializing submodules. Ensure that you are
on a dfuse branch (one ending with `-deep-mind`) so that initial submodule fetching is
performed on our own branch which point to our private fork of `libraries/FC` submodule.

##### Assumptions

For the best result when working with this repository and the scripts it contains:

- The remote `eoscanada-private` exists on main module and points to `git@github.com:eoscanada/eosio-eos-private.git`
- The remote `origin` exists on main module and points to `https://github.com/EOSIO/eos`
- The remote `eoscanada-private` exists on `libraries/fc` submodule and points to `git@github.com:eoscanada/eosio-fc-private.git`
- The remote `origin` exists on main module and points to `https://github.com/EOSIO/FC`

### Development

All the development should happen in the `deep-mind` branch, this is our own branch
containing our commits.

When a new version of `EOSIO` is available, we merge the commits (using the release tag)
into the `deep-mind` branch so we have the latest code. The older deep mind code on the
previous release is tagged with `v<X>-dm-v<Y>` where `X` is the EOSIO release version
and `Y` the deep mind version.

#### Building

##### Locally

Simply use the `build_debug.sh` script that can be found at the
root of the project to build the `nodeos` process (and all other
tools) in debug mode.

    ./build_debug.sh

This will install the necessary dependencies as well as installing some
local version of some critical EOSIO dependencies mainly `clang8` and
`boost`. Those two are compiled from source.

This means the first time you run the script, it might take around
1 hour to install and compile dependencies. In this period, your CPU
will often be maxed out at 100% utilization rate, that's normal.

**Important** You are doing active development? Use `./build_debug.sh` only
once, to properly configure your environment or when updating to a new
upstream version. Always re-running `./build_debug.sh` does not re-use existing
compiled objects, which greatly speed up the feedback loop when doing active
development. Instead, use `cd build && make`.

##### Using Docker

TBC

### Update to New Upstream Version

We assume you are in the top directory of the repository when performing the following
operations. Here, we outline the rough idea. Extra details and command lines to use
will be completed later if missing.

We are using `v1.8.7` as the example release tag that we want to update to, assuming
`v1.8.5` was the previous latest merged tag and deep mind version is `10.2`. Change
those with your own values.

Let's first pull latest changes:

    git checkout deep-mind
    git pull -p

    cd libraries/fc
    git checkout deep-mind
    git pull -p

You first fetch the origin repository new data from Git:

    git fetch origin -p
    cd libraries/fc
    git fetch origin -p
    cd ../..

Once fetched, go back to top level and checkout the tag you want to update to
and update submodule once merge has been performed (even if there is conflicts!):

    git merge v1.8.7
    git submodule update --init --recursive

This might generates conflicts in the main module as well as will the
`libraries/fc` module directly.

If you encounter a conflicts with `libraries/fc`, here how to **correctly**
solve it.

The idea is reset to current version (which will be a commit in `deep-mind`),
note the commit from the merged branch (`v1.8.7`), then merge that commit inside
our own fork of `libraries/fc`.

    git ls-tree v1.8.7 libraries/fc | grep -Eo '[0-9a-f]{40}'
    # Note the previous commit that is outputted by command above

    cd libraries/fc
    git checkout deep-mind
    git merge <noted commit id above>
    git submodule update --init --recursive

    # Resolves any conflicts that have happened here
    git commit

    cd ../..
    git add libraries/fc

By doing this, you ensure that you own fork has the same set of changes in
the `libraries/fc` module as above.

Got any other `libraries/*` submodule problem? Simply reset them to the
commit id pointed by the merged version. We do not modify those, so assuming
git complains about `libraries/chainbase`, the operations to perform are:

    git ls-tree v1.8.7 libraries/chainbase | grep -Eo '[0-9a-f]{40}'
    # Note the previous commit that is outputted by command above

    cd libraries/chainbase
    git checkout <noted commit id above>
    cd ../..

    git add libraries/chainbase

You can then continue solving other conflicts from the main module as usual.
Once all conflicts have been resolved, build the version following the `Building`
step below, once satisfied:

    git commit
    git push eoscanada-private deep-mind v1.8.7

    cd libraries/fc
    git push eoscanada-private deep-mind

#### Release

Once you are satisfied, you can tag the repository for later building with
the script

    ./tag_release.sh 1.8.7

This will create and push tag `v1.8.7-dm-v10.2`. Note that if you pass a second argument,
it overrides the default deep mind revision stored in the script

    ./tag_release.sh 1.8.7 v10.2-hotfix

Would create and push tag `v1.8.7-dm-v10.2-hotfix`.

### View only our commits

**Important** To correctly work, you need to use the right base branch, otherwise, it will be screwed up.

* From `gitk`: `gitk --no-merges --first-parent v1.8.7..deep-mind`
* From terminal: `git log --decorate --pretty=oneline --abbrev-commit --no-merges --first-parent v1.8.7..deep-mind`
* From `GitHub`: [https://github.com/eoscanada/eosio-eos-private/compare/v1.8.7...deep-mind](https://github.com/eoscanada/go-ethereum-private/compare/v1.8.7...deep-mind)

* Modified files in our fork: `git diff --submodule=log --name-status v1.8.7..deep-mind | grep -E "^M" | cut -d $'\t' -f 2`
