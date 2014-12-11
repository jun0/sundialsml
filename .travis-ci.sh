#!/bin/sh

case $TRAVIS_OS_NAME in
linux)
        # We assume Ubuntu.
        case "$OCAML_VERSION,$OPAM_VERSION" in
        3.12.1,1.1.1) ppa=avsm/ocaml312+opam11 ;;
        4.00.1,1.1.1) ppa=avsm/ocaml40+opam11 ;;
        4.01.0,1.1.1) ppa=avsm/ocaml41+opam11 ;;
        *)            echo Unknown $OCAML_VERSION,$OPAM_VERSION; exit 1 ;;
        esac
        echo "yes" | sudo add-apt-repository ppa:$ppa
        sudo apt-get update -qq
        sudo apt-get install -qq libsundials-serial-dev ocaml ocaml-native-compilers opam
       ;;
osx)
        brew update
        brew install sundials ocaml opam
        ;;
esac

case $OCAML_MPI in
yes) OPAM_DEPS="ocamlfind mpi";;
no)  OPAM_DEPS="ocamlfind";;
*)   echo "Unrecognized OCAML_MPI: ${OCAML_MPI}"
     exit 1;;
esac

opam init
eval `opam config env`
# If the system compiler is the right version, try that instead.
# There are significant differences from opam install <ver>.
if ! ocaml -version | grep -q $OCAML_VERSION; then
    opam switch $OCAML_VERSION
    eval `opam config env`
    echo "OCaml version (opam)"
    ocaml -version
else
    echo "OCaml version (system)"
    ocaml -version
fi
echo OPAM versions
opam --version
opam --git-version

opam install ${OPAM_DEPS}
./configure
make

