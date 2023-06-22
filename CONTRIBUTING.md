# CONTRIBUTING

## Releasing

To release a new version of the `flappi` gem follow this checklist:

 1. Merge your branch (feature or bugfix) into `master`:

    ```sh
    git checkout master
    git merge my_branch
    ```

 2. Bump the version (e.g. to `0.12.0`) using [semantic versioning](https://semver.org)

    ```sh
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
