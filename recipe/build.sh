#!/bin/bash

if [[ ${build_platform} != ${target_platform} ]]; then
    case ${target_platform} in
        linux-aarch64)
            cargo_target_args="-DRust_CARGO_TARGET=aarch64-unknown-linux-gnu"
            ;;
        linux-ppc64le)
            cargo_target_args="-DRust_CARGO_TARGET=powerpc64le-unknown-linux-gnu"
            ;;
        osx-arm64)
            cargo_target_args="-DRust_CARGO_TARGET=aarch64-apple-darwin"
            ;;
        *)
            echo "Unsupported cross-compilation target: ${target_platform}"
            exit 1
            ;;
    esac
fi

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cmake -S . -B build \
    ${CMAKE_ARGS} \
  -DSYSTEM_CORROSION=ON \
  ${cargo_target_args}

cmake --build build --parallel ${CPU_COUNT}
ctest -V --test-dir build --parallel ${CPU_COUNT}
cmake --install build

# Install shell completions
# (fish and zsh are already installed by `cmake --install` to the correct paths)
install -d "${PREFIX}/share/bash-completion/completions"
install "scripts/bash/task.sh" "${PREFIX}/share/bash-completion/completions/task"
