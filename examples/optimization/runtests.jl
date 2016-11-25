import Mads
import Base.Test

workdir = Mads.getmadsdir() # get the directory where the problem is executed
if workdir == ""
	workdir = Mads.madsdir * "/../examples/optimization/"
end

if Mads.long_tests
	Mads.madsinfo("External optimization ...")

	md = Mads.loadmadsfile(workdir * "external-jld.mads")
	jparam, jresults = Mads.calibrate(md, maxEval=2, np_lambda=1, maxJacobians=1)

	if !haskey(ENV, "MADS_NO_PYTHON")
		md = Mads.loadmadsfile(workdir * "external-yaml.mads")
		yparam, yresults = Mads.calibrate(md, maxEval=2, np_lambda=1, maxJacobians=1)
		@Base.Test.test yparam == jparam
	end
end

include(workdir * "optimization-lm.jl")
include(workdir * "optimization_rosenbrock.jl")
include(workdir * "optimization_callback.jl")
include(workdir * "optimization_linear_problem.jl")
# include(workdir * "optimization_linear_problem_nlopt.jl") # requires NLopt
include(workdir * "optimization_linear_problem+template.jl")

Mads.addkeyword!(md, "ssdr")
Mads.residuals(md)

p = Mads.getparamdict(md)
f = Mads.makemadscommandfunctionandgradient(md) # make MADS command gradient function
f(p)
f = Mads.makemadscommandgradient(md)
f(p)