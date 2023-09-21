#!/bin/bash

INSTALL_DIR=/tmp/INSTALL_DIR/dakota

if [[ -z "${SKIP_SETUP}" ]]; then

  mkdir -p $INSTALL_DIR

  yum install wget -y
  yum install lapack-devel -y

  update-alternatives --install /usr/bin/python python /usr/local/bin/python3.11 20
  update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.11 20
  update-alternatives --auto python
  update-alternatives --auto python3

  python -m venv myvenv
  source myvenv/bin/activate

  pip install numpy

  wget https://github.com/snl-dakota/dakota/releases/download/v6.18.0/dakota-6.18.0-public-src-cli.tar.gz
  tar xf dakota-6.18.0-public-src-cli.tar.gz
fi

cd dakota-6.18.0-public-src-cli

mkdir build
cd build

export PATH=/tmp/INSTALL_DIR/bin:$PATH
export LD_LIBRARY_PATH=/tmp/INSTALL_DIR/lib:$LD_LIBRARY_PATH

export PYTHON_ROOT_DIR=$(python3 -c "import sys; print(sys.prefix)")
export PYTHON_INCLUDE_DIR=$(python -c "import sysconfig; print(sysconfig.get_path('include'))")
export PYTHON_LIBRARY=$(python -c "import sysconfig; print(sysconfig.get_config_var('LIBDIR'))")

echo $PYTHON_ROOT_DIR
echo $PYTHON_INCLUDE_DIR
echo $PYTHON_LIBRARY

cmake \
      -DCMAKE_CXX_STANDARD=14 \
      -DBUILD_SHARED_LIBS=ON \
      -DDAKOTA_PYTHON_DIRECT_INTERFACE=ON \
      -DDAKOTA_PYTHON_DIRECT_INTERFACE_NUMPY=ON \
      -DDAKOTA_DLL_API=OFF \
      -DHAVE_X_GRAPHICS=OFF \
      -DDAKOTA_ENABLE_TESTS=OFF \
      -DDAKOTA_ENABLE_TPL_TESTS=OFF \
      -DCMAKE_BUILD_TYPE="Release" \
      -DDAKOTA_NO_FIND_TRILINOS:BOOL=TRUE \
      -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
      -DPython3_INCLUDE_DIRS=$(python -c "import sysconfig; print(sysconfig.get_path('include'))")  \
      -DPython3_LIBRARIES=$(python -c "import sysconfig; print(sysconfig.get_config_var('LIBDIR'))") \
      -DPYTHON_EXECUTABLE=$(which python) \
      -DCMAKE_DISABLE_FIND_PACKAGE_Python=TRUE \
      ..

#make -j8 install
