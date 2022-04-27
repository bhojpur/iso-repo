# Bhojpur ISO - Image Build Repository

It is built automatically and hosts the [Bhojpur ISO](https://github.com/bhojpur/iso) packages binaries (built with `isomgr`)

## Local Repository

You can also build this repository locally, if you wish:

```sh
$ make deps
$ curl -LO https://storage.googleapis.com/container-diff/latest/container-diff-linux-amd64 && chmod +x container-diff-linux-amd64 && sudo mv container-diff-linux-amd64 /usr/local/bin/container-diff
$ BHOJPUR_ISO_MANAGER=$GOPATH/bin/isomgr make build-all create-repo
```
To consume this repository with [Bhojpur ISO](https://github.com/bhojpur/iso), add in the `iso.yml`:

```yaml
repositories:
- name: "isomgr"
  type: "http"
  enable: true
  priority: 1
  urls:
  - "https://raw.githubusercontent.com/bhojpur/iso-repo/gh-pages"
```
