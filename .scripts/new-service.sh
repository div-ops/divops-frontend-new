printf "도메인을 선택해주세요!\n"
domains=(
  "app.divops.kr"
  "www.creco.services"
)

select domain in "${domains[@]}"; do
  case $domain in "app.divops.kr" | "www.creco.services")
    echo "$domain 을 선택했습니다."
    break
    ;;
  *)
    echo "1 혹은 2를 입력해주세요."
    exit 1
    ;;
  esac
done

printf "서비스 이름을 입력하세요 (e.g. hello-world) >>> "

read serviceName

gh repo create --public --add-readme div-ops/$domain-$serviceName || exit 1

echo "✅ REPO create 완료"

cd $domain/hello-world || exit 1

git remote add $serviceName git@github.com:div-ops/$domain-$serviceName.git || exit 1

git push $serviceName main -f || exit 1

git remote remove $serviceName || exit 1

cd -

git submodule add git@github.com:div-ops/$domain-$serviceName.git ./$domain/$serviceName || exit 1

echo "✅ REPO clone 완료"

cd ./$domain/$serviceName

git remote update

git switch main

echo "# $domain-$serviceName" >./README.md

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

git commit -m "feat: $domain/$serviceName 스캐폴딩"

git push origin HEAD

case $domain in "app.divops.kr")
  echo "✅ VERCEL 설정을 하세요!"

  COMMAND="npx vercel-submodules --all && yarn install"
  echo "👉 INSTALL COMMAND: \"$COMMAND\""

  IGNORE='[[ $VERCEL_GIT_COMMIT_MESSAGE == *"skip vercel"* ]] && exit 0 || exit 1'
  echo "👉 Ignored Build Step: \"$IGNORE\""

  open "https://vercel.com/new/divops-monorepo"

  break
  ;;
"www.creco.services")

  echo "✅ .github 을 설정하세요"
  break
  ;;
esac
