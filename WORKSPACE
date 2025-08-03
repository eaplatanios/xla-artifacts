workspace(name = "rift-pjrt-sys")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# ----------------------------------------------------
# XLA
# ----------------------------------------------------

XLA_COMMIT = "a12ee15c98cdbc9cb728d00f389a9353c7c8f1d4"

XLA_SHA256 = "8bb449e8f7a4782e83662229d6d6b61e9845f42794cc65eaa7a6cc41a00defaf"

JAX_COMMIT = "24f652832ade6991caf067abc701f1b38c02bc52"

JAX_SHA256 = "b2a2fc74293c8f116104f42c17e5d5aa9e168fb128ee16d20cd41bdd736a62aa"

http_archive(
    name = "xla",
    patch_args = [
        "-p1",
        "--ignore-whitespace",
    ],
    patches = ["//patches:xla.patch"],
    sha256 = XLA_SHA256,
    strip_prefix = "xla-{commit}".format(commit = XLA_COMMIT),
    urls = [
        "https://storage.googleapis.com/mirror.tensorflow.org/github.com/openxla/xla/archive/{commit}.tar.gz".format(commit = XLA_COMMIT),
        "https://github.com/openxla/xla/archive/{commit}.tar.gz".format(commit = XLA_COMMIT),
    ],
)

http_archive(
    name = "jax",
    sha256 = JAX_SHA256,
    strip_prefix = "jax-{commit}".format(commit = JAX_COMMIT),
    urls = [
        "https://storage.googleapis.com/mirror.tensorflow.org/github.com/jax-ml/jax/archive/{commit}.tar.gz".format(commit = JAX_COMMIT),
        "https://github.com/jax-ml/jax/archive/{commit}.tar.gz".format(commit = JAX_COMMIT),
    ],
)

load("@xla//:workspace4.bzl", "xla_workspace4")

xla_workspace4()

load("@xla//:workspace3.bzl", "xla_workspace3")

xla_workspace3()

load("@xla//third_party/py:python_init_rules.bzl", "python_init_rules")

python_init_rules()

load("@xla//third_party/py:python_init_repositories.bzl", "python_init_repositories")

python_init_repositories(
    requirements = {
        "3.11": "@xla//:requirements_lock_3_11.txt",
    },
)

load("@xla//third_party/py:python_init_toolchains.bzl", "python_init_toolchains")

python_init_toolchains()

load("@xla//third_party/py:python_init_pip.bzl", "python_init_pip")

python_init_pip()

load("@pypi//:requirements.bzl", "install_deps")

install_deps()

load("@xla//:workspace2.bzl", "xla_workspace2")

xla_workspace2()

load("@xla//:workspace1.bzl", "xla_workspace1")

xla_workspace1()

load("@xla//:workspace0.bzl", "xla_workspace0")

xla_workspace0()

http_archive(
    name = "rules_ml_toolchain",
    patch_args = [
        "-p1",
        "--ignore-whitespace",
    ],
    patches = ["//patches:rules_ml_toolchain.patch"],
    sha256 = "d486aadba1b4415da16d744e4511c7a35d4d1604c61ed562d37519d5ed072a86",
    strip_prefix = "rules_ml_toolchain-69a7b71c9424ddbcc27cb7814ecfd482510b1947",
    urls = [
        "https://github.com/google-ml-infra/rules_ml_toolchain/archive/69a7b71c9424ddbcc27cb7814ecfd482510b1947.tar.gz",
    ],
)

load(
    "@rules_ml_toolchain//cc/deps:cc_toolchain_deps.bzl",
    "cc_toolchain_deps",
)

cc_toolchain_deps()

register_toolchains("@rules_ml_toolchain//cc:linux_x86_64_linux_x86_64")

register_toolchains("@rules_ml_toolchain//cc:linux_x86_64_linux_x86_64_cuda")

load(
    "@rules_ml_toolchain//third_party/gpus/cuda/hermetic:cuda_json_init_repository.bzl",
    "cuda_json_init_repository",
)

cuda_json_init_repository()

load(
    "@cuda_redist_json//:distributions.bzl",
    "CUDA_REDISTRIBUTIONS",
    "CUDNN_REDISTRIBUTIONS",
)
load(
    "@rules_ml_toolchain//third_party/gpus/cuda/hermetic:cuda_redist_init_repositories.bzl",
    "cuda_redist_init_repositories",
    "cudnn_redist_init_repository",
)

cuda_redist_init_repositories(
    cuda_redistributions = CUDA_REDISTRIBUTIONS,
)

cudnn_redist_init_repository(
    cudnn_redistributions = CUDNN_REDISTRIBUTIONS,
)

load(
    "@rules_ml_toolchain//third_party/gpus/cuda/hermetic:cuda_configure.bzl",
    "cuda_configure",
)

cuda_configure(name = "local_config_cuda")

load(
    "@rules_ml_toolchain//third_party/nccl/hermetic:nccl_redist_init_repository.bzl",
    "nccl_redist_init_repository",
)

nccl_redist_init_repository()

load(
    "@rules_ml_toolchain//third_party/nccl/hermetic:nccl_configure.bzl",
    "nccl_configure",
)

nccl_configure(name = "local_config_nccl")

load(
    "@rules_ml_toolchain//third_party/nvshmem/hermetic:nvshmem_json_init_repository.bzl",
    "nvshmem_json_init_repository",
)

nvshmem_json_init_repository()

load(
    "@nvshmem_redist_json//:distributions.bzl",
    "NVSHMEM_REDISTRIBUTIONS",
)
load(
    "@rules_ml_toolchain//third_party/nvshmem/hermetic:nvshmem_redist_init_repository.bzl",
    "nvshmem_redist_init_repository",
)

nvshmem_redist_init_repository(nvshmem_redistributions = NVSHMEM_REDISTRIBUTIONS)

load("@jax//third_party/flatbuffers:workspace.bzl", flatbuffers = "repo")

flatbuffers()

load("@jax//:test_shard_count.bzl", "test_shard_count_repository")

test_shard_count_repository(name = "test_shard_count")

load("@jax//jaxlib:jax_python_wheel.bzl", "jax_python_wheel_repository")

jax_python_wheel_repository(
    name = "jax_wheel",
    version_key = "_version",
    version_source = "@jax//jax:version.py",
)

load(
    "@xla//third_party/py:python_wheel.bzl",
    "python_wheel_version_suffix_repository",
)

python_wheel_version_suffix_repository(
    name = "jax_wheel_version_suffix",
)

# ----------------------------------------------------
# Bazel
# ----------------------------------------------------

http_archive(
    name = "buildifier_prebuilt",
    sha256 = "f98dd3d8f32661629b8cab11f02d7730bb8e03bd8af09dbbb268047889c8ff10",
    strip_prefix = "buildifier-prebuilt-8.2.0.2",
    urls = [
        "http://github.com/keith/buildifier-prebuilt/archive/8.2.0.2.tar.gz",
    ],
)

# load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

# bazel_skylib_workspace()
