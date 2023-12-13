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

if [ "$BUILD" == "yes" ]; then
  git clone --branch "$BRANCH" https://github.com/filecoin-project/lotus.git "${BASEDIR}/build"
fi


mkdir -p "${BASEDIR}/scripts"

cat > "${BASEDIR}/env" <<EOF
export PRIVATE_KEY=0x0a3570f105ea5d06c355ea1a7a1fea441e90e44984896779b6c44c2ca5a8e16b
export PRIVATE_KEY_BIDDER=0xcc52fdd7a98313d783f01e5275ac4fc1c15b8efe26ecdfbab3a5cd9c932cc986
export PRIVATE_KEY_DATASETAUDITOR=0xce8f384ece258c311ce572ceb7205e952c58d72d4880fe64b88239c07ef3cde6
export PRIVATE_KEY_METADATASUBMITTER=0x0904cdc9c54d32fd7bef4ac225dabfd5d7aeafeaa118ba5e2da8f8b4f36012a1
export PRIVATE_KEY_PROOFSUBMITTER=0xe624c69077cfea8e36bf4f1a1383ad4555f2f52f2d34abfe54c0918b8d843099
EOF


cat > "${BASEDIR}/scripts/build.bash" <<EOF
#!/usr/bin/env bash
set -x

SCRIPTDIR="\$( cd "\$( dirname "\${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd \$SCRIPTDIR/../build

pwd
env RUSTFLAGS="-C target-cpu=native -g" FFI_BUILD_FROM_SOURCE=1 make clean deps lotus lotus-miner lotus-shed
cp lotus lotus-miner lotus-shed ../bin/

popd
EOF

cat > "${BASEDIR}/scripts/env.fish" <<EOF
set -x LOTUS_PATH ${BASEDIR}/.lotus
set -x LOTUS_MINER_PATH ${BASEDIR}/.lotusminer
set -x LOTUS_API_LISTENADDRESS "/ip4/0.0.0.0/tcp/1234/http"
set -x LOTUS_FEVM_ENABLEETHRPC true
EOF

cat > "${BASEDIR}/scripts/env.bash" <<EOF
export LOTUS_PATH=${BASEDIR}/.lotus
export LOTUS_MINER_PATH=${BASEDIR}/.lotusminer
export LOTUS_API_LISTENADDRESS="/ip4/0.0.0.0/tcp/1234/http"
export LOTUS_FEVM_ENABLEETHRPC=true
EOF

cat > "${BASEDIR}/scripts/create_miner.bash" <<EOF
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
  fish ) shell=fish ;;
  *    ) shell=bash ;;
esac

source ${BASEDIR}/scripts/env.$shell

lotus-seed pre-seal --sector-size 2KiB --num-sectors 2
lotus-seed genesis new devnet.json
lotus-seed genesis set-signers --threshold=1 --signers $(lotus-shed keyinfo new bls) devnet.json
lotus-seed genesis add-miner devnet.json ~/.genesis-sectors/pre-seal-t01000.json
nohup lotus daemon --lotus-make-genesis=dev.gen --genesis-template=devnet.json --bootstrap=false > ${BASEDIR}/daemon.log &


export LOTUS_PATH="${BASEDIR}/.lotus"
lotus wait-api

${BASEDIR}/scripts/create_miner.bash
nohup lotus-miner run --miner-api 2345 --nosync > ${BASEDIR}/miner.log &

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

cat > "${BASEDIR}/contract_version" <<EOF
$CONTRACT_VERSION
EOF

curl -sL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

npm install
npm install -g yarn
npm install -g npx
yarn hardhat compile
yarn hardhat deploy 

RolesAddress=$(npx hardhat getProxyAddress --type localnet --name Roles)
FilecoinAddress=$(npx hardhat getProxyAddress --type localnet --name Filecoin)
FilplusAddress=$(npx hardhat getProxyAddress --type localnet --name Filplus)
MerkleUtilsAddress=$(npx hardhat getProxyAddress --type localnet --name MerkleUtils)
CarstoreAddress=$(npx hardhat getProxyAddress --type localnet --name Carstore)
EscrowAddress=$(npx hardhat getProxyAddress --type localnet --name Escrow)
DatasetsAddress=$(npx hardhat getProxyAddress --type localnet --name Datasets)
DatasetsRequirementAddress=$(npx hardhat getProxyAddress --type localnet --name DatasetsRequirement)
DatasetsProofAddress=$(npx hardhat getProxyAddress --type localnet --name DatasetsProof)
DatasetsChallengeAddress=$(npx hardhat getProxyAddress --type localnet --name DatasetsChallenge)
MatchingsAddress=$(npx hardhat getProxyAddress --type localnet --name Matchings)
MatchingsTargetAddress=$(npx hardhat getProxyAddress --type localnet --name MatchingsTarget)
MatchingsBidsAddress=$(npx hardhat getProxyAddress --type localnet --name MatchingsBids)
StoragesAddress=$(npx hardhat getProxyAddress --type localnet --name Storages)
DatacapsAddress=$(npx hardhat getProxyAddress --type localnet --name Datacaps)

cat > "${BASEDIR}/contract" <<EOF
export RolesAddress=$RolesAddress
export FilecoinAddress=$FilecoinAddress
export FilplusAddress=$FilplusAddress
export MerkleUtilsAddress=$MerkleUtilsAddress
export CarstoreAddress=$CarstoreAddress
export EscrowAddress=$EscrowAddress
export DatasetsAddress=$DatasetsAddress
export DatasetsRequirementAddress=$DatasetsRequirementAddress
export DatasetsProofAddress=$DatasetsProofAddress
export DatasetsChallengeAddress=$DatasetsChallengeAddress
export MatchingsAddress=$MatchingsAddress
export MatchingsTargetAddress=$MatchingsTargetAddress
export MatchingsBidsAddress=$MatchingsBidsAddress
export StoragesAddress=$StoragesAddress
export DatacapsAddress=$DatacapsAddress
EOF

RootAddress=$(lotus msig inspect f080 |grep t0100 |awk '{print $2}') 
NotariyAddress=$(lotus evm stat $FilecoinAddress |grep "ID address" |awk '{print $3}')
lotus-shed verifreg add-verifier $RootAddress $NotariyAddress 100000000
lotus filplus list-notaries

cd ..

rm -rf /opt/dataswap
