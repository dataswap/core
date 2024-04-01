

## [0.9.4](https://github.com/dataswap/core/compare/v0.9.3...v0.9.4) (2024-04-01)


### Bug Fixes

* 🐛 update _getSecureDatasetChallengePoints ([d7ed60f](https://github.com/dataswap/core/commit/d7ed60f325d060522328eb3b5d44be4fad152128)), closes [#375](https://github.com/dataswap/core/issues/375)

## [0.9.3](https://github.com/dataswap/core/compare/v0.9.2...v0.9.3) (2024-04-01)


### Bug Fixes

* 🐛 “Challenge proof" logical organization submission ([3301a38](https://github.com/dataswap/core/commit/3301a38ee6dce527e9cda3716ab07387354771a2)), closes [#350](https://github.com/dataswap/core/issues/350)
* 🐛 Fixed piece size error ([c4f9359](https://github.com/dataswap/core/commit/c4f935947b853d6a1a66450abb4b5444b8abc158)), closes [#371](https://github.com/dataswap/core/issues/371)
* 🐛 remove import of SendAPI from matchingBids ([b394a27](https://github.com/dataswap/core/commit/b394a2743e69a3a6f7e982df50cf73f4c52118b1))
* 🐛 Remove the vendor directory and use the original version ([f90a9fe](https://github.com/dataswap/core/commit/f90a9fe6dde4c75c7f2dd8e3661b2837158b3bd2)), closes [#367](https://github.com/dataswap/core/issues/367)
* 🐛 requestAllocateDatacap check if matched ([47bc2db](https://github.com/dataswap/core/commit/47bc2db8963624b54ac173b4f2f2e803d7e6cbbf)), closes [#363](https://github.com/dataswap/core/issues/363)
* 🐛 Resolving the issue of incorrect CID length ([d16ce2d](https://github.com/dataswap/core/commit/d16ce2dc5b8646c40ffa0aae4ee517add000987c)), closes [#366](https://github.com/dataswap/core/issues/366)

## [0.9.2](https://github.com/dataswap/core/compare/v0.9.1...v0.9.2) (2024-03-26)


### Bug Fixes

* 🐛 change isWinner to view ([24dc9da](https://github.com/dataswap/core/commit/24dc9dafaf0023fcde2576a9e513b255167c2889)), closes [#361](https://github.com/dataswap/core/issues/361)
* 🐛 fix statistics events ([fcad941](https://github.com/dataswap/core/commit/fcad94124d6a4ba5c31442ea1224d36949d8e9b6)), closes [#359](https://github.com/dataswap/core/issues/359)

## [0.9.1](https://github.com/dataswap/core/compare/v0.9.0...v0.9.1) (2024-03-25)


### Bug Fixes

* 🐛 add func getDatasetProofRootHash ([012b05a](https://github.com/dataswap/core/commit/012b05ad4797a93ab7d82f5db972ff3aaf962c03)), closes [#354](https://github.com/dataswap/core/issues/354)
* 🐛 merge count and size statistics ([8d85490](https://github.com/dataswap/core/commit/8d85490150065d5a9005f422bf8e9f5d6edff680)), closes [#356](https://github.com/dataswap/core/issues/356)

# [0.9.0](https://github.com/dataswap/core/compare/v0.8.0...v0.9.0) (2024-03-22)


### Bug Fixes

* 🐛 add filecoin-solidity-api v1.1.1 ([cb71eaa](https://github.com/dataswap/core/commit/cb71eaabcc449a934cde1e9c2843f848566827d5))
* 🐛 Add lock version file ([01b3e51](https://github.com/dataswap/core/commit/01b3e51f509b016781bdd737722228e90b68c773)), closes [#346](https://github.com/dataswap/core/issues/346)
* 🐛 compile and deserializeGetClaimsReturn failure ([b710380](https://github.com/dataswap/core/commit/b710380db9502885e424e25e442d94d3f3560c72))
* 🐛 getReplicaClaimData failure ([bc56b11](https://github.com/dataswap/core/commit/bc56b1155e44154736979275eb98484db03afd6d)), closes [#329](https://github.com/dataswap/core/issues/329)
* 🐛 Improve the configuration of the deployment tool ([c949a0e](https://github.com/dataswap/core/commit/c949a0e9f21f471925d8bdf6b76429365d2a74d7)), closes [#341](https://github.com/dataswap/core/issues/341)
* 🐛 remove getChallengeAuditCollateralRequirement ([7d4bc90](https://github.com/dataswap/core/commit/7d4bc9025c8643bb59403b2cfa7bf54dfafed36f)), closes [#349](https://github.com/dataswap/core/issues/349)
* 🐛 remove zondex  filecoin-solidity ([6833787](https://github.com/dataswap/core/commit/6833787e4370038afb015100a37deff34623b23d))
* 🐛 renaming of filplus rules ([446b9fd](https://github.com/dataswap/core/commit/446b9fd6e8798e8c9d618c03b673a675753a71de)), closes [#351](https://github.com/dataswap/core/issues/351)


### Features

* 🎸 add statistics events ([d0e08dc](https://github.com/dataswap/core/commit/d0e08dc6b7ea90978104282f36e2926516e34b43)), closes [#344](https://github.com/dataswap/core/issues/344)

# [0.8.0](https://github.com/dataswap/core/compare/v0.7.0...v0.8.0) (2024-03-15)


### Bug Fixes

* 🐛 Finance Subsidy requirement error ([0146215](https://github.com/dataswap/core/commit/0146215c418417da5659a2c6488c7739487ef97c)), closes [#326](https://github.com/dataswap/core/issues/326)
* 🐛 optimize the state variables in the 'roles' contract ([c1613f4](https://github.com/dataswap/core/commit/c1613f4a507cc0ca08db914cfd51e7aab286722b)), closes [#330](https://github.com/dataswap/core/issues/330)


### Features

* 🎸 design dataset auditors election ([c494037](https://github.com/dataswap/core/commit/c4940379f518d0cf6b22940d269874329030c5e7)), closes [#253](https://github.com/dataswap/core/issues/253)
* 🎸 Handling of the addCanceled function in the Storages ([008abe4](https://github.com/dataswap/core/commit/008abe4a807ffc89f17e99bc4dc28901cf577be7)), closes [#218](https://github.com/dataswap/core/issues/218)
* 🎸 impl dataset auditor election ([7512a6b](https://github.com/dataswap/core/commit/7512a6b728493aaf8e50b49751244f7d39d22188)), closes [#337](https://github.com/dataswap/core/issues/337)

# [0.7.0](https://github.com/dataswap/core/compare/v0.6.0...v0.7.0) (2024-03-11)


### Bug Fixes

* 🐛 Fix contract upgrade issue ([ddd03ce](https://github.com/dataswap/core/commit/ddd03ceebfe77755a0a44cd6d7a67069024a13fc)), closes [#327](https://github.com/dataswap/core/issues/327)
* 🐛 fix matching storage statistics ([d79364b](https://github.com/dataswap/core/commit/d79364b5e276fb8d26c914d41190adbc578345e0)), closes [#331](https://github.com/dataswap/core/issues/331)


### Features

* 🎸 add setRoles to filecoin contract ([18a0f8c](https://github.com/dataswap/core/commit/18a0f8cd9f49f1cdaec8a7b25216362ceef323d0)), closes [#333](https://github.com/dataswap/core/issues/333)

# [0.6.0](https://github.com/dataswap/core/compare/v0.5.1...v0.6.0) (2024-03-07)


### Bug Fixes

* 🐛 Add support for obtaining subsidy requirements ([97931e1](https://github.com/dataswap/core/commit/97931e17bcf007c37bf95df9ca33089a41d20eeb)), closes [#324](https://github.com/dataswap/core/issues/324)


### Features

* 🎸 Add initialization function after contract deployment ([62042e0](https://github.com/dataswap/core/commit/62042e0fcb05225c23dc1c27b58f0109bba524c1)), closes [#322](https://github.com/dataswap/core/issues/322)

## [0.5.1](https://github.com/dataswap/core/compare/v0.5.0...v0.5.1) (2024-03-01)


### Bug Fixes

* 🐛 fix docker scripts ([c672d73](https://github.com/dataswap/core/commit/c672d73eed728f55532465435058e5190143c66d)), closes [#320](https://github.com/dataswap/core/issues/320)
* 🐛 fix submitDatasetChallengeProofs ([e4af9a3](https://github.com/dataswap/core/commit/e4af9a3ee2fbf37a1269b194855cdfa956969663)), closes [#318](https://github.com/dataswap/core/issues/318)

# [0.5.0](https://github.com/dataswap/core/compare/v0.4.0...v0.5.0) (2024-02-29)


### Bug Fixes

* 🐛 Fixed the issue with submitDatasetChallengeProofs ([2b9414e](https://github.com/dataswap/core/commit/2b9414e018396e74285c288a7a63473e7c9e4c54)), closes [#316](https://github.com/dataswap/core/issues/316)
* 🐛 Initialization after contract deployment in the docker ([fe3b517](https://github.com/dataswap/core/commit/fe3b5176b56266928a11be963da4c31cd41d73e6)), closes [#313](https://github.com/dataswap/core/issues/313)


### Features

* 🎸 Modify the IEScrowBase extend interface as the internal ([315820c](https://github.com/dataswap/core/commit/315820c6708403293f05a47ad733d2b9cfdcd8e8)), closes [#312](https://github.com/dataswap/core/issues/312)

# [0.4.0](https://github.com/dataswap/core/compare/v0.3.1...v0.4.0) (2024-02-27)


### Bug Fixes

* 🐛 change tvl to escrow in statistics ([2f150bb](https://github.com/dataswap/core/commit/2f150bb4c223df86f26cbe86d2b8fab2907d330e)), closes [#304](https://github.com/dataswap/core/issues/304)
* 🐛 remove member finance statistics ([b8dcc22](https://github.com/dataswap/core/commit/b8dcc2252b1704fc8269156f0e00ecd0fc37f541)), closes [#305](https://github.com/dataswap/core/issues/305)


### Features

* 🎸 Add StorageProviderDatacapChunkLandPenalty to statistic ([59d50b1](https://github.com/dataswap/core/commit/59d50b189292f41ed399e5ef6b880c786733abde)), closes [#308](https://github.com/dataswap/core/issues/308)

## [0.3.1](https://github.com/dataswap/core/compare/v0.3.0...v0.3.1) (2024-02-26)


### Bug Fixes

* 🐛 Fix library function visibility issue ([82ae822](https://github.com/dataswap/core/commit/82ae8226e7e7acea69ae8de5ecba99db6578be4a)), closes [#300](https://github.com/dataswap/core/issues/300)
* 🐛 getAccountEscrow interface Arguments in wrong order ([90eb215](https://github.com/dataswap/core/commit/90eb215efa7bfb8655689082c5b5261178d30188)), closes [#302](https://github.com/dataswap/core/issues/302)

# [0.3.0](https://github.com/dataswap/core/compare/v0.2.0...v0.3.0) (2024-02-26)


### Features

* 🎸 Implement ChallengeAudit escrow contract ([99a58d1](https://github.com/dataswap/core/commit/99a58d1bd59f149461ad80088bf4d17dc5ab4265)), closes [#248](https://github.com/dataswap/core/issues/248)
* 🎸 Implement DisputeAudit escrow contract ([6535142](https://github.com/dataswap/core/commit/653514241de1f8551e130ef7d9ad18825a8f16d9)), closes [#249](https://github.com/dataswap/core/issues/249)
* 🎸 Implement ProofAudit escrow contract ([8d8bc00](https://github.com/dataswap/core/commit/8d8bc003f93f79a5908eb9a4f7c25558e934f3ee)), closes [#247](https://github.com/dataswap/core/issues/247)
* 🎸 Optimize deployment tools ([9022ff8](https://github.com/dataswap/core/commit/9022ff8748e91906cdcfe111bdc88fb6e13caf86)), closes [#297](https://github.com/dataswap/core/issues/297)
* 🎸 update devnet.bash ([b355da2](https://github.com/dataswap/core/commit/b355da20c8aa4e99b37f725a2a51f1a5d5bf72b4)), closes [#297](https://github.com/dataswap/core/issues/297)
* 🎸 update version to 0.2.0 ([eddacf2](https://github.com/dataswap/core/commit/eddacf219c0b52e96404545832ae31f24e551e8d))
