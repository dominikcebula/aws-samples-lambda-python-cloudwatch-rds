# Packages lambda with all dependencies as a zip archive for deployment

from os import remove
from os.path import abspath, exists
from shutil import rmtree, copytree, make_archive
from subprocess import run

import venv

ARCHIVE_NAME = "aws-samples-lambda-python-cloudwatch-rds.zip"
CODE_FOLDER = "code"


def main():
    remove(ARCHIVE_NAME) if exists(ARCHIVE_NAME) else None
    rmtree("package", ignore_errors=True)
    rmtree("venv", ignore_errors=True)

    venv.create("venv", with_pip=True)
    copytree(CODE_FOLDER, "package")
    run(["venv/bin/pip", "install", "-r", abspath("package/requirements.txt"), "-t", abspath("package")], cwd=".")
    make_archive('aws-samples-lambda-python-cloudwatch-rds.zip', 'zip', 'package')


if __name__ == "__main__":
    main()
