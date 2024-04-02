#!/usr/bin/env bash

session="lotus-devnet"
wdaemon="daemon"
wminer="miner"
wsetup="setup"
wpledging="pledging"
wcli="cli"
wshell="cli"

PLEDGE_COUNT="${1:-20}"

if [ -z "$BRANCH" ]; then
  BRANCH="devnet"
fi

if [ -z "$BUILD" ]; then
  BUILD="no"
fi

if [ -z "$DEVNET" ]; then
  DEVNET="yes"
fi

BASEDIR="/root"
NETWORK_RPC_URL="http://127.0.0.1:1234/rpc/v1"
if [ "$BUILD" == "yes" ]; then
  git clone --branch "$BRANCH" https://github.com/filecoin-project/lotus.git "${BASEDIR}/build"
fi

mkdir -p "${BASEDIR}/scripts"

cat >"${BASEDIR}/env" <<EOF
export PRIVATE_KEY=0x0a3570f105ea5d06c355ea1a7a1fea441e90e44984896779b6c44c2ca5a8e16b
export PRIVATE_KEY_BIDDER=0xcc52fdd7a98313d783f01e5275ac4fc1c15b8efe26ecdfbab3a5cd9c932cc986
export PRIVATE_KEY_DATASETAUDITOR=0xce8f384ece258c311ce572ceb7205e952c58d72d4880fe64b88239c07ef3cde6
export PRIVATE_KEY_METADATASUBMITTER=0x0904cdc9c54d32fd7bef4ac225dabfd5d7aeafeaa118ba5e2da8f8b4f36012a1
export PRIVATE_KEY_PROOFSUBMITTER=0xe624c69077cfea8e36bf4f1a1383ad4555f2f52f2d34abfe54c0918b8d843099
export DATASWAP_GOVERNANCE=0x09C6DEE9DB5e7dF2b18283c0CFCf714fEDB692d7
export DATASWAP_BIDDER=0xca942f0fd39185d971d1d58E151645e596FC7Eff
export DATASWAP_DATASETAUDITOR=0x405741492033d32eb3f1f12aa1aba40e47a59234
export DATASWAP_PROOFSUBMITTER=0x3D08114dD4F65B5DDCc760884249D9d1AE435Dee
export DATASWAP_METADATASUBMITTER=0x15B2896f76Cee4E2C567e7bC671bB701D7339B30
EOF

cat >"${BASEDIR}/scripts/build.bash" <<EOF
#!/usr/bin/env bash
set -x

SCRIPTDIR="\$( cd "\$( dirname "\${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd \$SCRIPTDIR/../build

pwd
env RUSTFLAGS="-C target-cpu=native -g" FFI_BUILD_FROM_SOURCE=1 make clean deps lotus lotus-miner lotus-shed
cp lotus lotus-miner lotus-shed ../bin/

popd
EOF

cat >"${BASEDIR}/scripts/env.fish" <<EOF
set -x LOTUS_PATH ${BASEDIR}/.lotus
set -x LOTUS_MINER_PATH ${BASEDIR}/.lotusminer
set -x LOTUS_API_LISTENADDRESS "/ip4/0.0.0.0/tcp/1234/http"
set -x LOTUS_FEVM_ENABLEETHRPC true
EOF

cat >"${BASEDIR}/scripts/env.bash" <<EOF
export LOTUS_PATH=${BASEDIR}/.lotus
export LOTUS_MINER_PATH=${BASEDIR}/.lotusminer
export LOTUS_API_LISTENADDRESS="/ip4/0.0.0.0/tcp/1234/http"
export LOTUS_FEVM_ENABLEETHRPC=true
EOF

cat >"${BASEDIR}/scripts/create_miner.bash" <<EOF
#!/usr/bin/env bash
set -x

lotus wallet import --as-default ~/.genesis-sectors/pre-seal-t01000.key
lotus-miner init --genesis-miner --actor=t01000 --sector-size=2KiB --pre-sealed-sectors=~/.genesis-sectors --pre-sealed-metadata=~/.genesis-sectors/pre-seal-t01000.json --nosync
EOF

chmod +x "${BASEDIR}/scripts/build.bash"
chmod +x "${BASEDIR}/scripts/create_miner.bash"

export LOTUS_PATH="${BASEDIR}/.lotus"
export LOTUS_MINER_PATH="${BASEDIR}/.lotusminer"

case $(basename $SHELL) in
fish) shell=fish ;;
*) shell=bash ;;
esac

source ${BASEDIR}/scripts/env.$shell

