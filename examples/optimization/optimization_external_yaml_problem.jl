using Mads

info("Levenberg-Marquardt optimization of an external problem using YAML files ...")
workdir = Mads.getmadsdir() # get the directory where the problem is executed
if workdir == ""
	workdir = Mads.madsdir * "/../examples/optimization/"
end
md = Mads.loadmadsfile(workdir * "external-yaml.mads")
results = Mads.calibrate(md, maxEval=2, maxIter=1, maxJacobians=1, np_lambda=2)
