#!/bin/bash

# Exit on any error
set -e

# Define installation directories
INSTALL_DIR=~/dialer
LIB_INSTALL_DIR=/usr/local/lib
INCLUDE_INSTALL_DIR=/usr/local/include

# Function to clean up old files
clean_old_files() {
    echo "Cleaning up old files..."

    # Remove old baresip, libre, and librem directories
    rm -rf $INSTALL_DIR/baresip
    rm -rf $INSTALL_DIR/re
    rm -rf $INSTALL_DIR/rem

    # Remove old installed libraries and includes
    sudo rm -f $LIB_INSTALL_DIR/libre.a $LIB_INSTALL_DIR/libre.so
    sudo rm -f $LIB_INSTALL_DIR/librem.a $LIB_INSTALL_DIR/librem.so
    sudo rm -rf $INCLUDE_INSTALL_DIR/re
    sudo rm -rf $INCLUDE_INSTALL_DIR/rem

    # Update the shared library cache
    sudo ldconfig

    echo "Old files cleaned."
}

# Function to install dependencies
install_dependencies() {
    echo "Installing dependencies..."
    sudo apt-get update
    sudo apt-get install -y build-essential git cmake libssl-dev libasound2-dev libpulse-dev \
    libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libvpx-dev \
    libopus-dev libx264-dev libsdl2-dev libxcb-shm0-dev libxcb-xfixes0-dev pkg-config
    echo "Dependencies installed."
}

# Function to clone and build libre
build_libre() {
    echo "Cloning and building libre..."
    git clone https://github.com/baresip/re.git $INSTALL_DIR/re
    cd $INSTALL_DIR/re
    mkdir -p build
    cd build
    cmake ..
    make

    # Copy header files directly from include directory
    if [ -d "$INSTALL_DIR/re/include" ]; then
        sudo cp -r "$INSTALL_DIR/re/include/"* $INCLUDE_INSTALL_DIR/
        echo "libre headers installed from $INSTALL_DIR/re/include."
    else
        echo "Error: libre headers not found!"
        exit 1
    fi

    # Install libre
    sudo cp libre.a $LIB_INSTALL_DIR/
    sudo cp libre.so $LIB_INSTALL_DIR/
    sudo ldconfig
    echo "libre built and installed."
}

# Function to clone and build librem
build_librem() {
    echo "Cloning and building librem..."
    git clone https://github.com/baresip/rem.git $INSTALL_DIR/rem
    cd $INSTALL_DIR/rem
    mkdir -p build
    cd build
    cmake ..
    make

    # Copy header files directly from include directory
    if [ -d "$INSTALL_DIR/rem/include" ]; then
        sudo cp -r "$INSTALL_DIR/rem/include/"* $INCLUDE_INSTALL_DIR/
        echo "librem headers installed from $INSTALL_DIR/rem/include."
    else
        echo "Error: librem headers not found!"
        exit 1
    fi

    # Install librem
    sudo cp librem.a $LIB_INSTALL_DIR/
    sudo cp librem.so $LIB_INSTALL_DIR/
    sudo ldconfig
    echo "librem built and installed."
}

# Function to clone and build baresip
build_baresip() {
    echo "Cloning and building baresip..."
    git clone https://github.com/baresip/baresip.git $INSTALL_DIR/baresip
    cd $INSTALL_DIR/baresip
    cmake -B build
    cmake --build build -j

    # Optionally install baresip globally
    sudo cmake --install build
    echo "Baresip built and installed."
}

# Run the script

clean_old_files
install_dependencies
build_libre
build_librem
build_baresip

echo "Baresip installation complete. You can run it with 'baresip'."
