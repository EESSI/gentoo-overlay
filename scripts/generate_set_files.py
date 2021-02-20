#!/usr/bin/env python3
#
# Generate Gentoo package set files based on an YAML input file.
#
import argparse
import yaml
import sys

def is_supported(package, arch):
    """
    Return if a given package is supported on the given architecture.
    package: dict having at least a 'name' key, optionally 'exclude_on_archs' (list) and 'only_on_arch' (str)
    arch: str representing an architecture name
    """
    return not arch in package.get('exclude_on_archs', []) \
        and arch in package.get('only_on_arch', [arch])


def parse_args():
    """
    Parse the input arguments and return the populated namespace.
    """
    parser = argparse.ArgumentParser(description='Generate Gentoo package set files.')
    parser.add_argument('-y', '--yaml-file', dest='yamlfile', required=True,
                        help='YAML input file with architecture and set definitions.')
    parser.add_argument('-d', '--sets-dir', dest='setsdir', required=True,
                        help='Output directory for storing the set files.')
    args = parser.parse_args()
    return args


def parse_yaml_file(filename):
    """
    Parse the given YAML file, and return the specified architecture and set defintions.
    """
    archs = []
    sets = []

    with open(filename, 'r') as stream:
        try:
            y = yaml.safe_load(stream)
            archs = y['eessi_archs']
            sets = y['eessi_sets']
        except yaml.YAMLError as exc:
            sys.stderr.write("Error while parsing the given YAML file:\n")
            sys.stderr.write(str(exc) + '\n')
            sys.exit(1)

    return (archs, sets)


def main():
    """
    Main function.
    """
    args = parse_args()
    archs, sets = parse_yaml_file(args.yamlfile)

    # Create a set file with the supported packages for every listed architecture and set definition
    for arch in archs:
       for set in sets:
           supported_packages = [package['name'] + '\n' for package in set['packages'] if is_supported(package, arch)]
           with open(f"{args.setsdir}/{set['name']}-{arch}", 'w') as setfile:
               setfile.writelines(supported_packages)


if __name__ == '__main__':
    main()
