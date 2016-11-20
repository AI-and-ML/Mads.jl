import Mads
import ODE
import DataStructures

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
# Mads.showparameters(md)

# create parameter dictionary
paramdict = DataStructures.OrderedDict(zip(paramkeys, map(key->md["Parameters"][key]["init"], paramkeys)))

# function to create a function for the ODE solver
function makefunc(parameterdict::DataStructures.OrderedDict)
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
t, y = ODE.ode23s(funcosc, initialconditions, times, points=:specified)
ys = hcat(y...)' # vectorizing the output and transposing it with '

# create an observation dictionary in the MADS dictionary
Mads.madsinfo("Create MADS Observations ...")
Mads.createobservations!(md, t, ys[:,1], weight = 10)
Mads.createobservations!(md, t, ys[:,1], weight_type = "inverse", logtransform=true)
Mads.createobservations!(md, Dict("a"=>1,"c"=>1), weight = 10)
Mads.createobservations!(md, Dict("a"=>1,"c"=>1), weight_type = "inverse", logtransform=true)
Mads.createobservations!(md, t, ys[:,1])
Mads.madsinfo("Show MADS Observations ...")
# Mads.showobservations(md)