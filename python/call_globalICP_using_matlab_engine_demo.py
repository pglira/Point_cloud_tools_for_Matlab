# Install matlab python engine with "pip install matlab-engine" (requires matlab >= 2022b)
# https://www.mathworks.com/help/matlab/matlab_external/install-the-matlab-engine-for-python.html
import matlab.engine

from pathlib import Path

# Start MATLAB engine
print("Starting MATLAB engine ...")
eng = matlab.engine.start_matlab()
print("MATLAB engine started")

# Add the path to the repo to MATLAB's search path
repository_path = Path("/path/to/Point_cloud_tools_for_Matlab")
eng.addpath(eng.genpath(str(repository_path)))

# Print globalICP help screen for parameter information if needed
eng.ICP(nargout=0)

# Define parameters for globalICP
params = {
    "InFiles": str(repository_path.joinpath("demodata", "lionscan*approx.xyz")),
    "OutputFolder": "python_demo_output",
    "OutputFormat": "xyz",
    "TempFolder": "python_demo_temp",
    "UniformSamplingDistance": 2.0,
    "PlaneSearchRadius": 2.0,
}

# Call globalICP and save the transformation parameters
trafo_params = eng.ICP(params, nargout=1)
