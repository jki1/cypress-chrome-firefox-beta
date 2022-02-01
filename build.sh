set e+x

IMAGE_NAME=jk2394/cypress-chrome-firefox-beta

echo "Building started for $IMAGE_NAME"
docker build --no-cache -t $IMAGE_NAME .
echo "Building completed for $IMAGE_NAME"
