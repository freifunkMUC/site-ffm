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

As the CI is using Ubuntu, only the Ubuntu dependencies are being tracked. To simplify building on other distros, containerised building is also possible:
```sh
docker build -t site-ffm -f Dockerfile_build .
```
This will build the build Docker image. With the following export, the Makefile will then use the repo for building but will run inside an Ubuntu container.\
**Note**: If the working directory is a git worktree, add a volume mount for the main git folder.
```sh
docker run --rm -v $(pwd):/site-ffm:ro -v $(pwd)/gluon-build:/site-ffm/gluon-build:rw -v $(pwd)/output:/site-ffm/output:rw -w /site-ffm -u $UID site-ffm-next make
```

#### Example
Full command for a [lantiq-xrx200](https://github.com/freifunk-gluon/gluon/blob/v2022.1/targets/lantiq-xrx200) build:

```sh
mkdir -p logs
docker run --rm -v $(pwd):/site-ffm:ro -v $(pwd)/gluon-build:/site-ffm/gluon-build:rw -v $(pwd)/output:/site-ffm/output:rw -w /site-ffm -u $UID site-ffm-next make V=s BROKEN=1 GLUON_TARGETS=lantiq-xrx200 |& tee logs/buildtest_lantiq-xrx200_$(date --iso=s).log
```

## Further Resources

This firmware is based on [Gluon](https://gluon.readthedocs.io/en/v2021.1/).

Look at the [site configuration related Gluon documentation](https://gluon.readthedocs.io/en/v2021.1/user/site.html)
for information on site configuration options and examples from other communities.
