import Mads
using Base.Test

callbacksucceeded = false
@everywhere function callback(x_best, of, lambda)
	global callbacksucceeded
	callbacksucceeded = true
	println("The callback function was called: $x_best")
end

info("Levenberg-Marquardt optimization of the Rosenbrock function with callback")
results = Mads.levenberg_marquardt(Mads.rosenbrock_lm, Mads.rosenbrock_gradient_lm, [0.0, 0.0]; show_trace=false, callback=callback)
@test callbacksucceeded