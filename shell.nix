let
  pkgs =
    import
    (
      fetchTarball
      "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz"
    ) {};
in {
  # "pure" nixpkgs version. Simplest to use and recommended unless you have to use
  # the latest bleeding edge or something not available on nixpkgs.
  nix-pure = pkgs.mkShell {
    packages = [
      (pkgs.python3.withPackages (pp: [
        # insert all needed python packages that are available in NixPkgs
        # might need to fix additional dependencies for some packages.
        # look below.
        # pp.numpy
        # pp.requests
        # ....
      ]))
    ];
    shellHook = ''
      echo "Welcome to a pure nix python shell! -- WARNING: do not use pip."
    '';
  };

  # Use pip to install all python packages.
  nix-pip = pkgs.mkShell {
    packages = [
      (pkgs.python3.withPackages (pp: [
        pp.pip
      ]))
    ];

    shellHook = ''
      if [ ! -d .venv ]; then
        python -m venv .venv
      fi

      source .venv/bin/activate

      echo "Activated python venv -- WARNING: may need to handle dependencies."
    '';

    # We may need to handle dependencies.
    # For example, after doing pip install numpy, we get an
    # error when we import it. This error is related to the
    # LD_LIBRARY_PATH and we have to fix it by adding additional
    # packages.
    env.LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      pkgs.stdenv.cc.cc
      pkgs.zlib
    ];
  };

  jupyter-dask = pkgs.mkShell {
    packages = [
      (pkgs.python3.withPackages (pp: [
        pp.dask
        pp.distributed
        pp.dask-ml

        # for Dask Dashboard
        pp.bokeh

        # for jupyter notebook (basics, for more advanced use jupyenv)
        pp.ipython
        pp.jupyter

        # graph visualization
        pp.graphviz
      ]))
    ];
    shellHook = ''
      echo "Welcome to a pure nix python shell! -- WARNING: do not use pip."
    '';
  };
}
