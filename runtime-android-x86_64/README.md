# RACE Runnable Docker Image - Android Client

Installs android emulator. Configures systemd. 

## Build

### Sample build command

You will need to store your jfrog access token in a file named `/tmp/jfrog-access-token.txt`.

```bash
docker buildx build \
  --cache-from=race-android-client:local-build \
  --platform=linux/amd64 \
  --progress=plain \
  --tag=race-android-client:local-build \
  --secret=id=jfrog_token,src=/tmp/jfrog-access-token.txt \
  --build-arg BASE_IMAGE_TAG=develop \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --build-arg RACE_CONTAINER_REGISTRY=gitlab.race.twosixlabs.com:4567/race-ta3/race-images-base/ \
  .
```

Note for older version of docker (e.g. v19) you will have to replace the build command
```
docker buildx build
```
with
```
DOCKER_BUILDKIT=1 docker build
```
