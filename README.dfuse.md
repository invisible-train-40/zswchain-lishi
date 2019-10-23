### EOSIO dfuse Private Fork

This is our private instrumented fork of [eosio/eos](https://github.com/eosio/eos) repository. In this README, you will
find instructions about how to work with this repository, which uses submodules and for
which we also have a private submodule for one of the dependencies

#### Cloning

    cd ~/work
    git clone git@github.com:eoscanada/eosio-eos-private.git
    cd eosio-eos-private
    git checkout release/1.8.x-deep-mind
    git submodule update --init --recursive

This will clone our own fork as well as initializing submodules. Ensure that you are
on a dfuse branch (one ending with `-deep-mind`) so that initial submodule fetching is
performed on our own branch which point to our private fork of `libraries/FC` submodule.

Ensure you had a remote name `upstream` that points to upstream [eosio/eos](https://github.com/eosio/eos)
repository (**Note** it must be named `upstream`, for included dfuse scripts to work properly):

    git remote add upstream https://github.com/EOSIO/eos
    cd libraries/fc
    git remote add upstream https://github.com/EOSIO/FC

##### Assumptions

For the best result when working with this repository and the scripts it contains:

- The remote `origin` exists on main module and points to `git@github.com:eoscanada/eosio-eos-private.git`
- The remote `upstream` exists on main module and points to `https://github.com/EOSIO/eos`
- The remote `origin` exists on `libraries/fc` submodule and points to `git@github.com:eoscanada/eosio-fc-private.git`
- The remote `upstream` exists on main module and points to `https://github.com/EOSIO/FC`

#### Update to latest version

We assume you are in the top directory of the repository when performing the following
operations.

Here, we outline the rough idea. Extra details and command lines to use will be completed
later if missing.

You first fetch the upstream repository new data from Git:

    git fetch upstream -p
    cd libraries/fc
    git fetch upstream -p
    cd ../..

Once fetched, go back to top level and checkout the tag you want to update to
and update submodule there

    git checkout release/1.8.x-deep-mind
    git merge upstream/v1.8.5

Then, ensure that `libraries/fc` submodule is up to date with the one our
fork

    git checkout v1.8.5
    git submodule update --init --recursive
    git submodule | grep "libraries/fc"
    # Note the commit id that shows above

    git checkout release/1.8.x-deep-mind
    git submodule update --init --recursive
    cd libraries/fc
    git checkout v1.8.x-deep-mind
    git merge <commit id noted above>

    cd ../..
    git add libraries/fc

By doing this, you ensure that you own fork has the same set of changes in
the `libraries/fc` module as above.

You can then build everything to ensure it's working as expected.

#### Building

TBC

#### Tagging

Once you are satisfied, you can tag the repository for later building with
the script

    ./tag_release.sh 1.8.5

This will create and push tag `v1.8.5-dm-v10.2`. Note that if you pass a second argument,
it overrides the default deep mind revision stored in the script

    ./tag_release.sh 1.8.5 v10.2-hotfix

Would create and push tag `v1.8.5-dm-v10.2-hotfix`.

#### Our Changes

On main repository:

    git cherry -v v1.8.5 release/1.8.x-deep-mind

On `libraries/fc` submodule:

    git cherry -v upstream/v1.8.x v1.8.x-deep-mind

**Note** If this reports all sort of commits that are not part of deep mind
commits set, it means the base branch/tag is not the latest one synced with
the deep mind branch. You can always check latest merge commit in deep mind
branch to become aware of latest merge commit.
