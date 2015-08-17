#!/usr/bin/env python
# 
# Helper script to download cryptobox-ios binaries from github 



import urllib2
import argparse
import sys
import tempfile
import shutil
import os
import tarfile
import errno



class TemporaryDirectory(object):
    def __enter__(self):
        self.name = tempfile.mkdtemp()
        return self.name

    def __exit__(self, exc_type, exc_value, traceback):
        shutil.rmtree(self.name)

def create_download_url(version, verbose=False):
	number = None
	if version[0] is not "v":
		number = version
		version = "v" + version
	else:
		number = version[1:]
	if number is None:
		return None
	return "https://github.com/romanb/cryptobox-ios/releases/download/%s/cryptobox-ios-%s.tar.gz" % (version, number)

def download_archive(to_dir, url, verbose=False):
	archive_url = urllib2.urlopen(url)
	archive_name = 'archive.tar.gz'
	path = os.path.join(to_dir, archive_name)
	if verbose:
		print "Downloading to archive to '%s'" % (path)
	output = open(path, 'wb')
	output.write(archive_url.read())
	output.close()
	return path

def unpack(archive_path, dir):
	tfile = tarfile.open(archive_path, 'r:gz')
	to_path = os.path.join(dir, 'unpacked')
	tfile.extractall(to_path)
	return to_path

def copy_libraries(src, dst):
    try:
        shutil.copytree(src, dst)
    except OSError as exc: 
        if exc.errno == errno.ENOTDIR:
            shutil.copy(src, dst)
        else: raise

def project_library_dir():
	return os.path.join(os.getcwd(), "build")

if __name__ == "__main__":
	parser = argparse.ArgumentParser()
	parser.add_argument("-lv", "--lib_version", help="The version tag", default=None)
	parser.add_argument("-v", "--verbose", help="increase output verbosity", action="store_true")
	args = parser.parse_args()

	version = args.lib_version
	if version is None:
		print "Missing version tag. Use fetch-lib-from-github.py -lv <VERSION>"
		sys.exit(1)
	print "Downloading cryptobox-ios dependencies. Requested version: '%s'" % (version)
	url = create_download_url(version, args.verbose)
	if url is None:
		print "Could't create version url"
		sys.exit(1)

	if args.verbose:
		print "Github release url: '%s'" % (url)

	with TemporaryDirectory() as tmp_dir:
		archive_path = download_archive(tmp_dir, url, args.verbose)
		if args.verbose:
			print "Downloaded archive to '%s' directory" % (archive_path)
		unarchived_path = unpack(archive_path, tmp_dir)
		if args.verbose:
			print "Unarchived to '%s' directory" % (unarchived_path)

		library_dir = project_library_dir()
		if args.verbose:
			print "Using '%s' as project libraries directory" % (library_dir)

		if os.path.exists(library_dir):
			shutil.rmtree(library_dir)

		copy_libraries(unarchived_path, library_dir)

	print "Fin."
