import DataStructures

function mamkemadsmodelrun_internal_linearmodel(madsdata::Associative)
	function madsmodelrun(parameters::Associative) # model run
		f(t) = parameters["a"] * t - parameters["b"] # a * t - b
		times = 1:4
		predictions = DataStructures.OrderedDict{String, Float64}(zip(map(i -> string("o", i), times), map(f, times)))
		return predictions
	end
	return madsmodelrun
end
