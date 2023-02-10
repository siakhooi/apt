clean:
	rm -rf docs/dists

local-build:
	GPG_PRIVATE_KEY=$$(cat siakhooi-apt.gpg.private.key | base64)  GPG_KEY_NAME=siakhooi-apt ./build.sh
