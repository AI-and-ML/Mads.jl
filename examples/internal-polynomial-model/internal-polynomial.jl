import Mads
import DataStructures

function makemadsmodelrun_internal_polynomial(madsdata::Associative)
	times = Mads.getobstime(madsdata)
	names = Mads.getobskeys(madsdata)
	function madsmodelrun(parameters::Associative) # model run
		f(t) = parameters["a"] * (t ^ parameters["n"]) + parameters["b"] * t + parameters["c"] # a * t^n + b * t + c
		predictions = DataStructures.OrderedDict{String, Float64}(zip(names, map(f, times)))
		return predictions
	end
end
