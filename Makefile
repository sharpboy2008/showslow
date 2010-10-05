all:	update userbase dbupgrade assets

update:
	svn update

userbase:
	rm -rf __users_export
	svn export http://svn.github.com/sergeychernyshev/UserBase.git __users_export
	rm -rf users
	mv __users_export/users .
	rm -rf __users_export

dbupgrade:
	php dbupgrade.php

rel:	release
release: assets
ifndef v
	# Must specify version as 'v' param
	#
	#   make rel v=1.1.1
	#
else
	#
	# Tagging it with release tag
	#
	svn copy . https://showslow.googlecode.com/svn/tags/REL_${subst .,_,${v}}/
	#
	# Creating release tarball and zip
	#
	svn export https://showslow.googlecode.com/svn/tags/REL_${subst .,_,${v}}/ showslow_${v}

	# copying userbase there too
	rm -rf __users_export
	svn export http://svn.github.com/sergeychernyshev/UserBase.git __users_export
	mv __users_export/users showslow_${v}/
	rm -rf __users_export

	# Not including Makefile into the package since it's not doing anything but release packaging
	tar -c showslow_${v} |gzip > showslow_${v}.tgz
	zip -r showslow_${v}.zip showslow_${v}
	rm -rf showslow_${v}
	# upload to Google Code repository (need account with enough permissions)
	googlecode/googlecode_upload.py -s "ShowSlow v${v} (tarball)" -p showslow -l "Featured,Type-Archive,OpSys-All" showslow_${v}.tgz
	googlecode/googlecode_upload.py -s "ShowSlow v${v} (zip)" -p showslow -l "Featured,Type-Archive,OpSys-All" showslow_${v}.zip
	rm showslow_${v}.tgz showslow_${v}.zip
endif

timeplot-patch:
	patch -p0 <timeplot.patch

# from svn-assets project
clean: noassets

assets:
	svn status --verbose --xml |php svn-assets/svnassets.php > asset_versions.php

# uncomment next line when we'll have any CSS files to process
#find ./ -name '*.css' -not -wholename "./timeplot/*" -not -wholename "./timeline/*" -not -wholename "./ajax/*" -not -wholename "./users/*" | xargs -n1 php svn-assets/cssurlrewrite.php

noassets:
	cp svn-assets/no-assets.php asset_versions.php
	find ./ -name '*_deploy.css' | xargs -n10 rm -f
