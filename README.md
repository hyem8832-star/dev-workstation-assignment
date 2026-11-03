# 내 컴퓨터에 개발자용 작업실 꾸미기

> **제출용 프로젝트 초안** — Dockerfile/웹 소스/실습 스크립트는 작성 완료. 아래 `[ ]` 항목은 **실제 PC에서 실행·검증 후** `[x]`로 바꿔야 하며, 실행하지 않은 결과를 성공한 것으로 적지 않습니다.

## 1. 프로젝트 소개

Windows + PowerShell + Docker Desktop(또는 Linux/macOS의 Docker)에서 CLI, 권한, Docker 이미지/컨테이너, 웹 서버, 포트, 바인드 마운트, 영속 볼륨, Git/GitHub를 실습합니다. 기본 이미지 `nginx:1.27-alpine`을 골라 HTML을 교체한 커스텀 이미지를 만듭니다.

- **이미지**: 컨테이너 실행용 설계도
- **컨테이너**: 이미지로 만든 실행 중 또는 중지된 인스턴스
- **포트 매핑**: PC의 포트 8080/8081을 컨테이너의 80번 포트로 연결
- **바인드 마운트**: PC `site` 폴더를 컨테이너에 연결해 수정 즉시 반영
- **볼륨**: 컨테이너를 삭제해도 독립적으로 데이터를 유지
- **Git vs GitHub**: Git은 내 PC의 변경 이력 관리, GitHub는 원격 저장소 및 협업

## 2. 실행 환경 (실제 실행 후 수정)

| 항목 | 정보 |
|---|---|
| OS | Windows (정확한 버전 기록 필요) |
| Shell/터미널 | PowerShell / Windows Terminal 또는 VSCode 터미널 |
| Docker | `docker --version` 출력으로 기입 |
| Docker 엔진 | `docker info` 성공 여부 기입 |
| Git | `git --version` 출력으로 기입 |
| 에디터 | VSCode |

> Docker Desktop은 **실행 중**이어야 합니다. 시작 화면에서 멈췄다면 Docker 엔진 정상 실행 전이므로 이후 명령이 실패할 수 있습니다. 학교 제공 macOS 환경이라면 OrbStack 사용 가능. Windows에서 OrbStack 설치를 전제로 하지 않습니다.

## 3. 수행 체크리스트

- [ ] Linux CLI: 이동/생성/복사/이름변경/삭제/내용/숨김 파일
- [ ] 파일과 디렉터리 권한 실습
- [ ] Docker 버전과 데몬 확인
- [ ] Docker 이미지/컨테이너 운영, 로그/리소스 확인
- [ ] `hello-world` 및 Ubuntu 내부 명령 수행
- [ ] 커스텀 Dockerfile 이미지 빌드 및 실행
- [ ] 포트 8080과 8081 접속 검증
- [ ] 바인드 마운트 변경 전후 비교
- [ ] 볼륨 삭제 전후 데이터 유지 확인
- [ ] Git 설정, VSCode 연동, GitHub 푸시
- [ ] 트러블슈팅 2건 기록
- [ ] 모든 캡처·로그를 `evidence/`에 저장하고 링크 연결

## 4. 터미널/파일/권한 — Linux CLI

PowerShell과 Linux의 명령어/권한은 다르므로 Linux 컨테이너 안에서 실습합니다. 프로젝트 폴더의 PowerShell에서:

```powershell
docker run --rm -it --name lab-cli -v "${PWD}/scripts:/scripts:ro" ubuntu:24.04 bash
```

컨테이너 내부(프롬프트가 `root@...#`로 바뀜):

```bash
bash /scripts/terminal-permissions.sh
exit
```

