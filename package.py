# Packages lambda with all dependencies as a zip archive for deployment

from os import remove
from os.path import abspath, exists
from shutil import rmtree, copytree, make_archive
from subprocess import run

ARCHIVE_NAME = "aws-samples-lambda-python-cloudwatch-rds"
CODE_FOLDER = "code"


def main():
    cleanup()

    build_package()


def cleanup():
    remove(ARCHIVE_NAME) if exists(ARCHIVE_NAME) else None
    rmtree("package", ignore_errors=True)


def build_package():
    copytree(CODE_FOLDER, "package")
    run(["pip", "install", "-r", abspath("package/requirements.txt"), "-t", abspath("package")])
    make_archive(ARCHIVE_NAME, 'zip', 'package')


if __name__ == "__main__":
    main()
