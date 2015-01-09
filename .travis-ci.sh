#!/bin/sh -e

function build_sundials_c () {
    instroot=`pwd`
    wget http://archive.ubuntu.com/ubuntu/pool/universe/s/sundials/sundials_2.5.0.orig.tar.gz || exit 1
    tar -axf sundials_2.5.0.orig.tar.gz || exit 1
    cd sundials-2.5.0/ || exit 1
    # MPI should be detected automatically
    ./configure --enable-shared --prefix "$instroot/sundials" || exit 1
    make || exit 1
    make install || exit 1
    cd .. || exit 1
}

case $TRAVIS_OS_NAME in
linux)
        # We assume Ubuntu.
        case "$OCAML_VERSION,$OPAM_VERSION" in
        3.12.1,1.2.0) ppa=avsm/ocaml312+opam12 ;;
        4.00.1,1.2.0) ppa=avsm/ocaml40+opam12 ;;
        4.01.0,1.2.0) ppa=avsm/ocaml41+opam12 ;;
        4.02.0,1.2.0) ppa=avsm/ocaml42+opam12 ;;
        *)            echo Unknown $OCAML_VERSION,$OPAM_VERSION; exit 1 ;;
        esac
        echo "yes" | sudo add-apt-repository ppa:$ppa
        sudo apt-get update -qq
        sudo apt-get install ocaml ocaml-native-compilers opam
        case $OCAML_MPI in
            yes) OPAM_DEPS="ocamlfind mpi"
                 sudo apt-get install openmpi-bin libopenmpi-dev
                 ;;
            no)  OPAM_DEPS="ocamlfind";;
            *)   echo "Unrecognized OCAML_MPI: ${OCAML_MPI}"
                 exit 1;;
        esac
        echo "Checking sundials version: dpkg -l libsundials-serial-dev | grep 2.5.0"
        if dpkg -l libsundials-serial-dev | grep 2.5.0; then
            echo "2.5.0 seems to be available"
            sudo apt-get install -qq libsundials-serial-dev
        else
            echo "2.5.0 not found; building from source"
            sudo apt-get install wget
            build_sundials_c || exit 2
            export PATH="`pwd`/sundials/bin:$PATH"
        fi
       ;;
osx)
        brew update
        brew install sundials ocaml opam
        case "$OCAML_VERSION,$OPAM_VERSION" in
        3.12.1,1.1.1) echo "Skipping this configuration."; exit 0 ;;
        4.00.1,1.1.1) echo "Skipping this configuration."; exit 0 ;;
        4.01.0,1.1.1) echo "Skipping this configuration."; exit 0 ;;
        4.02.0,1.1.1) ;;
        *)            echo Unknown $OCAML_VERSION,$OPAM_VERSION; exit 1 ;;
        esac

        case $OCAML_MPI in
            yes) OPAM_DEPS="ocamlfind mpi"
                 brew install open-mpi
                 ;;
            no)  OPAM_DEPS="ocamlfind";;
            *)   echo "Unrecognized OCAML_MPI: ${OCAML_MPI}"
                exit 1;;
        esac
       ;;
esac

export OPAMYES=1
export OPAMVERBOSE=1

echo "OCaml version (system)"
ocaml -version
echo OPAM versions
opam --version
opam --git-version

opam init
eval `opam config env`
opam install ${OPAM_DEPS}
./configure
make

