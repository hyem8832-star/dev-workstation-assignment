#!/bin/sh
# Docker Ubuntu 컨테이너 등 리눅스 셸에서 실행. 출력은 tee로 evidence에 저장하세요.
set -eu
mkdir -p /tmp/workstation-lab/practice
cd /tmp/workstation-lab
printf '\n## current/hidden files\n'
pwd
ls -la
printf '\n## create/copy/rename/move/content/touch/delete\n'
echo 'hello CLI' > practice/original.txt
cp practice/original.txt practice/copy.txt
mv practice/copy.txt practice/renamed.txt
touch practice/empty.txt
cat practice/renamed.txt
ls -la practice
rm practice/empty.txt
printf '\n## permissions: file and directory BEFORE\n'
ls -ld practice practice/original.txt
printf '\n## permissions: change 600/700\n'
chmod 600 practice/original.txt
chmod 700 practice
ls -ld practice practice/original.txt
printf '\n## permissions: restore 644/755\n'
chmod 644 practice/original.txt
chmod 755 practice
ls -ld practice practice/original.txt
printf '\nDone\n'
