PHP_ARG_WITH(imagick, whether to enable the imagick extension,
[ --with-imagick[=DIR]	Enables the imagick extension. DIR is the prefix to Imagemagick installation directory.], no)

PHP_ARG_WITH(imagick-gm, whether to enable the imagick GraphicsMagick backend,
[ --with-imagick-gm[=DIR]	GraphicsMagick backend. NO LONGER SUPPORTED!], no, no)

if test $PHP_IMAGICK_GM != "no"; then
	AC_MSG_ERROR(GraphicsMagick backend is no longer supported)
fi

if test $PHP_IMAGICK != "no"; then

        if test -r $PHP_IMAGICK/bin/Wand-config; then
                WAND_CONFIG_PATH=$PHP_IMAGICK/bin
        else
                AC_MSG_CHECKING(Wand-config in default path)

                for i in /usr/local /usr;
                do
                        test -r $i/bin/Wand-config && WAND_CONFIG_PATH=$i/bin && break
                done

                if test -z "$WAND_CONFIG_PATH"; then
                        for i in $PHP_IMAGICK /usr/local /usr;
                        do
                                test -r $i/Wand-config && WAND_CONFIG_PATH=$i && break
                        done
                fi
                if test -z "$WAND_CONFIG_PATH"; then
                        AC_MSG_ERROR(Cannot locate configuration program Wand-config)
                else
                        AC_MSG_RESULT(found in $WAND_CONFIG_PATH)
                fi
        fi

		WAND_DIR=`$WAND_CONFIG_PATH/Wand-config --prefix`
		AC_MSG_CHECKING(for magick-wand.h header file)

		if test -r $WAND_DIR/include/wand/magick-wand.h; then
				AC_MSG_RESULT(found in $WAND_DIR/include/wand/magick-wand.h)
		else
				AC_MSG_ERROR(Cannot locate header file magick-wand.h)
		fi


		IMAGEMAGICK_VERSION_ORIG=`$WAND_CONFIG_PATH/Wand-config --version`
		IMAGEMAGICK_VERSION_MASK=`echo ${IMAGEMAGICK_VERSION_ORIG} | awk 'BEGIN { FS = "."; } { printf "%d", ($1 * 1000 + $2) * 1000 + $3;}'`


		AC_MSG_CHECKING(if ImageMagick version is at least 6.2.4)
		if test "$IMAGEMAGICK_VERSION_MASK" -ge 6002004; then
				AC_MSG_RESULT(found version $IMAGEMAGICK_VERSION_ORIG)
		else
				AC_MSG_ERROR(no. You need at least Imagemagick version 6.2.4 to use Imagick.)
		fi

		dnl Thanks to Antony Dovgal for pointing out that the
		dnl earlier version would not have worked if compiling
		dnl statically and no php-config present.

		AC_MSG_CHECKING(if PHP version is at least 5.1.3)

		tmp_version=$PHP_VERSION
		if test -z "$tmp_version"; then
    		if test -z "$PHP_CONFIG"; then
      			AC_MSG_ERROR([php-config not found])
    		fi
   			IMAGICK_PHP_VERSION_ORIG=`$PHP_CONFIG --version`;
		else
			IMAGICK_PHP_VERSION_ORIG=$tmp_version
		fi

		if test -z $IMAGICK_PHP_VERSION_ORIG; then
			AC_MSG_ERROR([failed to detect PHP version, please report])
		fi

		IMAGICK_PHP_VERSION_MASK=`echo ${IMAGICK_PHP_VERSION_ORIG} | awk 'BEGIN { FS = "."; } { printf "%d", ($1 * 1000 + $2) * 1000 + $3;}'`

		if test $IMAGICK_PHP_VERSION_MASK -ge 5001003; then
				AC_MSG_RESULT(found version $IMAGICK_PHP_VERSION_ORIG)
		else
				AC_MSG_ERROR(no. You need at least PHP version 5.1.3 to use Imagick.)
		fi

		AC_DEFINE(HAVE_IMAGICK,1,[ ])

		PHP_ADD_LIBRARY_WITH_PATH(Magick, $WAND_DIR/lib, IMAGICK_SHARED_LIBADD)
		PHP_ADD_LIBRARY_WITH_PATH(Wand, $WAND_DIR/lib, IMAGICK_SHARED_LIBADD)
		PHP_ADD_INCLUDE($WAND_DIR/include)
		PHP_SUBST(IMAGICK_SHARED_LIBADD)
		PHP_NEW_EXTENSION(imagick, imagick.c, $ext_shared)

fi
