load("@com_google_protobuf//bazel/common:proto_info.bzl", "ProtoInfo")
load("@rules_cc//cc/common:cc_info.bzl", "CcInfo")

STRIP_PREFIXES = [
    "external/llvm-project/mlir/include/",
    "external/shardy/",
    "external/stablehlo/",
    "external/xla/",
]

HEADERS = [
    "jaxlib/mosaic/gpu/integrations/c/passes.h",
    "mlir-c/IR.h",
    "mlir-c/RegisterEverything.h",
    "mlir-c/Support.h",
    "mlir-c/Dialect/AMDGPU.h",
    "mlir-c/Dialect/Arith.h",
    "mlir-c/Dialect/Async.h",
    "mlir-c/Dialect/ControlFlow.h",
    "mlir-c/Dialect/EmitC.h",
    "mlir-c/Dialect/Func.h",
    "mlir-c/Dialect/GPU.h",
    "mlir-c/Dialect/Index.h",
    "mlir-c/Dialect/IRDL.h",
    "mlir-c/Dialect/Linalg.h",
    "mlir-c/Dialect/LLVM.h",
    "mlir-c/Dialect/Math.h",
    "mlir-c/Dialect/MemRef.h",
    "mlir-c/Dialect/MLProgram.h",
    "mlir-c/Dialect/NVGPU.h",
    "mlir-c/Dialect/NVVM.h",
    "mlir-c/Dialect/OpenMP.h",
    "mlir-c/Dialect/PDL.h",
    "mlir-c/Dialect/Quant.h",
    "mlir-c/Dialect/ROCDL.h",
    "mlir-c/Dialect/SCF.h",
    "mlir-c/Dialect/Shape.h",
    "mlir-c/Dialect/SMT.h",
    "mlir-c/Dialect/SparseTensor.h",
    "mlir-c/Dialect/SPIRV.h",
    "mlir-c/Dialect/Tensor.h",
    "mlir-c/Dialect/Transform.h",
    "mlir-c/Dialect/Vector.h",
    "shardy/integrations/c/attributes.h",
    "shardy/integrations/c/dialect.h",
    "shardy/integrations/c/passes.h",
    "stablehlo/integrations/c/ChloAttributes.h",
    "stablehlo/integrations/c/ChloDialect.h",
    "stablehlo/integrations/c/StablehloAttributes.h",
    "stablehlo/integrations/c/StablehloDialect.h",
    "stablehlo/integrations/c/StablehloPasses.h",
    "stablehlo/integrations/c/StablehloDialectApi.h",
    "stablehlo/integrations/c/StablehloUnifiedApi.h",
    "stablehlo/integrations/c/StablehloTypes.h",
    "stablehlo/integrations/c/InterpreterDialect.h",
    "stablehlo/integrations/c/VhloDialect.h",
    "xla/mlir_hlo/bindings/c/Attributes.h",
    "xla/mlir_hlo/bindings/c/Dialects.h",
    "xla/mlir_hlo/bindings/c/Passes.h",
    "xla/mlir_hlo/bindings/c/Types.h",
    "xla/pjrt/c/pjrt_c_api.h",
    "xla/pjrt/c/pjrt_c_api_ffi_extension.h",
    "xla/pjrt/c/pjrt_c_api_layouts_extension.h",
    "xla/pjrt/c/pjrt_c_api_memory_descriptions_extension.h",
    "xla/pjrt/c/pjrt_c_api_phase_compile_extension.h",
    "xla/pjrt/c/pjrt_c_api_profiler_extension.h",
    "xla/pjrt/c/pjrt_c_api_raw_buffer_extension.h",
    "xla/pjrt/c/pjrt_c_api_stream_extension.h",
    "xla/pjrt/c/pjrt_c_api_triton_extension.h",
    "xla/service/spmd/shardy/integrations/c/passes.h",
]

