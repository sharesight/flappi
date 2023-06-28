# CONTRIBUTING

## Releasing to _testing_

To test one of your `flappi` branches, follow these steps:

 1. Merge your branch `my_branch` (feature or bugfix) into `testing`:

    ```sh
    # in flappi
    git checkout testing
    git merge my_branch
    ```

 2. Update the `testing` branch in _investapp_:

    ```sh
    # in investapp
    git checkout testing
    bundle update flappi --conservative
    git commit -am "Update flappi testing branch"
    git push
    ```

  3. Deploy to _testing_


## Releasing to _production_

To release a new version of the `flappi` gem follow this checklist:

 1. Merge your branch (feature or bugfix) into `master`:

    ```sh
    # in flappi
    git checkout master
    git merge my_branch
    ```

 2. Bump the version (e.g. to `0.12.0`) using [semantic versioning](https://semver.org)

    ```sh
    # in flappi
    vi lib/flappi/version.rb

    # change version and describe your changes
    vi CHANGELOG.md

    git commit -m "Bump version to 0.12.0" -a
    ```

    It is strongly recommended to change version and changelog on release only to avoid merge conflicts during development.

 3. Push your changes

    ```sh
    git push
    ```

 4. Update the gem in the _investapp_

    ```sh
    cd investapp
    bundle update flappi
    # make sure the released version matches
    git commit -m "Update the flappi gem to its latest version 0.12.0" -a
    git push
    ```

 5. Deploy the _investapp_

 6. Merge into testing

    ```sh
    # in investapp
    git checkout testing
    git merge master
    # resolve any conflicts
    # maybe deploy to testing
    ```

## Code of Conduct

See [CODE_OF_CONDUCT](./CODE_OF_CONDUCT.md).
