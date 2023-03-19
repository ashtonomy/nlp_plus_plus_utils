#!/bin/bash
#
# Download and set up the NLP Engine in the Palmetto Cluster.
#
# Note: This should only need to be run once to setup, with
# the exception of the modules. Also, no guarantees on this,
# as there are quite a few dependencies involved. It should 
# at the very least give an outline of build requirements
# running on the Palmetto Cluster.
#
# Tested on:
# nlp-engine: v2.7.0

# ADD MODULES.
# Delete OpenSSL after adding cmake to avoid dependency errors
module add gcc/9.5.0
module add cmake/3.23.1-gcc/9.5.0
module del openssl/1.1.1o-gcc/9.5.0

# Read command line arguments
output_dir=''
ac_url=''

print_help() {
    echo ""
    echo "Palmetto NLP++ Engine Setup Script"
    echo ""
    echo "Usage: $(basename $0) [-o arg] [-h]"
    echo "Options:"
    echo "-a, --ac_url         URL of desired version of Autoconfig archive."
    echo "-o, --output_dir     Absolute path to output directory."
    echo "-h, --help           Usage info."
    echo ""
}

while getopts 'o:h' flag; do
    case "${flag}" in
        a | ac_url) ac_url="${OPTARG}" ;;
        o | output_dir) output_dir="${OPTARG}" ;;
        h | help) print_help
            exit 1 ;;
    esac
done

# Check validity of output_dir
if $output_dir;
then
    output_dir=$(pwd)
elif (! test -f "$output_dir");
then
    echo "Error: ${output_dir} does not exist."
    exit 1
fi

echo "Writing files to ${output_dir}"
cd ${output_dir}

# Get nlp engine files
git clone https://github.com/VisualText/nlp-engine
cd nlp-engine

# Get AutoConfig
if ! "$ac_url";
then
    ac_url = http://ftpmirror.gnu.org/autoconf-archive/autoconf-archive-2023.02.20.tar.xz
fi

wget "$ac_url"
compressed_ac_file=$(basename $ac_url)
tar -xf "$compressed_ac_file"
IFS='.' read -r -a unzipped_ac_file <<< "$compressed_ac_file"
cd unzipped_ac_file

# Get GNULib to handle AutoMake dependency, etc
git clone https://git.savannah.gnu.org/git/gnulib.git

# Build GNUlib
cd gnulib
./configure prefix="$output_dir"
make
make install

# Now that we have handled dependencies, build AutoConfig
cd ..
./configure prefix="$output_dir"
make
make install

# Make sure the AC archive path is set in our env
export ACLOCAL_PATH="$output_dir/share/aclocal"

# Finally, set up vcpkg and build with cmake
cd ../vcpkg
./bootstrap-vcpkg.sh
./vcpkg install
cd ..
mkdir build
cd build
cmake ..
cmake --build . --config Debug -- -m