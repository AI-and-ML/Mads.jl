import DataStructures
import DocumentFunction

"""
Parse Amanzi output provided in an external file (`filename`)

$(DocumentFunction.documentfunction(amanzi_output_parser;
argtext=Dict("filename"=>"external file name [default=`\"observations.out\"`]")))

Returns:

- dictionary with model observations following MADS requirements

Example:

```julia
Mads.amanzi_output_parser()
Mads.amanzi_output_parser("observations.out")
```
"""
function amanzi_output_parser(filename::String="observations.out")
	d = readdlm(filename, ',', skipstart=2)
	no = size(d)[1]
	mads@info("Number of observations $(no)")
	w = map(i->strip(i), d[:,2])
	mads@info("Number of wells $(length(unique(w)))")
	time = d[:,5]
	mads@info("Number of observation times $(length(unique(time)))")
	obs = d[:,6]
	head_index = find(d[:,4] .== " hydraulic head")
	cr_index = find(d[:,4] .== " Chromium aqueous concentration")
	mads@info("Number of head observations $(length(head_index))")
	mads@info("Number of chromium observations $(length(cr_index))")
	flag = Array{Char}(no)
	flag[head_index] = 'h'
	flag[cr_index] = 'c'
	obs_name = Array{String}(no)
	for i = 1:no
		obs_name[i] = w[i] * "$(flag[i])" * "_" * "$(@sprintf("%.1f", time[i]))"
	end
	dict = DataStructures.OrderedDict{String,Float64}(zip(obs_name, obs))
	return dict
end
