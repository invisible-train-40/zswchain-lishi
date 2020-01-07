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

This will clone our own fork as well as initializing submodules.

##### Assumptions

For the best result when working with this repository and the scripts it contains:

- The remote `eoscanada-private` exists on main module and points to `git@github.com:eoscanada/eosio-eos-private.git`
- The remote `origin` exists on main module and points to `https://github.com/EOSIO/eos`

### Branches & Workflow

Dealing with a big enterprise repository like EOSIO that have multiple
incompatible version (1.7.x, 1.8.x, 2.0.x, etc.) and for which we need
to track multiple forks (`BOS`, `WAX`) pose a branch management challenges.

Even more that we have our own set of patches to enable deep data extraction
for dfuse consumption.

We use merging of the branches into one another to make that work manageable.
The first and foremost important rule is that we always put new development to
deep mind in the `deep-mind` branch.

This branch must always be tracking the lowest supported version of all. Indeed,
this is our "work" branch for our patches, new development must go there. If you
perform our work with newer code, the problem that will arise is that this new
deep mind work will not be mergeable into forks or older release that we still
support!

We then create `release/<identifier>` branch that tracks the version of interest
for us, versions that we will manages and deploy.

Let's take the following information to create an example branch structure:

- We support vanilla EOSIO 1.8.x series, latest update for this branch is 1.8.7.
- We support vanilla EOSIO 2.0.x series, latest update for this branch is 2.0.0.
- We support WAX 1.8.x series, latest update for this is wax-1.8.4 which is based on EOSIO 1.8.4

To manage all this, we have the following set of branches:

- `deep-mind` (based on `v1.8.4` version of EOSIO repository, with all dfuse Deep Mind commits in it)
- `release/1.8.x-dm` (based on `v1.8.7` version EOSIO, with branch `deep-mind` merged in it)
- `release/2.0.x-dm` (based on `v2.0.0` version EOSIO, with branch `deep-mind` merged in it)
- `release/wax-1.8.x-dm` (based on `v1.8.4` of WAX, which is based on `v1.8.4` of EOSIO, `deep-mind` merged in it)

You can see here the problem if `deep-mind` is not on the lowest merged point, when doing new
development, if we try to merge `deep-mind` in `release/wax-1.8.x-dm`, it will pull any EOSIO
changes between 1.8.4 (version used by WAX) and where `deep-mind` is currently at.

#### Making New Deep Mind Changes

Making new Deep Mind changes should be performed on the `deep-mind` branch. When happy
with the changes, simply merge the `deep-mind` branch in all the release branches we track
and support.

    git checkout deep-mind
    git pull -p

    # Perform necessary changes and tests

    git checkout release/1.8.x-dm
    git pull -p
    git merge deep-mind

    git checkout release/2.0.x-dm
    git pull -p
    git merge deep-mind

    git checkout release/wax-1.8.x-dm
    git pull -p
    git merge deep-mind

    git push eoscanada-private deep-mind release/1.8.x-dm release/2.0.x-dm release/wax-1.8.x-dm

### Update to New Upstream Version (EOSIO)

We assume you are in the top directory of the repository when performing the following
operations. Here, we outline the rough idea. Extra details and command lines to use
will be completed later if missing.

We are using `v1.8.7` as the example release tag that we want to update to, assuming
`v1.8.5` was the previous latest merged tag and deep mind version is `10.2`. Change
those with your own values.

First step is to checkout the release branch of the series you are currently
updating to:

    git checkout release/1.8.x-dm
    git pull -p

You first fetch the origin repository new data from Git:

    git fetch origin -p

Once fetched, go back to top level and checkout the tag you want to update to
and update submodule:

    git merge v1.8.7
    git submodule update --init --recursive

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
section, once satisfied:

    git commit
    git push eoscanada-private release/1.8.x-dm v1.8.7

### Development

All the development should happen in the `deep-mind` branch, this is our own branch
containing our commits.

When a new version of `EOSIO` is available, we merge the commits (using the release tag)
into the `deep-mind` branch so we have the latest code. The older deep mind code on the
previous release is tagged with `v<X>-dm-v<Y>` where `X` is the EOSIO release version
and `Y` the deep mind version.

#### Building

##### Locally

On first build, you should call the `./configure_project.sh` script to
install requires dependencies and configure the project.

    ./configure_project.sh

**Note** Only call this if you you have a fresh clone of upgrading
between feature/major versions as this will force a re-compilation of
everything. In most cases, you should configure only once and then
use `make -jX` while inside the `build` folder, see below

**Tips** Are you going to work on multiple spanning version like 1.8.x
and 2.0.x? Use `BUILD_DIR_SUFFIX=1.8.x ./configure_project.sh` to create
a different build directory for each branch.

This will install the necessary dependencies as well as installing some
local version of some critical EOSIO dependencies mainly `clang8` and
`boost`. Those two are compiled from source.

This means the first time you run the script, it might take around
1 hour to install and compile dependencies. In this period, your CPU
will often be maxed out at 100% utilization rate, that's normal.

The dependencies are installed and the project is configured, next step
is to invoke the compilation step.

For this, simply go in the `build` directory and then call `max -jX` where
X is the amount of cores that you want to dedicate to compilation. On my
machine which have 8 virtual cores, I use 6 so I have some room for other
tasks.

**Tips** Want to speed compilation a bit by skipping not required targets
like tests? Use `make nodeos -jX` instead to build only `nodeos` binary.

##### Using Docker

TBC

#### Release

Once you are satisfied, you can tag the repository for later building with
the script

    ./release_tag.sh 1.8.7

This will create and push tag `v1.8.7-dm-v10.2`. Note that if you pass a second argument,
it overrides the default deep mind revision stored in the script

    ./release_tag.sh 1.8.7 v10.2-hotfix

Would create and push tag `v1.8.7-dm-v10.2-hotfix`.

### View only our commits

**Important** To correctly work, you need to use the right base branch, otherwise, it will be screwed up. The `deep-mind`
branch was based on `v1.8.5` at time of writing.

* From `gitk`: `gitk --no-merges --first-parent v1.8.5..deep-mind`
* From terminal: `git log --decorate --pretty=oneline --abbrev-commit --no-merges --first-parent v1.8.5..deep-mind`
* From `GitHub`: [https://github.com/eoscanada/eosio-eos-private/compare/v1.8.5...deep-mind](https://github.com/eoscanada/go-ethereum-private/compare/v1.8.5...deep-mind)

* Modified files in our fork: `git diff --submodule=log --name-status v1.8.5..deep-mind | grep -E "^M" | cut -d $'\t' -f 2`
