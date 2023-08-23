# Dataswap

Dataswap is a blockchain-based Layer 2 project built on [IPFS](https://ipfs.tech/) and [Filecoin](https://filecoin.io/), functioning as a decentralized open data exchange platform. Its goal is to aggregate open datasets from various regions and industries globally, enabling the permanent storage of valuable human data. Additionally, Dataswap offers comprehensive and reliable services for data retrieval, downloading, and analysis. Through these efforts, it aims to facilitate data sharing and collaborative progress for humanity.

## Features

Aggregating open big data from various global regions and industries, encompassing economic, financial, medical, and health data types. This creates efficient and valuable gateways to datasets.

Implementing a decentralized matching mechanism to attract more suppliers of open datasets, storage providers, and users, fostering worldwide data sharing and innovation.

* `Dataswap storage`

  * [Dataswap storage](https://github.com/dataswap/specs/tree/main/systems#22-trustless-notary)  fully satisfies the specific design requirements of [Ideation: Trustless Notary Design Space + Guidelines](https://medium.com/filecoin-plus/ideation-trustless-notary-design-space-guidelines-bc21f6d9d5f2).

  * Utilizing a data authentication mechanism (including data submit, verification, and auditing) to ensure the genuine value of platform data.

  * Leveraging blockchain technology for permanent storage ([using Filecoin](https://filecoin.io/)) and distribution of datasets, establishing a transparent and publicly accessible distributed data index.

* `Dataswap retrieve`

  * Offering open retrieval and download services, enabling users to effortlessly search for and obtain the datasets they need. This encompasses diverse access methods, such as web interfaces, API integrations, and file downloads.

* `Dataswap compute`

  * Providing decentralized data analysis and matching services, empowering data-driven decision-making and intelligent solutions.


## Documentation

For more details about Dataswap, check out the [Dataswap Spec](https://github.com/dataswap/specs).

## Installation

```shell
To be added
```

## Usage

```shell
To be added
```

## Development

### Clone the repository

```shell
git clone https://github.com/dataswap/core.git
cd core/
```

### dependencies

```shell
forge install
yarn install
```

### Build

```shell
forge build

or 

yarn hardhat compile
```

### Test

```shell
forge test

and

yarn hardhat test
```

### Gas Snapshots

```shell
forge snapshot
```

### Cast

```shell
To be added
```

## Contribute

Dataswap is a universally open project and welcomes contributions of all kinds: code, docs, and more. However, before making a contribution, we ask you to heed these recommendations:

* If the change is complex and requires prior discussion, [open an issue](https://github.com/dataswap/core/issues). This is to avoid disappointment and sunk costs, in case the change is not actually needed or accepted.

* Please refrain from submitting [PRs](https://github.com/dataswap/core/pulls) to adapt existing code to subjective preferences. The changeset should contain functional or technical improvements/enhancements, bug fixes, new features, or some other clear material contribution. Simple stylistic changes are likely to be rejected in order to reduce code churn.

When implementing a change:

* Adhere to the standard [Solidity Style Guide](https://docs.soliditylang.org/en/develop/style-guide.html)

* Stick to the idioms and patterns used in the codebase. Familiar-looking code has a higher chance of being accepted than eerie code. Pay attention to commonly used variable and parameter names, avoidance of naked returns, error handling patterns, etc.

* Minimize code churn. Modify only what is strictly necessary. Well-encapsulated changesets will get a quicker response from maintainers.

* Lint your code with [CI check](https://github.com/dataswap/core/blob/main/.github/workflows/test.yml) (CI will reject your PR if unlinted).

* Add tests.

* Title the PR in a meaningful way and describe the rationale and the thought process in the PR description.

* Write clean, thoughtful, and detailed [commit messages](https://chris.beams.io/posts/git-commit/). This is even more important than the PR description, because commit messages are stored _inside_ the Git history. One good rule is: if you are happy posting the commit message as the PR description, then it's a good commit message.

## License

This project is licensed under [GPL-3.0-or-later](https://www.gnu.org/licenses/gpl-3.0.en.html).
