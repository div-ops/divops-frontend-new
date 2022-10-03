FILE=$(node -p "require('fs').readFileSync('$1', 'utf-8').replace('$2', '$3')")

echo $FILE | jq >$1