**출력 저장 권장:** Windows 터미널에서 `Start-Transcript -Path evidence/01-terminal.txt` 실행 후 Docker 명령과 내부 작업을 수행하고 종료 후 `Stop-Transcript`를 실행합니다. 같은 로그를 `02-permissions.txt`로 복사하거나 관련 부분만 분리해 넣어도 됩니다. `scripts/terminal-permissions.sh`는 `pwd`, `ls -la`, `cd`, `mkdir`, `cp`, `mv`, `rm`, `touch`, `cat`, `chmod`, `ls -ld`를 실제 수행합니다.

설명: `/tmp/workstation-lab`은 **절대 경로**, `practice/original.txt`는 현재 작업 디렉터리를 기준으로 한 **상대 경로**입니다. `r=4`, `w=2`, `x=1`이므로 `755`는 소유자 `rwx`, 그룹/기타 `r-x`이고 `644`는 소유자 `rw-`, 그룹/기타 `r--`입니다. 디렉터리에서 `x`는 안으로 접근·탐색하는 권한입니다.

## 5. Docker 설치 점검 및 기본 운영

아래의 각 코드블록은 **실제 실행 명령**이며, 예상 출력은 고정해 두지 않았습니다. 명령 및 출력은 `evidence/03-docker.txt` 등으로 저장합니다.

```powershell
docker --version
docker info
docker pull hello-world
docker images
docker run --rm hello-world
docker run -it --name lab-ubuntu ubuntu:24.04 bash
```

Ubuntu 내부:

```bash
pwd
ls
echo 'ubuntu container works'
exit
```

다시 PowerShell:

```powershell
docker ps
docker ps -a
docker start lab-ubuntu
docker ps -a
docker rm -f lab-ubuntu
```

`docker run -it ... bash`에서 `exit`하면 기본 프로세스가 끝나 컨테이너가 중지됩니다. `docker start`로 재가동하면 Docker가 저장한 시작 명령(`bash`)이 대화형 입력 없이 곧 종료될 수 있습니다. 재시작 직후에도 바로 끝날 수 있습니다. **안정적으로 exec를 보려면** 다음을 실행합니다.

```powershell
docker run -d --name lab-ubuntu-bg ubuntu:24.04 sleep infinity
docker exec lab-ubuntu-bg sh -c 'echo running; ls /'
docker stop lab-ubuntu-bg
docker rm lab-ubuntu-bg
```

`run -it`은 터미널에 붙어 실행하고, `run -d`는 백그라운드로 실행하며, `exec`는 **이미 실행 중인 컨테이너** 안에 명령을 추가로 수행합니다.

## 6. Dockerfile과 커스텀 웹 서버

`Dockerfile` 내용:

```dockerfile
FROM nginx:1.27-alpine
LABEL org.opencontainers.image.title="workstation-lab-web"
LABEL org.opencontainers.image.description="CLI Docker Git workstation training web server"
COPY site/ /usr/share/nginx/html/
EXPOSE 80
```

커스텀 내용: `nginx:1.27-alpine` 기반으로 경량 웹 서버를 사용하고(`FROM`), 식별 정보를 넣고(`LABEL`), 작성한 한글 웹페이지를 기본 서비스 폴더에 복사(`COPY`)하고, 내부 웹 포트 80을 문서화(`EXPOSE`)했습니다. `EXPOSE`만으로 PC에 포트가 공개되지는 않으며 `-p`를 붙여야 합니다.

프로젝트 폴더에서:

```powershell
docker build -t workstation-web:1.0 .
docker run -d --name lab-web-8080 -p 8080:80 workstation-web:1.0
docker run -d --name lab-web-8081 -p 8081:80 workstation-web:1.0
docker images
docker ps -a
docker logs lab-web-8080
docker stats --no-stream
curl.exe http://localhost:8080
curl.exe http://localhost:8081
```

브라우저에서 `http://localhost:8080`과 `http://localhost:8081`에 접속해 주소창과 페이지가 한 화면에 보이게 각각 캡처합니다: [8080 증거](evidence/05-port-8080.png), [8081 증거](evidence/06-port-8081.png). **실제 캡처 파일이 아직 없다면 이 링크는 열리지 않습니다.**

