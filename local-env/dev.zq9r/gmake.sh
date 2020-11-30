#! /bin/sh
source /git/envDev.sh
PROJECT_TOP="../.."

gitPush()
{
expect <<EOF
set timeout 180
spawn git push $gitServerName $gitBranchName
expect {
  "(y/n)" {send "y\r";exp_continue}
  "password:" {send "$gitServerPD\n"}
  "root@" {send "\r"}
  "Already up-to-date." {send "\r"}
}
expect eof
EOF
}

_common ()
{
  git commit -m "$1"
  gitPush
  echo ======================================================

  rm -f vers_${PROJECT_NAME}.sh
  perl ${PROJECT_TOP}/genVersionHeader.pl -v -t ${PROJECT_TOP}/ -N ver_${PROJECT_NAME} vers_${PROJECT_NAME}.sh

  echo =========== git commit version infomation  ===========
  git add vers_${PROJECT_NAME}.sh
  git commit -m "update ${PROJECT_NAME} version info"
  gitPush
  echo ======================================================
}

update_boot ()
{
  echo ================== git commit start ==================
  PROJECT_NAME="boot"
  git add BOOT.BIN
  _common "$1"
}

update_image ()
{
  echo ================== git commit start ==================
  PROJECT_NAME="image"
  git add image.ub
  _common "$1"
}

case "$1" in
  -b)
          update_boot "$2"; ;;
  -i)
          update_image "$2"; ;;
  *)
          echo "======================================="
          echo "[err] missing option :  -b[boot] or -i[image] / 'commit comment'"
          exit 1
esac

exit $?