def _build_archive_impl(ctx):
    output = ctx.actions.declare_file(ctx.label.name + ".tar.gz")

    protos = []
    td_files = []
    headers = []
    libraries = []

    if ProtoInfo in ctx.attr.rift_pjrt_sys_protos:
        proto_info = ctx.attr.rift_pjrt_sys_protos[ProtoInfo]
        transitive_proto_sources = proto_info.transitive_sources.to_list()
        transitive_descriptors = proto_info.transitive_descriptor_sets.to_list()
        proto_files = transitive_proto_sources + transitive_descriptors
        for output_file in proto_files:
            path = output_file.short_path
            if path.startswith("../xla/"):
                path = path[len("../xla/"):]
                protos.append((output_file, path))

    if CcInfo in ctx.attr.rift_pjrt_sys_headers:
        cc_info = ctx.attr.rift_pjrt_sys_headers[CcInfo]

        # Get headers from the compilation context.
        for header in cc_info.compilation_context.headers.to_list():
            path = header.path
            for prefix in STRIP_PREFIXES:
                if path.startswith(prefix):
                    path = path[len(prefix):]
            if path in HEADERS:
                headers.append((header, path))

    if DefaultInfo in ctx.attr.rift_pjrt_sys_td_files:
        for output_file in ctx.attr.rift_pjrt_sys_td_files[DefaultInfo].files.to_list():
            path = output_file.path
            for prefix in STRIP_PREFIXES:
                if path.startswith(prefix):
                    path = path[len(prefix):]
            td_files.append((output_file, path))

    # Collect output files from DefaultInfo.
    if DefaultInfo in ctx.attr.rift_pjrt_sys_library:
        for output_file in ctx.attr.rift_pjrt_sys_library[DefaultInfo].files.to_list():
            libraries.append(output_file)
    if ctx.attr.rift_pjrt_sys_windows_interface_library:
        if DefaultInfo in ctx.attr.rift_pjrt_sys_windows_interface_library:
            for output_file in ctx.attr.rift_pjrt_sys_windows_interface_library[DefaultInfo].files.to_list():
                # TODO(eaplatanios): Rename `rift_pjrt_sys.if.lib` to `rift_pjrt_sys.lib`.
                libraries.append(output_file)

    copy_commands = []
    for proto, path in protos:
        copy_commands.append("""
            target_dir="$archive_dir/protos/$(dirname "{path}")"
            mkdir -p "$target_dir"
            chmod 755 "$target_dir"

            cp "{proto}" "$archive_dir/protos/{path}"
            chmod 644 "$archive_dir/protos/{path}"
        """.format(
            proto = proto.path,
            path = path,
        ))
    for td_file, path in td_files:
        copy_commands.append("""
            target_dir="$archive_dir/td/$(dirname "{path}")"
            mkdir -p "$target_dir"
            chmod 755 "$target_dir"

            cp "{td_file}" "$archive_dir/td/{path}"
            chmod 644 "$archive_dir/td/{path}"
        """.format(
            td_file = td_file.path,
            path = path,
        ))
    for header, path in headers:
        copy_commands.append("""
            target_dir="$archive_dir/include/$(dirname "{path}")"
            mkdir -p "$target_dir"
            chmod 755 "$target_dir"

            cp "{header}" "$archive_dir/include/{path}"
            chmod 644 "$archive_dir/include/{path}"
        """.format(
            header = header.path,
            path = path,
        ))

    # # Set permissions based on file type
    # if [[ "$filename" == *.so ]] || [[ "$filename" == *.so.* ]] || [[ "$filename" == *.dylib ]] || [[ "$filename" == *.dll ]]; then
    #     # Shared libraries need execute permission
    #     chmod 755 "$archive_dir/$relative_path"
    # elif [[ "$filename" == *.a ]]; then
    #     # Static libraries don't need execute permission
    #     chmod 644 "$archive_dir/$relative_path"
    # else
    #     # Default for headers and other files
    #     chmod 644 "$archive_dir/$relative_path"
    # fi

    for library in libraries:
        copy_commands.append("""
            if [[ -f "{library}" ]]; then
                library="{library}"

                if [[ "$library" =~ bazel-out/[^/]+/bin/(.*) ]]; then
                    # For generated files, use the path after bin/
                    library="${{BASH_REMATCH[1]}}"
                fi

                target_dir="$archive_dir/lib/$(dirname "$library")"
                mkdir -p "$target_dir"
                chmod 755 "$target_dir"

                cp "{library}" "$archive_dir/lib/$library"
                chmod 755 "$archive_dir/lib/$library"
            fi
        """.format(
            library = library.path,
        ))

    ctx.actions.run_shell(
        inputs = [proto[0] for proto in protos] + [td_file[0] for td_file in td_files] + [header[0] for header in headers] + libraries,
        outputs = [output],
        command = """
            set -e
            archive_dir=$(mktemp -d)
            chmod 755 "$archive_dir"

            {copy_commands}

            if [[ "$OSTYPE" == "darwin"* ]]; then
                tar -C "$archive_dir" -czf "{output}" .
            else
                # TODO(eaplatanios): Should this use 777 instead?
                tar -C "$archive_dir" --mode=644 -czf "{output}" .
            fi
            rm -rf "$archive_dir"
        """.format(
            copy_commands = "\n".join(copy_commands),
            output = output.path,
        ),
    )

    return [DefaultInfo(files = depset([output]))]

build_archive = rule(
    implementation = _build_archive_impl,
    attrs = {
        "rift_pjrt_sys_protos": attr.label(providers = [ProtoInfo]),
        "rift_pjrt_sys_td_files": attr.label(providers = [DefaultInfo]),
        "rift_pjrt_sys_headers": attr.label(providers = [CcInfo]),
        "rift_pjrt_sys_library": attr.label(providers = [DefaultInfo]),
        "rift_pjrt_sys_windows_interface_library": attr.label(providers = [DefaultInfo]),
    },
)