기본 로그 모으기:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/collect-docker.ps1
```

## 7. 바인드 마운트: PC 파일을 바꾸면 즉시 반영

기존 8080 컨테이너와는 별도로 8082를 사용합니다.

```powershell
docker run -d --name lab-web-bind -p 8082:80 -v "${PWD}/site:/usr/share/nginx/html:ro" nginx:1.27-alpine
curl.exe http://localhost:8082
```

1. `http://localhost:8082`를 열고 **원본 문구** 캡처 → `evidence/07-bind-before.png`.
2. VSCode에서 `site/index.html`의 `바인드 마운트 테스트: 원본 문구`를 `바인드 마운트 테스트: 수정 반영 성공`으로 변경하고 저장.
3. 브라우저 새로고침(Ctrl+F5) 후 **수정 문구** 캡처 → `evidence/08-bind-after.png`.
4. `curl.exe http://localhost:8082` 결과와 실행 명령도 로그로 남김.

검증: 컨테이너 재빌드 없이 바뀌면 바인드 마운트 성공. **주의:** 이 수정 이후 다시 커스텀 이미지를 빌드하면 수정된 HTML이 이미지에 반영됩니다.

## 8. Docker 볼륨: 컨테이너를 삭제해도 데이터 유지

```powershell
docker volume create workstation-data
docker run -d --name lab-vol-before -v workstation-data:/data ubuntu:24.04 sleep infinity
docker exec lab-vol-before sh -c 'echo persistent-data-2026 > /data/proof.txt; cat /data/proof.txt'
docker rm -f lab-vol-before
docker run -d --name lab-vol-after -v workstation-data:/data ubuntu:24.04 sleep infinity
docker exec lab-vol-after cat /data/proof.txt
docker volume ls
docker rm -f lab-vol-after
```

같은 `persistent-data-2026`이 **삭제 전후 모두 출력**되어야 성공입니다. 실제 실행 명령·출력을 `evidence/09-volume.txt`로 저장하세요. 볼륨은 `docker rm -f`로 삭제되지 않지만 `docker volume rm workstation-data`로 별도 삭제할 수 있습니다.

## 9. Git/GitHub/VSCode 연동

개인 이름/이메일은 **본인 정보**로 설정합니다. `git config --list` 출력에는 사용자 이메일 및 인증 관련 값이 있을 수 있으니 업로드 전 반드시 검토·마스킹합니다.

```powershell
git --version
git config --global user.name "YOUR_NAME"
git config --global user.email "YOUR_EMAIL"
git config --global init.defaultBranch main
git config --list
git init
git add .
git commit -m "Create developer workstation assignment"
```

1. GitHub 웹사이트에서 빈 저장소 `dev-workstation-assignment` 생성(README 자동 생성 옵션 해제).
2. VSCode에서 GitHub 로그인: 좌측 계정 아이콘 → **Sign in with GitHub**. 소스 제어 탭에서 변경 사항을 확인.
3. 다음 명령 실행 (`YOUR_ID`는 실제 GitHub 계정명으로 변경):

```powershell
git branch -M main
git remote add origin https://github.com/YOUR_ID/dev-workstation-assignment.git
git push -u origin main
git remote -v
git status
```

4. GitHub에서 README 및 파일들이 보이는 화면과 VSCode 로그인/소스 제어 연동 화면을 캡처 → `evidence/11-github.png`(필요하면 여러 장).
5. 실습 증거 파일을 나중에 추가했다면 다시 `git add .`, `git commit -m "Add real verification evidence"`, `git push` 합니다.

## 10. 트러블슈팅 (실제 발생 여부 확인 후 기록)

### 사례 A: Docker Engine이 계속 시작 중인 문제 (확인 필요)

