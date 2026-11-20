#!/usr/bin/env bash
# 构建上游 botan（configure.py + make）→ <out>/prefix。
# 只编基线需要的模块：sha2_32 / aes / ctr。--cpu=generic 让两侧走同一份代码路径，
# 否则 configure.py 会按宿主 CPU 打开 NEON 之类，基线就不再可比。
set -euo pipefail
SRC=$1
OUT=$2
MARCH=${3:-rv64gcv}
KERN=${4:-0}
EXTRA_CXX=()
if [ "$KERN" = "1" ]; then EXTRA_CXX=("--extra-cxxflags=-march=${MARCH} -DRVV_KERNELS=1 -Isrc/riscv -Isrc/src/riscv"); fi
rm -rf "${OUT}"
mkdir -p "${OUT}/prefix" "${OUT}/src"
cp -R "${SRC}" "${OUT}/src/pkg"
cd "${OUT}/src/pkg"
# botan 没有 --host：交叉靠 --cc-bin + --os + sysroot + --ar-command
HOST_ARG=""
if [ -n "${HOST:-}" ]; then
  HOST_ARG="--cc-bin=${CXX:-riscv64-linux-gnu-g++} --os=linux --with-sysroot-dir=/usr/riscv64-linux-gnu --ar-command=riscv64-linux-gnu-ar"
fi
python3 configure.py --prefix="${OUT}/prefix" ${HOST_ARG} \
  --build-targets=static --without-documentation --disable-shared \
  --minimized-build --enable-modules=sha2_32,aes,ctr \
  --cpu=generic "${EXTRA_CXX[@]}" >/dev/null
make -j"$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)" >/dev/null 2>&1
make install >/dev/null 2>&1
echo "== 上游 botan 构建完成：${OUT}/prefix"