# install tools
curl -sL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs
curl -L https://foundry.paradigm.xyz | bash
source ${BASEDIR}/.bashrc
${BASEDIR}/.foundry/bin/foundryup
${BASEDIR}/.foundry/bin/cast -h



lotus-seed pre-seal --sector-size 2KiB --num-sectors 2
lotus-seed genesis new devnet.json
lotus-seed genesis set-signers --threshold=1 --signers $(lotus-shed keyinfo new bls) devnet.json
lotus-seed genesis add-miner devnet.json ~/.genesis-sectors/pre-seal-t01000.json
nohup lotus daemon --lotus-make-genesis=dev.gen --genesis-template=devnet.json --bootstrap=false >${BASEDIR}/daemon.log &

export LOTUS_PATH="${BASEDIR}/.lotus"
lotus wait-api

${BASEDIR}/scripts/create_miner.bash
nohup lotus-miner run --miner-api 2345 --nosync >${BASEDIR}/miner.log &

cp ${BASEDIR}/.lotus/token /var/lib/lotus/
cp ${BASEDIR}/.lotusminer/token /var/lib/lotus-miner/

lotus wallet import bls-*
lotus send f410fbhdn52o3lz67fmmcqpam7t3rj7w3newxjclinsi 100
lotus send f410fcwzis33wz3sofrlh466gog5xahlthgzqezasapy 100
lotus send f410fhuebctou6znv3xghmceeesoz2gxegxpoopw46jq 100
lotus send f410fiblucsjagpjs5m7r6evkdk5ebzd2leru46j3wli 100
lotus send f410fzkkc6d6tsgc5s4or2whbkfsf4wlpy7x7l6g2p6i 100

