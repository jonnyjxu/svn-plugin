import os
import subprocess
import shutil
import xml.etree.ElementTree as ET

from buildenv import env, BitcodeBuildFailure
from cmdtool import Clang, Swift, Ld, CopyFile
from verifier import clang_option_verifier, ld_option_verifier, \
    swift_option_verifier
from translate import SwiftArgTranslator, ClangCC1Translator


class xar(object):

    """xar class"""
    XAR_EXEC = "/usr/bin/xar"

    def __init__(self, xar_path):
        if os.path.isfile(xar_path):
            self.input = xar_path
        else:
            env.error(u"Input XAR doesn't exist: {}".format(xar_path))

        cmd = [self.XAR_EXEC, "-d", "-", "-f", self.input]
        try:
            out = subprocess.check_output(cmd)
        except subprocess.CalledProcessError:
            env.error(u"toc cannot be extracted: {}".format(xar_path))
        else:
            self.xml = ET.fromstring(out)
        self.dir = env.createTempDirectory()
        cmd = [self.XAR_EXEC, "-x", "-C", self.dir, "-f", self.input]
        try:
            out = subprocess.check_output(cmd)
        except subprocess.CalledProcessError:
            env.error(u"XAR cannot be extracted: {}".format(xar_path))
        cmd = ['/bin/chmod', "-R", "+r", self.dir]
        try:
            out = subprocess.check_output(cmd)
        except subprocess.CalledProcessError:
            env.error(u"Permission fixup failed: {}".format(xar_path))

    @property
    def subdoc(self):
        return self.xml.find("subdoc")

    @property
    def toc(self):
        return self.xml.find("toc")


