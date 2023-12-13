#!/usr/bin/env bash

BASEDIR="/root"
export LOTUS_PATH="${BASEDIR}/.lotus"
export LOTUS_MINER_PATH="${BASEDIR}/.lotusminer"

cat > "/usr/local/bin/monitor.bash" <<EOF
#!/usr/bin/env bash

while true; do
  clear
  lotus sync status

  echo
  echo
  echo Miner Info
  lotus-miner info

  echo
  echo
  echo Sector List
  lotus-miner sectors list | tail -n4

  sleep 25

  lotus-shed noncefix --addr \$(lotus wallet list) --auto

done
EOF
chmod +x /usr/local/bin/monitor.bash
nohup lotus daemon --genesis=/dev.gen > ${BASEDIR}/daemon.log &
sleep 5s
nohup lotus-miner run --miner-api 2345 --nosync > ${BASEDIR}/miner.log &


/usr/local/bin/monitor.bash
