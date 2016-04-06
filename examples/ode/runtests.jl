using Mads
using ODE
using JSON
using Gadfly
using DataStructures

# load parameter data from MADS YAML file
Mads.madsinfo("Loading data ...")
workdir = Mads.getmadsdir() # get the directory where the problem is executed
if workdir == ""
	workdir = Mads.madsdir * "/../examples/ode/"
end

md = Mads.loadmadsfile(workdir * "ode.mads")
rootname = Mads.getmadsrootname(md)

# get parameter keys
paramkeys = Mads.getparamkeys(md)
Mads.showparameters(md)

# create parameter dictionary
paramdict = OrderedDict(zip(paramkeys, map(key->md["Parameters"][key]["init"], paramkeys)))

# function to create a function for the ODE solver
function makefunc(parameterdict::OrderedDict)
	# ODE parameters
	omega = parameterdict["omega"]
	k = parameterdict["k"]
	function func(t, y) # function needed by the ODE solver
		# ODE: x''[t] == -\omega^2 * x[t] - k * x'[t]
		f = similar(y)
		f[1] = y[2] # u' = v
		f[2] = -omega * omega * y[1] - k * y[2] # v' = -omega^2*u - k*v
		return f
	end
	return func
end

# create a function for the ODE solver
funcosc = makefunc(paramdict)
Mads.madsinfo("Solve ODE ...")
times = collect(0:.1:100)
initialconditions = [1.,0.]
t, y = ode23s(funcosc, initialconditions, times, points=:specified)
ys = hcat(y...)' # vectorizing the output and transposing it with '

# draw initial solution
p = Gadfly.plot(layer(x=t, y=ys[:,1], Geom.line,Theme(default_color=parse(Colors.Colorant, "orange"))), layer(x=t,y=ys[:,2],Geom.line))
Gadfly.draw(Gadfly.SVG(string("$rootname-solution.svg"),6inch,4inch),p)

# create an observation dictionary in the MADS dictionary
Mads.madsinfo("Create MADS Observations ...")
Mads.createobservations!(md, t, ys[:,1])
Mads.madsinfo("Show MADS Observations ...")
# Mads.showobservations(md)

Mads.madsinfo("Global sensitivity analysis ...")
saltelliresult = Mads.efast(md, seed=20151001)
if !haskey(ENV, "MADS_NO_PLOT")
	Mads.plotobsSAresults(md, saltelliresult; xtitle = "Time", ytitle = "State variable")
end

Mads.madsinfo("Spaghetti plots over the prior parameter ranges ...")
if !haskey(ENV, "MADS_NO_PLOT")
	Mads.spaghettiplot(md, 100; obs_plot_dots=false, keyword="prior", seed=20151001)
	Mads.spaghettiplots(md, 100; obs_plot_dots=false, keyword="prior", seed=20151001)
end

Mads.madsinfo("Local sensitivity analysis ...")
localsaresult = Mads.localsa(md, format="png")
stddev = localsaresult["stddev"]

Mads.madsinfo("Posterior ranges at the initial (prior) optimal estimate ...")
f = open("$rootname-localsa-paramranges.dat", "w")
for i in 1:length(paramkeys)
	println(f, md["Parameters"][paramkeys[i]]["init"]-3*stddev[i]," < ",md["Parameters"][paramkeys[i]]["longname"], " < ", md["Parameters"][paramkeys[i]]["init"]+3*stddev[i])
end
close(f)

Mads.madsinfo("Bayesian sampling ...")
mcmcchain = Mads.bayessampling(md)

Mads.madsinfo("Bayesian scatter plots ...")
if !haskey(ENV, "MADS_NO_PLOT")
	Mads.scatterplotsamples(md, mcmcchain.value', rootname * "-bayes.svg")
end

# convert the parameters in the chain to a parameter dictionary of arrays
mcmcvalues = Mads.paramarray2dict(md, mcmcchain.value') 

if !haskey(ENV, "MADS_NO_PLOT")
	info("Posterior (Bayesian) spaghetti plots ...")
	Mads.spaghettiplots(md, mcmcvalues, keyword="posterior", obs_plot_dots=false)
	Mads.spaghettiplot(md, mcmcvalues, keyword="posterior", obs_plot_dots=false)
end