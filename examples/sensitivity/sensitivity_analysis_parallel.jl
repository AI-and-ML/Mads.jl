using Mads
using Base.Test

problemdir = Mads.getmadsdir()

info("Parallel Saltelli sensitivity analysis: Sobol test ...")
mdsobol = Mads.loadmadsfile(problemdir * "sobol.mads")
results = Mads.saltelliparallel(mdsobol, N=500, 2)
Mads.printSAresults(mdsobol, results)

info("Parallel Saltelli sensitivity analysis: Linear problem ...")
mdsaltelli = Mads.loadmadsfile(problemdir * "saltelli.mads")
results = Mads.saltelliparallel(mdsaltelli, N=500, 2)
Mads.printSAresults(mdsaltelli, results)

if isdir("saltellirestart")
	rm("saltellirestart", recursive=true)
end
results1 = Mads.saltelliparallel(mdsaltelli, 2; seed=2016, N=500, restartdir="saltellirestart")
results2 = Mads.saltelliparallel(mdsaltelli, 2; seed=2016, N=500, restartdir="saltellirestart")
@test results1 == results2
rm("saltellirestart", recursive=true)

if isdir("saltellicheckpoint")
	rm("saltellicheckpoint", recursive=true)
end
results1 = Mads.saltelli(mdsaltelli; N=5000, restartdir="saltellicheckpoint", checkpointfrequency=1000, parallel=true, seed=2016)
results2 = Mads.saltelli(mdsaltelli; N=5000, restartdir="saltellicheckpoint", checkpointfrequency=1000, parallel=true, seed=2016)
@test results1 == results2
rm("saltellicheckpoint", recursive=true)
# Mads.madsinfo("Parallel Saltelli sensitivity analysis (brute force): Sobol test:") # TODO Brute force needs to be fixed
# mdsobol = Mads.loadmadsfile("sobol.mads")
# results = Mads.saltellibruteparallel(mdsobol, 2) # Slow
# Mads.saltelliprintresults2(mdsobol, results)

# Mads.madsinfo("Parallel Saltelli sensitivity analysis (brute force): Linear problem:")
# mdsaltelli = Mads.loadmadsfile("saltelli.mads")
# results = Mads.saltellibruteparallel(mdsaltelli,2) # Slow
# Mads.saltelliprintresults2(mdsaltelli, results)