mkdir /opt/dataswap
CONTRACT_VERSION=$(git ls-remote --tags https://github.com/dataswap/core.git | awk '{print $2}' | grep -v '{}' | awk -F '/' '{print $3}' | sort -V | tail -n 1)
git clone -b $CONTRACT_VERSION https://github.com/dataswap/core.git /opt/dataswap
cd /opt/dataswap

cat >"${BASEDIR}/contract_version" <<EOF
$CONTRACT_VERSION
EOF

npm install
npm install -g yarn
npm install -g npx
yarn hardhat compile
yarn hardhat deploy

RolesAddress=$(npx hardhat getProxyAddress --type localnet --name Roles)
FilplusAddress=$(npx hardhat getProxyAddress --type localnet --name Filplus)
FinanceAddress=$(npx hardhat getProxyAddress --type localnet --name Finance)
FilecoinAddress=$(npx hardhat getProxyAddress --type localnet --name Filecoin)
CarstoreAddress=$(npx hardhat getProxyAddress --type localnet --name Carstore)
StoragesAddress=$(npx hardhat getProxyAddress --type localnet --name Storages)
MerkleUtilsAddress=$(npx hardhat getProxyAddress --type localnet --name MerkleUtils)
DatasetsAddress=$(npx hardhat getProxyAddress --type localnet --name Datasets)
DatasetsProofAddress=$(npx hardhat getProxyAddress --type localnet --name DatasetsProof)
DatasetsChallengeAddress=$(npx hardhat getProxyAddress --type localnet --name DatasetsChallenge)
DatasetsRequirementAddress=$(npx hardhat getProxyAddress --type localnet --name DatasetsRequirement)
MatchingsAddress=$(npx hardhat getProxyAddress --type localnet --name Matchings)
MatchingsBidsAddress=$(npx hardhat getProxyAddress --type localnet --name MatchingsBids)
MatchingsTargetAddress=$(npx hardhat getProxyAddress --type localnet --name MatchingsTarget)
EscrowDataTradingFeeAddress=$(npx hardhat getProxyAddress --type localnet --name EscrowDataTradingFee)
EscrowDatacapChunkLandCollateralAddress=$(npx hardhat getProxyAddress --type localnet --name EscrowDatacapChunkLandCollateral)
EscrowDatacapCollateralAddress=$(npx hardhat getProxyAddress --type localnet --name EscrowDatacapCollateral)
EscrowChallengeCommissionAddress=$(npx hardhat getProxyAddress --type localnet --name EscrowChallengeCommission)
EscrowChallengeAuditCollateralAddress=$(npx hardhat getProxyAddress --type localnet --name EscrowChallengeAuditCollateral)

cat >"${BASEDIR}/contract" <<EOF
export RolesAddress=$RolesAddress
export FilplusAddress=$FilplusAddress
export FinanceAddress=$FinanceAddress
export FilecoinAddress=$FilecoinAddress
export CarstoreAddress=$CarstoreAddress
export StoragesAddress=$StoragesAddress
export MerkleUtilsAddress=$MerkleUtilsAddress
export DatasetsAddress=$DatasetsAddress
export DatasetsProofAddress=$DatasetsProofAddress
export DatasetsChallengeAddress=$DatasetsChallengeAddress
export DatasetsRequirementAddress=$DatasetsRequirementAddress
export MatchingsAddress=$MatchingsAddress
export MatchingsBidsAddress=$MatchingsBidsAddress
export MatchingsTargetAddress=$MatchingsTargetAddress
export EscrowDataTradingFeeAddress=$EscrowDataTradingFeeAddress
export EscrowDatacapChunkLandCollateralAddress=$EscrowDatacapChunkLandCollateralAddress
export EscrowDatacapCollateralAddress=$EscrowDatacapCollateralAddress
export EscrowChallengeCommissionAddress=$EscrowChallengeCommissionAddress
export EscrowChallengeAuditCollateralAddress=$EscrowChallengeAuditCollateralAddress
EOF

PRIVATE_KEY="0x0a3570f105ea5d06c355ea1a7a1fea441e90e44984896779b6c44c2ca5a8e16b"
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "registerContract(uint8,address)" 0 $FilplusAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "registerContract(uint8,address)" 1 $FinanceAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "registerContract(uint8,address)" 2 $FilecoinAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "registerContract(uint8,address)" 3 $CarstoreAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "registerContract(uint8,address)" 4 $StoragesAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "registerContract(uint8,address)" 5 $MerkleUtilsAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "registerContract(uint8,address)" 6 $DatasetsAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "registerContract(uint8,address)" 7 $DatasetsProofAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "registerContract(uint8,address)" 8 $DatasetsChallengeAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "registerContract(uint8,address)" 9 $DatasetsRequirementAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "registerContract(uint8,address)" 10 $MatchingsAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "registerContract(uint8,address)" 11 $MatchingsBidsAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "registerContract(uint8,address)" 12 $MatchingsTargetAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "registerContract(uint8,address)" 13 $EscrowDataTradingFeeAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "registerContract(uint8,address)" 14 $EscrowDatacapChunkLandCollateralAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "registerContract(uint8,address)" 15 $EscrowDatacapCollateralAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "registerContract(uint8,address)" 16 $EscrowChallengeCommissionAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "registerContract(uint8,address)" 17 $EscrowChallengeAuditCollateralAddress

sleep 15s

echo "filplusAddress:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "filplus()(address)")
echo "financeAddress:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "finance()(address)")
echo "filecoinAddress:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "filecoin()(address)")
echo "carstoreAddress:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "carstore()(address)")
echo "storagesAddress:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "storages()(address)")
echo "merkleUtilsAddress:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "merkleUtils()(address)")
echo "datasetsAddress:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "datasets()(address)")
echo "datasetsProofAddress:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "datasetsProof()(address)")
echo "datasetsChallengeAddress:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "datasetsChallenge()(address)")
echo "datasetsRequirementAddress:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "datasetsRequirement()(address)")
echo "matchingsAddress:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "matchings()(address)")
echo "matchingsBidsAddress:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "matchingsBids()(address)")
echo "matchingsTargetAddress:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "matchingsTarget()(address)")
echo "escrowDataTradingFeeAddress:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "escrowDataTradingFee()(address)")
echo "escrowDatacapChunkLandCollateralAddress:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "escrowDatacapChunkLandCollateral()(address)")
echo "escrowChallengeCommissionAddress:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "escrowChallengeCommission()(address)")
echo "escrowDatacapCollateralAddress:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "escrowDatacapCollateral()(address)")
echo "escrowChallengeAuditCollateralAddress:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "escrowChallengeAuditCollateral()(address)")

DATASWAPROLE="0xd4c6f45e959193f4fa6251e76cc3d999512eb8b529a40dac0d5e892efe8ea48e"

${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "grantRole(bytes32,address)" $DATASWAPROLE $RolesAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "grantRole(bytes32,address)" $DATASWAPROLE $FilplusAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "grantRole(bytes32,address)" $DATASWAPROLE $FinanceAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "grantRole(bytes32,address)" $DATASWAPROLE $FilecoinAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "grantRole(bytes32,address)" $DATASWAPROLE $CarstoreAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "grantRole(bytes32,address)" $DATASWAPROLE $StoragesAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "grantRole(bytes32,address)" $DATASWAPROLE $MerkleUtilsAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "grantRole(bytes32,address)" $DATASWAPROLE $DatasetsAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "grantRole(bytes32,address)" $DATASWAPROLE $DatasetsProofAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "grantRole(bytes32,address)" $DATASWAPROLE $DatasetsChallengeAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "grantRole(bytes32,address)" $DATASWAPROLE $DatasetsRequirementAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "grantRole(bytes32,address)" $DATASWAPROLE $MatchingsAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "grantRole(bytes32,address)" $DATASWAPROLE $MatchingsBidsAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "grantRole(bytes32,address)" $DATASWAPROLE $MatchingsTargetAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "grantRole(bytes32,address)" $DATASWAPROLE $EscrowDataTradingFeeAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "grantRole(bytes32,address)" $DATASWAPROLE $EscrowDatacapChunkLandCollateralAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "grantRole(bytes32,address)" $DATASWAPROLE $EscrowDatacapCollateralAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "grantRole(bytes32,address)" $DATASWAPROLE $EscrowChallengeCommissionAddress
${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $RolesAddress "grantRole(bytes32,address)" $DATASWAPROLE $EscrowChallengeAuditCollateralAddress

sleep 15s

echo "roles role:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "hasRole(bytes32,address)(bool)" $DATASWAPROLE $RolesAddress)
echo "filplus role:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "hasRole(bytes32,address)(bool)" $DATASWAPROLE $FilplusAddress)
echo "finance role:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "hasRole(bytes32,address)(bool)" $DATASWAPROLE $FinanceAddress)
echo "filecoin role:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "hasRole(bytes32,address)(bool)" $DATASWAPROLE $FilecoinAddress)
echo "carstore role:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "hasRole(bytes32,address)(bool)" $DATASWAPROLE $CarstoreAddress)
echo "storages role:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "hasRole(bytes32,address)(bool)" $DATASWAPROLE $StoragesAddress)
echo "merkleUtils role:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "hasRole(bytes32,address)(bool)" $DATASWAPROLE $MerkleUtilsAddress)
echo "datasets role:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "hasRole(bytes32,address)(bool)" $DATASWAPROLE $DatasetsAddress)
echo "datasetsProof role:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "hasRole(bytes32,address)(bool)" $DATASWAPROLE $DatasetsProofAddress)
echo "datasetsChallenge role:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "hasRole(bytes32,address)(bool)" $DATASWAPROLE $DatasetsChallengeAddress)
echo "datasetsRequirement role:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "hasRole(bytes32,address)(bool)" $DATASWAPROLE $DatasetsRequirementAddress)
echo "matchings role:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "hasRole(bytes32,address)(bool)" $DATASWAPROLE $MatchingsAddress)
echo "matchingsBids role:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "hasRole(bytes32,address)(bool)" $DATASWAPROLE $MatchingsBidsAddress)
echo "matchingsTarget role:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "hasRole(bytes32,address)(bool)" $DATASWAPROLE $MatchingsTargetAddress)
echo "escrowDataTradingFee role:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "hasRole(bytes32,address)(bool)" $DATASWAPROLE $EscrowDataTradingFeeAddress)
echo "escrowDatacapChunkLandCollateral role:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "hasRole(bytes32,address)(bool)" $DATASWAPROLE $EscrowDatacapChunkLandCollateralAddress)
echo "escrowDatacapCollateral role:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "hasRole(bytes32,address)(bool)" $DATASWAPROLE $EscrowDatacapCollateralAddress)
echo "escrowChallengeCommission role:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "hasRole(bytes32,address)(bool)" $DATASWAPROLE $EscrowChallengeCommissionAddress)
echo "escrowChallengeAuditCollateral role:" $(${BASEDIR}/.foundry/bin/cast call --rpc-url $NETWORK_RPC_URL $RolesAddress "hasRole(bytes32,address)(bool)" $DATASWAPROLE $EscrowChallengeAuditCollateralAddress)


RootAddress=$(lotus msig inspect f080 | grep t0100 | awk '{print $2}')
NotariyAddress=$(lotus evm stat $FilecoinAddress | grep "ID address" | awk '{print $3}')
lotus-shed verifreg add-verifier $RootAddress $NotariyAddress 100000000000000000
lotus filplus list-notaries

${BASEDIR}/.foundry/bin/cast send --rpc-url $NETWORK_RPC_URL --async --private-key $PRIVATE_KEY $StoragesAddress "registDataswapDatacap(uint256)" 100000000000000000

cd ..

rm -rf /opt/dataswap
rm -rf /root/.cache
rm -rf /root/.npm
rm -rf /root/.foundry
rm -rf /usr/local/bin/lotus-shed
rm -rf /usr/local/bin/lotus-seed

