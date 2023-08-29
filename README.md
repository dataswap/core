# Dataswap

Dataswap is a blockchain-based Layer 2 project built on [IPFS](https://ipfs.tech/) and [Filecoin](https://filecoin.io/), functioning as a decentralized open data exchange platform. Its goal is to aggregate open datasets from various regions and industries globally, enabling the permanent storage of valuable human data. Additionally, Dataswap offers comprehensive and reliable services for data retrieval, downloading, and analysis. Through these efforts, it aims to facilitate data sharing and collaborative progress for humanity.

## Features

Aggregating open big data from various global regions and industries, encompassing economic, financial, medical, and health data types. This creates efficient and valuable gateways to datasets.

Implement a decentralized matching mechanism to attract more open dataset suppliers, storage providers, retrieval providers, compute providers, and users, fostering global data sharing and innovation.

* `Dataswap storage`

  * about [Discussion on Trustless Notary](https://docs.google.com/document/d/1KLR6nZ8ic4ARj3J46XsxSE_b1RpDP_z3JBKL4alHGGw/edit?pli=1) and [Trustless Notary Design Space + Guidelines](https://medium.com/filecoin-plus/ideation-trustless-notary-design-space-guidelines-bc21f6d9d5f2), [Dataswap storage](https://github.com/dataswap/specs/tree/main/systems#22-trustless-notary) has undertaken a more in-depth implementation in this regard.
    * Enabling proof and verification of stored [Valid Data Consistency](https://github.com/dataswap/specs/blob/main/algorithms/README.md#2-dataset-consistency-algorithm).
    * Monitoring client's valid data storage and verification with finer granularity.
    * Simplifying notary work through code.
    * Decoupling data cap and notary signatures to prevent malicious behavior.

  * Utilizing a data authentication mechanism (including data submit, verification, and auditing) to ensure the genuine value of platform data.
  * Utilizing the decentralized automated matching mechanism of DataSwap storage for the permanent storage ([using Filecoin](https://filecoin.io/)) and distribution of datasets, establishing a transparent and publicly accessible distributed data index.

* `Dataswap retrieve`

  * Provide open retrieval and download services. This includes various access methods such as web interfaces, API integration, and file downloads.
    * Customers pay funds into smart contracts to easily search for and access the required datasets.
    * Retrieval service providers receive incentives by offering retrieval services.

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
  * Note:Function parameters and internal functions should begin with an underscore.

* Stick to the idioms and patterns used in the codebase. Familiar-looking code has a higher chance of being accepted than eerie code. Pay attention to commonly used variable and parameter names, avoidance of naked returns, error handling patterns, etc.

* Minimize code churn. Modify only what is strictly necessary. Well-encapsulated changesets will get a quicker response from maintainers.

* Lint your code with [CI check](https://github.com/dataswap/core/blob/main/.github/workflows/test.yml) (CI will reject your PR if unlinted).

* **Add [tests](./test/v0.8/Readme.md),It's very important.**
  * If you have added a new feature or changed interface，you need add [assertions](./test/v0.8/assertions).
  * If your tests are complex and require reuse, you may need to add [helpers](./test/v0.8/helpers/).
  * Ensure your [testcases](./test/v0.8/testcases/) provide comprehensive coverage, considering both normal and exceptional scenarios.
  * Add [unittest](./test/v0.8/uinttests/) or [integrationtest](./test/v0.8/integrationtest/) instance.

* Title the PR in a meaningful way and describe the rationale and the thought process in the PR description.

* Write clean, thoughtful, and detailed [commit messages](https://chris.beams.io/posts/git-commit/). This is even more important than the PR description, because commit messages are stored _inside_ the Git history. One good rule is: if you are happy posting the commit message as the PR description, then it's a good commit message.

## License

This project is licensed under [GPL-3.0-or-later](https://www.gnu.org/licenses/gpl-3.0.en.html).
