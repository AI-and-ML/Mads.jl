@doc "Load ASCII file" ->
function loadasciifile(filename::AbstractString) # load ASCII text file
	data = open(readdlm, filename)
	return data
end

@doc "Dump ASCII file" ->
function dumpasciifile(filename::AbstractString, data) # dump ASCII text file
	writedlm(filename, data)
end

@doc "Read MADS predictions from an ASCII file" ->
function readasciipredictions(filename::AbstractString) # read ASCII text predictions
	return loadasciifile(filename)
end
