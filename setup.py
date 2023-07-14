from setuptools import setup

setup(
    name='py-codegen',
    version='0.0.1',
    description='Code generation library',
    packages=[
        'codegen'
    ],
    install_requires=[
        'pynvim',
    ],
    package_dir={"codegen": "codegen"},
)
