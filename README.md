# remoll-builder

Setup a spack environment, similar to
```
spack:
  specs:
    - geant4 cxxstd=11
    - boost cxxstd=11
    - root -opengl cxxstd=11
  packages:
    all:
      target:
      - x64_64
  concretization: together
  config:
    install_missing_compilers: true
    install_tree: /opt/software
  view: /opt/view
```
Exact details may vary; please check `Dockerfile`.
