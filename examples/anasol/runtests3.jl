import Mads
import JLD
import Base.Test

srand(2017)

workdir = joinpath(Mads.madsdir, "..", "examples", "anasol")
md = Mads.loadmadsfile(joinpath(workdir, "w01purebig.mads"))
ns = 10
rsetdict = Mads.getparamrandom(md, ns)
rsetarray = hcat(map(i->rsetdict[i], keys(rsetdict))...)'
rsetarrayplus = [repmat([823], ns)'; repmat([1499], ns)'; repmat([3], ns)'; rsetarray; repmat([15], ns)']
Mads.vectoron()
computeconcentrations = Mads.makedoublearrayfunction(md)
@time rv = computeconcentrations(rsetarrayplus);
# this is slow because concentration function is created each time
#rfs = Array{Float64}(ns);
#@time for i = 1:ns
#    rfs[i] = Mads.forward(md, rsetarrayplus[:, i])
#end

Mads.vectoroff()
@time rf = Mads.forward(md, rsetarray);

# rv == rf

include("/Users/monty/Julia/FastMadsAnasol.jl/base.jl")
@makemadslikeanasol madslike "w01purebig.mads"
ra = Array{Float64}(ns);
for i = 1:ns
    ra[i] = madslike(rsetarray[:, i])[1]
end
@time for i = 1:ns
	ra[i] = madslike(rsetarray[:, i])[1]
end