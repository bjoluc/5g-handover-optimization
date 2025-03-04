import shutil
from pathlib import Path

from Cython.Build import build_ext, cythonize  # type: ignore
from setuptools import Distribution, Extension

CYTHON_DIR = Path("ue_power_model_5g") / "sleep_ratio"
extension = Extension(
    "ue_power_model_5g.sleep_ratio.simulation",
    [CYTHON_DIR / "simulation.py"],
    extra_compile_args=["-fopenmp"],
    extra_link_args=["-fopenmp"],
)

ext_modules = cythonize([extension], include_path=[CYTHON_DIR], language_level="3str")
dist = Distribution({"ext_modules": ext_modules})

cmd = build_ext(dist)
cmd.ensure_finalized()
cmd.run()

for output in cmd.get_outputs():
    output = Path(output)
    shutil.copyfile(output, output.relative_to(cmd.build_lib))
