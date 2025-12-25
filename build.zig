const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

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
    const mqjsStdlibLib = b.addExecutable(.{
        .name = "mqjs_stdlib",
        .root_module = mqjsStdlibMod,
    });
    mqjsStdlibLib.linkLibC();
    b.installArtifact(mqjsStdlibLib);

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
}
