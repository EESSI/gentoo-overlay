# Scripts

## generate_set_files.py

This Python script can be used to automatically generate the EESSI set files in `/etc/portage/sets` from one common YAML file (`eessi_sets.yml`).
The YAML file defines the supported architectures and the packages that should be installed.
For each packages an attribute `exclude_on` or `include_on` can be used to specify that it should not be installed on a specific architecture,
or only be installed on the listed architecture(s), respectively.

The script can be run in the following way: 
```
generate_set_files.py -y YAMLFILE -d SETSDIR
```
Here, `YAMLFILE` refers to the YAML file with the definitions, and `SETSDIR` to the output directory in which all generated set files will be stored.

This script is also being run as a Github Action, see:
https://github.com/EESSI/gentoo-overlay/blob/main/.github/workflows/generate_sets.yml