class BitcodeBundle(xar):

    """BitcodeBundle class"""

    def __init__(self, arch, input_xar, output_path):
        self.output = os.path.realpath(output_path)
        self.returncode = 0
        self.stdout = ""
        self.arch = arch
        self.is_executable = False
        self.contain_swift = False
        super(BitcodeBundle, self).__init__(input_xar)
        try:
            self.platform = self.subdoc.find("platform").text
            self.sdk_version = self.subdoc.find("sdkversion").text
            self.version = self.subdoc.find("version").text
        except AttributeError:
            env.error("Malformed Header for bundle")
        else:
            env.setVersion(self.version)
            env.setPlatform(self.platform)

    def __repr__(self):
        return self.stdout

    @property
    def linkOptions(self):
        """Return all the link options"""
        linker_options = [x.text if x.text is not None else "" for x in
                          self.subdoc.find("link-options").findall("option")]
        if not ld_option_verifier.verify(linker_options):
            env.error(u"Linker option verification "
                      "failed for bundle {} ({})".format(
                          self.input,
                          ld_option_verifier.error_msg))
        if linker_options.count("-execute") != 0:
            self.is_executable = True
        if self.platform is not None and self.platform != "Unknown":
            linker_options.extend(["-syslibroot", env.getSDK()])
        if self.sdk_version is not None and self.sdk_version != "NA":
            linker_options.extend(["-sdk_version", self.sdk_version])
        return linker_options

    @property
    def contain_symbols(self):
        try:
            return (self.subdoc.find("hide-symbols").text == '0')
        except AttributeError:
            return True

    @property
    def forceload_compiler_rt(self):
        try:
            return (self.subdoc.find("rt-forceload").text == '1')
        except AttributeError:
            return False

    def run_job(self, job):
        """Run sub command and catch errors"""
        try:
            rv = job.run()
        except BitcodeBuildFailure:
            # Catch and log an error
            env.error(u"Failed to compile bundle: {}".format(self.input))
        else:
            return rv

    def getFileNode(self, file_type):
        """Return all the XML node of file type"""
        return filter(lambda x: x.find("file-type").text == file_type,
                      self.toc.findall("file"))

    def constructBitcodeJob(self, xml_node):
        """construct a single bitcode workload"""
        name = xml_node.find("name").text
        output_name = name + ".o"
        if xml_node.find("clang") is not None:
            clang = Clang(name, output_name, self.dir)
            options = [x.text if x.text is not None else ""
                       for x in xml_node.find("clang").findall("cmd")]
            options = ClangCC1Translator.translate(options)
            if (clang_option_verifier.verify(options)):
                clang.addArgs(options)
            else:
                env.error(u"Clang option verification "
                          "failed for bitcode {} ({})".format(
                              name, clang_option_verifier.error_msg))
            return clang
        elif xml_node.find("swift") is not None:
            # swift uses extension to distinguish input type
            # we need to move the file to have .bc extension first
            self.contain_swift = True
            if env.compile_with_clang:
                clang = Clang(name, output_name, self.dir)
                options = [x.text if x.text is not None else ""
                           for x in xml_node.find("swift").findall("cmd")]
                if (swift_option_verifier.verify(options)):
                    clang.addArgs(
                        SwiftArgTranslator.translate(options))
                else:
                    env.error(u"Swift option verification "
                              "failed for bitcode {} ({})".format(
                                  name, clang_option_verifier.error_msg))
                return clang
            else:
                bcname = name + ".bc"
                shutil.move(os.path.join(self.dir, name),
                            os.path.join(self.dir, bcname))
                swift = Swift(bcname, output_name, self.dir)
                options = [x.text if x.text is not None else ""
                           for x in xml_node.find("swift").findall("cmd")]
                if (swift_option_verifier.verify(options)):
                    swift.addArgs(options)
                else:
                    env.error(u"Swift option verification "
                              "failed for bitcode {} ({})".format(
                                  name, swift_option_verifier.error_msg))
                return swift
        else:
            env.error("Cannot figure out bitcode kind: {}".format(name))

    def constructBundleJob(self, xml_node):
        """construct a single XAR bundle workload"""
        name = os.path.join(self.dir, xml_node.find("name").text)
        output_name = name + ".o"
        xar_job = BitcodeBundle(self.arch, name, output_name)
        return xar_job

    def constructObjectJob(self, xml_node):
        """construct the job to build object which is just a copy"""
        name = os.path.join(self.dir, xml_node.find("name").text)
        output_name = name + ".o"
        object_job = CopyFile(name, output_name, self.dir)
        object_job.output = output_name
        return object_job

    def run(self):
        """Build Bitcode Bundle"""
        linker_inputs = []
        linker = Ld(self.output, self.dir)
        linker.addArgs(["-arch", self.arch])
        linker.addArgs(self.linkOptions)
        # handle bitcode input
        bitcode_files = self.getFileNode("Bitcode")
        if len(bitcode_files) > 0:
            compiler_jobs = map(self.constructBitcodeJob, bitcode_files)
            linker_inputs.extend(compiler_jobs)
        # object input
        object_files = self.getFileNode("Object")
        if len(object_files) > 0:
            if env.getPlatform() == "watchos":
                env.error("Watch platform doesn't support object inputs")
            object_jobs = map(self.constructObjectJob, object_files)
            linker_inputs.extend(object_jobs)
        # run compilation
        env.map(self.run_job, linker_inputs)
        # run bundle compilation in sequential to avoid dead-lock
        bundle_files = self.getFileNode("Bundle")
        if len(bundle_files) > 0:
            bundle_jobs = map(self.constructBundleJob, bundle_files)
            map(self.run_job, bundle_jobs)
            linker_inputs.extend(bundle_jobs)
        # sort object inputs
        inputs = sorted([os.path.basename(x.output) for x in linker_inputs])
        # handle LTO inputs
        LTO_inputs = self.getFileNode("LTO")
        if (len(LTO_inputs)) != 0:
            inputs.extend([x.find("name").text for x in LTO_inputs])
            linker.addArgs(["-flto-codegen-only"])
        # add inputs to a LinkFileList
        LinkFileList = os.path.join(self.dir, self.output + ".LinkFileList")
        with open(LinkFileList, 'w') as f:
            for i in inputs:
                f.write(os.path.join(self.dir, i))
                f.write('\n')
        linker.addArgs(["-filelist", LinkFileList])
        # version specific arguments
        if env.satifiesLinkerVersion("253.2"):
            linker.addArgs(["-ignore_auto_link"])
        if env.satifiesLinkerVersion("253.3.1"):
            linker.addArgs(["-allow_dead_duplicates"])
        # add libLTO.dylib if needed
        if env.liblto is not None:
            linker.addArgs(["-lto_library", env.liblto])
        # handle dylibs
        dylibs_node = self.subdoc.find("dylibs")
        if dylibs_node is not None:
            for lib_node in dylibs_node.iter():
                if lib_node.tag == "lib":
                    lib_path = env.resolveDylibs(self.arch, lib_node.text)
                    linker.addArgs([lib_path])
                elif lib_node.tag == "weak":
                    # allow weak framework to be missing. If they provide no
                    # symbols, the link will succeed.
                    lib_path = env.resolveDylibs(self.arch, lib_node.text,
                                                 True)
                    if lib_path is not None:
                        linker.addArgs(["-weak_library", lib_path])

        # add swift library search path, only when auto-link cannot be ignored.
        if self.contain_swift and not env.satifiesLinkerVersion("253.2"):
            swiftLibPath = env.getlibSwiftPath(self.arch)
            if swiftLibPath is not None:
                linker.addArgs(["-L", swiftLibPath])
        # add libclang_rt
        if self.forceload_compiler_rt:
            linker.addArgs(["-force_load"])
        linker.addArgs([env.getlibclang_rt(self.arch)])
        # linking
        self.run_job(linker)

        return self
