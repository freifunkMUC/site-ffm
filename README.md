![Build ffmuc firmware](https://github.com/freifunkMUC/site-ffm/workflows/Build%20ffmuc%20firmware/badge.svg)

## Dependencies

* git
* GNU make
* GNU patch
* [Upstream Gluon dependencies](https://gluon.readthedocs.io/en/latest/user/getting_started.html#dependencies)

For convenience, you can find a script to install those dependencies on an Ubuntu-based distribution:\
 [install_build_dependencies.sh](scripts/install_build_dependencies.sh)

## Building

Check out this repository and execute `make`, i.e. like this:

```bash
git clone https://github.com/freifunkMUC/site-ffm.git site-ffm
cd site-ffm
git checkout -b patched && git checkout stable
make
```

### Containerised building

The CI builds inside the official Gluon build container ([gluon-build](https://github.com/freifunk-gluon/gluon/pkgs/container/gluon-build)), pinned in [Dockerfile_build](Dockerfile_build) to the Gluon release from the Makefile. The same container can be used locally:

```sh
docker build -t site-ffm-$(git rev-parse --abbrev-ref HEAD) -f Dockerfile_build .
```

With the following command, the Makefile will then use the repo for building but will run inside the container.\
**Note**: If the working directory is a git worktree, add a volume mount for the main git folder.

```sh
mkdir -p gluon-build output
docker run --rm -v $(pwd):/site-ffm:ro -v $(pwd)/gluon-build:/site-ffm/gluon-build:rw -v $(pwd)/output:/site-ffm/output:rw -w /site-ffm -u $UID site-ffm-$(git rev-parse --abbrev-ref HEAD) make
```

#### Example

Full command for a [lantiq-xrx200](https://github.com/freifunk-gluon/gluon/blob/v2022.1/targets/lantiq-xrx200) build:

```sh
mkdir -p logs gluon-build output
docker run --rm -v $(pwd):/site-ffm:ro -v $(pwd)/gluon-build:/site-ffm/gluon-build:rw -v $(pwd)/output:/site-ffm/output:rw -w /site-ffm -u $UID site-ffm-$(git rev-parse --abbrev-ref HEAD) make V=s GLUON_TARGETS=lantiq-xrx200 |& tee logs/build_lantiq-xrx200_$(date --iso=s).log
```

## Further Resources

This firmware is based on [Gluon](https://gluon.readthedocs.io/).

Look at the [site configuration related Gluon documentation](https://gluon.readthedocs.io/en/latest/user/site.html)
for information on site configuration options and examples from other communities.