- 문제: Docker Desktop에서 `Starting the Docker Engine...`이 길게 지속됨.
- 원인 가설: WSL2 미설치/미활성화, 재부팅 미실시, 가상화 설정 또는 Docker 서비스 문제.
- 확인 명령: `wsl --status`, `wsl --list --verbose`, `docker info`.
- 해결/대안: 관리자 PowerShell에서 WSL 설치 권한/환경 확인, 허용된 환경에서 `wsl --install` 후 재부팅; 관리형 PC라면 관리자 문의. `wsl --install`에서 403이 발생한 경우 정책/다운로드 제한 가능성을 점검.
- **검증 결과:** 미실행 — 직접 실행 후 오류 화면과 해결 후 `docker info`를 기록.

### 사례 B: 포트가 이미 사용 중인 문제 (예시; 실제 발생하지 않았다면 교체)

- 문제: `docker run -p 8080:80`에서 `port is already allocated` 오류가 나는 경우.
- 원인 가설: 다른 컨테이너/프로그램이 8080 포트를 사용.
- 확인 명령: `docker ps`, `netstat -ano | findstr :8080` (Windows).
- 해결/대안: 사용 중인 컨테이너 중지 또는 호스트 포트를 8083으로 변경(`-p 8083:80`).
- **검증 결과:** 미실행 — 실제 발생한 오류와 복구 후 접속 결과를 기록.

> 제출 조건은 **트러블슈팅 2건 이상**입니다. 위 두 항목은 작성 틀에 해당하며, 실제 관찰한 문제/출력/해결 증거로 확정해야 합니다. 실패하지 않았다면 발생한 다른 실제 이슈나 사전 점검에서 발견한 문제를 사용하세요.

## 11. 검증 증거 위치

| 검증 | 실행 명령 | 증거 파일 |
|---|---|---|
| CLI 기본 조작 | `bash /scripts/terminal-permissions.sh` | [01-terminal.txt](evidence/01-terminal.txt) |
| chmod 파일/폴더 | `ls -ld`, `chmod` | [02-permissions.txt](evidence/02-permissions.txt) |
| Docker 정보/운영 | `docker --version`, `docker info`, `docker images`, `docker ps -a`, `docker logs`, `docker stats` | [03-docker.txt](evidence/03-docker.txt) |
| Dockerfile 빌드 | `docker build -t workstation-web:1.0 .` | [04-build.txt](evidence/04-build.txt) |
| 포트 8080/8081 | `curl.exe` + 브라우저 | [8080](evidence/05-port-8080.png), [8081](evidence/06-port-8081.png) |
| 바인드 마운트 | `-v "${PWD}/site:/usr/share/nginx/html:ro"` | [전](evidence/07-bind-before.png), [후](evidence/08-bind-after.png) |
| 볼륨 영속성 | `docker volume create`, `docker exec`, `docker rm -f` | [09-volume.txt](evidence/09-volume.txt) |
| Git/GitHub | `git config --list`, `git remote -v`, VSCode | [10-git.txt](evidence/10-git.txt), [11-github.png](evidence/11-github.png) |
| 문제 해결 2건 | `wsl --status` 등 실제 확인 | [12-troubleshooting.txt](evidence/12-troubleshooting.txt) |

**미수집 증거에 대한 링크는 아직 작동하지 않습니다.** 결과를 조작하거나 예시 로그를 실제 실행 결과처럼 제출하지 마세요.

## 12. 제출 전 마무리

1. 전 항목 실제 수행 및 출력/캡처 확인.
2. 모든 증거 파일을 `evidence/`에 저장하고 README 링크 정상 동작 확인.
3. 개인정보·토큰·비밀번호 노출 검사. 특히 `git config --list`, `docker info`, 스크린샷 확인.
4. README 체크리스트 완료 표시, 트러블슈팅을 실제 사례로 작성.
5. `git add .` → `git commit` → `git push` 후 GitHub 저장소 **링크** 제출.
