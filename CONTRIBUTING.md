# Contributing

👍🎉 First off, thanks for taking the time to contribute! 🎉👍

When contributing to this repository, please first discuss the change you wish to make via issue, email, or any other method with the owners of this repository before making a change.
Please note we have a [code of conduct](https://github.com/dataswap/core/blob/main/.github/CODE_OF_CONDUCT.md), please follow it in all your interactions with the project.

## Table of Contents

- [Contributing](#contributing)
  - [Table of Contents](#table-of-contents)
  - [Setting Up the project locally](#setting-up-the-project-locally)
  - [Git Commit](#git-commit)
  - [Submitting a Pull Request](#submitting-a-pull-request)

## Setting Up the project locally

To install the project you need to have `node` and `npm`

1.  [Fork](https://help.github.com/articles/fork-a-repo/) the project, clone
    your fork:

    ```sh
    # Clone your fork
    git clone https://github.com/<your-username>/core.git

    # Navigate to the newly cloned directory
    cd core
    ```

2.  Your environment needs to be running `node` version >= 18.17.0 and `npm` version >= 10.2.0.

3.  from the root of the project: `npm` to install all dependencies

    - make sure you have latest `npm` version

4.  from the root of the project: `npm run build` to build.

5.  Your local test environment need to be setted refer to  [.evn.example](https://github.com/dataswap/core/blob/main/.env.example),
    - copy [.evn.example](https://github.com/dataswap/core/blob/main/.env.example) to .env in root directory.
    - modify the environment meet to your own test evnironment.

## Git Commit
Pleas use `npm run commit`

## Submitting a Pull Request

Please go through existing issues and pull requests to check if somebody else is already working on it.

Also, make sure to run the tests and lint the code before you commit your
changes.

```sh
npm run test
```