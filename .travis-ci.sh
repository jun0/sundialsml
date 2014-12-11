#!/bin/sh

case $TRAVIS_OS_NAME in
linux)
        # We assume Ubuntu.
        case "$OCAML_VERSION,$OPAM_VERSION" in
        3.12.1,1.2.0) ppa=avsm/ocaml312+opam11 ;;
        4.00.1,1.2.0) ppa=avsm/ocaml40+opam11 ;;
        4.01.0,1.2.0) ppa=avsm/ocaml41+opam11 ;;
        4.02.0,1.2.0) ppa=avsm/ocaml42+opam11 ;;
        *)            echo Unknown $OCAML_VERSION,$OPAM_VERSION; exit 1 ;;
        esac
        echo "yes" | sudo add-apt-repository ppa:$ppa
        sudo apt-get update -qq
        sudo apt-get install -qq libsundials-serial-dev ocaml ocaml-native-compilers opam
        case $OCAML_MPI in
            yes) OPAM_DEPS="ocamlfind mpi"
                 sudo apt-get install openmpi-bin
                 ;;
            no)  OPAM_DEPS="ocamlfind";;
            *)   echo "Unrecognized OCAML_MPI: ${OCAML_MPI}"
                exit 1;;
        esac
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

