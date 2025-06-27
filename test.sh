failed=0
for file in *.yml; do
    echo "-> Checking $file..."
    resp=$(curl -s -w "%{http_code}" -o output.json \
        -X POST https://t01.durablox.net/descriptor/check/v1 \
        -H "Content-Type: application/x-yaml" \
        --data-binary "@$file")

    if [ "$resp" -ne 200 ]; then
        failed=1
    fi

    if [ "$(jq '.messages | length' output.json)" -gt 0 ]; then
        echo "     Messages for $file:"
        jq -r '.messages[] | "     \(.severity): \(.message)"' output.json
    else
        echo "     No Messages for $file..."
    fi
    echo ""
    

    rm output.json
done
exit $failed