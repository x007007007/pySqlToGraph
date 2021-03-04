import os
import re
import sys
import fnmatch
from os.path import join
from distutils import sysconfig
from setuptools import find_packages, setup


# package_data depending on system

setup(
    name='pyGbaseAnaylsis',
    description='',
    # author=find_meta("author"),
    # maintainer=find_meta("maintainer"),
    # license=find_meta("license"),
    # url=find_meta("uri"),
    version='0.1',
    # keywords=KEYWORDS,
    # long_description=read("README.md"),
    long_description_content_type="text/markdown",
    packages=find_packages(where="src"),
    package_data={'pyFlexBison': []},
    package_dir={
        "": "src",
    },
    zip_safe=False,
    # classifiers=CLASSIFIERS,
    install_requires=[
        "six",
        "setuptools"
    ],
    setup_requires=[
        'Cython'
    ],
    # py_modules=PY_MODULES,
    # scripts=SCRIPTS,
)
