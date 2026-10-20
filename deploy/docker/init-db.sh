#!/usr/bin/env bash
# One-shot database initialisation (runs in the SQL Server image, which ships sqlcmd):
# restores the three databases from Database/*.bak on first run, then applies deploy/sql/*.sql
# (idempotent fixes) and points the server list at PUBLIC_HOST:GAME_PORT.
set -euo pipefail
SQL="/opt/mssql-tools18/bin/sqlcmd -S ${DB_SERVER:-sqlserver} -U sa -P ${DB_PASSWORD} -C -b"
echo "waiting for SQL Server..."
for i in $(seq 1 90); do $SQL -Q "SELECT 1" >/dev/null 2>&1 && break; sleep 2; done

restore() { # db bakfile datafile logfile
  if [ "$($SQL -h -1 -W -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM sys.databases WHERE name='$1'")" = "0" ]; then
    echo "restoring $1 from $2"
    $SQL -Q "RESTORE DATABASE [$1] FROM DISK='/backup/$2' WITH MOVE '$3' TO '/var/opt/mssql/data/$1.mdf', MOVE '$4' TO '/var/opt/mssql/data/$1.ldf', REPLACE"
  else
    echo "$1 already exists"
  fi
}
restore Db_Membership Db_Membership.bak Db_Membership_Data Db_Membership_Log
restore Project_Game34 Game34.bak Db_Tank Db_Tank_log
restore Project_Player34 Player34.bak DDTMixTankAc DDTMixTankAc_log

for f in /sql/*.sql; do echo "applying $(basename "$f")"; $SQL -i "$f" >/dev/null; done
$SQL -d Project_Player34 -Q "UPDATE Server_List SET IP = N'${PUBLIC_HOST}', Port = ${GAME_PORT:-9500}, State = 1" >/dev/null
echo "database ready"
