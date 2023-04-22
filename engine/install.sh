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
    echo "-a, ac_url         URL of desired version of Autoconfig archive."
    echo "-o, output_dir     Absolute path to output directory."
    echo "-h, help           Usage info."
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
if [ ! -z $output_dir ];
then
    output_dir=$(pwd)
elif [ ! -d "$output_dir" ];
then
    echo "Error: ${output_dir} does not exist."
    exit 1
fi

echo "Writing files to ${output_dir}"
cd ${output_dir}

# Get nlp engine files
if [ ! -d nlp-engine ];
then
    git clone https://github.com/VisualText/nlp-engine
fi
cd nlp-engine
git submodule update --init --recursive

# Get AutoConfig
if [ -z "$ac_url" ];
then
    ac_url="http://ftpmirror.gnu.org/autoconf-archive/autoconf-archive-2023.02.20.tar.xz"
fi

echo "" 
echo "Getting autoconfig from ${ac_url}"
cd "${output_dir}"
wget "$ac_url"
compressed_ac_file=$(basename -- "$ac_url")
tar -xf "$compressed_ac_file"

unzipped_ac_file="${compressed_ac_file%%.tar.xz}"
if [ -d $unzipped_ac_file ];
then
    cd $unzipped_ac_file
else
    echo "Error: ${unzipped_ac_file} does not exist."
    exit 1
fi

# Get GNULib to handle AutoMake dependency, etc
echo ""
git clone https://git.savannah.gnu.org/git/gnulib.git

# Build GNUlib
echo ""
echo "Building gnulib"
./gnulib/gnulib-tool --import strdup
./configure prefix="$output_dir"
make
make install

# Wait for make
wait

# Now that we have handled dependencies, build AutoConfig
echo ""
echo "Building autoconfig"
cd ${output_dir}
./configure prefix="$output_dir"
make
make install

# Make sure the AC archive path is set in our env
export ACLOCAL_PATH="$output_dir/share/aclocal"

# Finally, set up vcpkg and build with cmake
cd "${output_dir}/nlp-engine/vcpkg"
./bootstrap-vcpkg.sh
./vcpkg install
cd "${output_dir}/nlp-engine"
cd build
cmake ..
cmake --build . --config Debug -- -m
