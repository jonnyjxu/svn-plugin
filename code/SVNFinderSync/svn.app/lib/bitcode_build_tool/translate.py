"""Translates various options/names for build compatibility"""
import os


class ClangCC1Translator:
    ARG_MAP = {
        "apcs-vfp": "aapcs16"
    }

    @staticmethod
    def translate(opts):
        return [ClangCC1Translator.ARG_MAP[x]
                if x in ClangCC1Translator.ARG_MAP else x
                for x in opts]


class SwiftArgTranslator:

    TO_CLANG = {
        "-frontend": "-cc1",
        "-emit-object": "-emit-obj",
        "-target": "-triple",
        "-Xllvm": "-mllvm",
        "-Onone": "-O0",
        "-O": "-Os",
        # meaningless but just map to some clang cc1 option
        "-module-name": "-main-file-name",
        "-parse-stdlib": "-stdlib=libc++"
    }

    @staticmethod
    def translate(opts):
        return [SwiftArgTranslator.TO_CLANG[x]
                if x in SwiftArgTranslator.TO_CLANG else x
                for x in opts]


class FrameworkUpgrader:

    """Handle system frameworks/dylibs upgrade"""
    LIBRARY_MAP = {
        "/usr/lib/libextension":
            "/System/Library/Frameworks/Foundation.framework/Foundation"
    }

    @staticmethod
    def translate(lib):
        libname = os.path.splitext(lib)[0]
        return FrameworkUpgrader.LIBRARY_MAP.get(libname, lib)
