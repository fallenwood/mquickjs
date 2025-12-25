const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    b.top_level_steps = .{};

    const flags = [_][]const u8{
        "-std=gnu11",
        "-DZIG_BUILD",
        "-D_GNU_SOURCE",
        "-fno-math-errno",
        "-fno-trapping-math",
    };

    // mqjs stdlib
    const mqjsStdlibMod = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });

    mqjsStdlibMod.addCSourceFiles(.{
        .files = &.{
            "mqjs_stdlib.c",
            "mquickjs_build.c",
        },
        .flags = &flags,
    });
    const mqjsStdlibExecutable = b.addExecutable(.{
        .name = "mqjs_stdlib",
        .root_module = mqjsStdlibMod,
    });
    mqjsStdlibExecutable.linkLibC();
    b.installArtifact(mqjsStdlibExecutable);

    // example stdlib
    const exampleStdlibMod = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });

    exampleStdlibMod.addCSourceFiles(.{
        .files = &.{
            "example_stdlib.c",
            "mquickjs_build.c",
        },
        .flags = &flags,
    });
    const exampleStdlibLib = b.addExecutable(.{
        .name = "example_stdlib",
        .root_module = exampleStdlibMod,
    });
    exampleStdlibLib.linkLibC();
    b.installArtifact(exampleStdlibLib);

    // Generate
    const generateMqjsStdlibCmd = b.addRunArtifact(mqjsStdlibExecutable);
    const mqjsStdlibPath = generateMqjsStdlibCmd.captureStdOut();
    const copyMqjsStdlibStep = b.addUpdateSourceFiles();
    copyMqjsStdlibStep.addCopyFileToSource(mqjsStdlibPath, "mqjs_stdlib.h");
    generateMqjsStdlibCmd.step.dependOn(&mqjsStdlibExecutable.step);

    const generateMqjsAtomCmd = b.addRunArtifact(mqjsStdlibExecutable);
    generateMqjsAtomCmd.addArg("-a");
    const mqjsAtomPath = generateMqjsAtomCmd.captureStdOut();
    const copyMqjsAtomStep = b.addUpdateSourceFiles();
    copyMqjsAtomStep.addCopyFileToSource(mqjsAtomPath, "mquickjs_atom.h");
    generateMqjsAtomCmd.step.dependOn(&mqjsStdlibExecutable.step);

    const generateExampleStdlibCmd = b.addRunArtifact(exampleStdlibLib);
    const exampleStdlibPath = generateExampleStdlibCmd.captureStdOut();
    const copyExampleStdlibStep = b.addUpdateSourceFiles();
    copyExampleStdlibStep.addCopyFileToSource(exampleStdlibPath, "example_stdlib.h");

    // mqjs executable
    const mqjsMod = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });

    mqjsMod.addCSourceFiles(.{
        .files = &.{
            "mqjs.c",
            "readline_tty.c",
            "readline.c",
            "mquickjs.c",
            "dtoa.c",
            "libm.c",
            "cutils.c",
        },
        .flags = &flags,
    });
    const mqjsExecutableBinary = b.addExecutable(.{
        .name = "mqjs",
        .root_module = mqjsMod,
    });
    mqjsExecutableBinary.linkLibC();
    b.installArtifact(mqjsExecutableBinary);
    mqjsExecutableBinary.step.dependOn(&copyMqjsStdlibStep.step);
    mqjsExecutableBinary.step.dependOn(&copyMqjsAtomStep.step);

    // example executable
    const exampleExecutableMod = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });
    exampleExecutableMod.addCSourceFiles(.{
        .files = &.{
            "example.c",
            "mquickjs.c",
            "dtoa.c",
            "libm.c",
            "cutils.c",
        },
        .flags = &flags,
    });
    const exampleExecutableBinary = b.addExecutable(.{
        .name = "example",
        .root_module = exampleExecutableMod,
    });
    exampleExecutableBinary.linkLibC();
    b.installArtifact(exampleExecutableBinary);
    exampleExecutableBinary.step.dependOn(&copyExampleStdlibStep.step);

    // dynamic library
    const libmqjsMod = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });

    libmqjsMod.addCSourceFiles(.{
        .files = &.{
            "readline_tty.c",
            "readline.c",
            "mquickjs.c",
            "dtoa.c",
            "libm.c",
            "cutils.c",
        },
        .flags = &flags,
    });

    const dynlib = b.addLibrary(.{
        .linkage = .dynamic,
        .name = "libmqjs",
        .root_module = libmqjsMod,
    });
    dynlib.linkLibC();
    b.installArtifact(dynlib);
    dynlib.step.dependOn(&copyMqjsStdlibStep.step);
    dynlib.step.dependOn(&copyMqjsAtomStep.step);
}
