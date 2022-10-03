printf "서비스 이름을 입력하세요 (e.g. hello-world) >>> "

read serviceName

gh repo create --public --add-readme div-ops/app.divops.kr-$serviceName || exit 1

echo "✅ REPO create 완료"

cd app.divops.kr/hello-world || exit 1

git remote add $serviceName git@github.com:div-ops/app.divops.kr-$serviceName.git || exit 1

git push $serviceName main -f || exit 1

git remote remove $serviceName || exit 1

cd -

git submodule add git@github.com:div-ops/app.divops.kr-$serviceName.git ./app.divops.kr/$serviceName || exit 1

echo "✅ REPO clone 완료"

cd ./app.divops.kr/$serviceName

git remote update

git switch main

echo "# app.divops.kr-$serviceName" >./README.md

../../.scripts/replace.sh ./package.json hello-world $serviceName || exit 1

../../.scripts/replace.sh ./next.config.js hello-world $serviceName || exit 1

echo "✅ REPO 초기 설정 완료"

git update-ref -d HEAD || exit 1

echo "✅ REPO commits 리셋 완료"

yarn || exit 1

yarn prepare || exit 1

git add -A || exit 1

git commit -m "initial commit" || exit 1

git push origin main -f || exit 1

echo "✅ REPO initial 완료"

cd -

yarn || exit 1

git add -A

git commit -m "feat: $serviceName 스캐폴딩"

git push origin HEAD
