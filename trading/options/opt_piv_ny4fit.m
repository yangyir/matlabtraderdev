function [estimates, model] = opt_piv_ny4fit(xdata, ydata,weights,start_point)
% Call fminsearch with a random starting point.
model = @piv_ny4;
estimates = fminsearch(model, start_point);
% piv_ny4 accepts curve parameters as inputs, and outputs sse,
% the sum of squares error for A*exp(-lambda*xdata)-ydata,
% and the FittedCurve. FMINSEARCH only needs sse, but we want
% to plot the FittedCurve at the end.
    function [sse, FittedCurve] = piv_ny4(params)
        skew = params(1);
        smile = params(2);
        power = params(3);
        FittedCurve = (1 + skew .* xdata + smile.*xdata.^2).^power;
        FittedCurve = FittedCurve.*weights;
        ErrorVector = FittedCurve - ydata.*weights;
        sse = sum(ErrorVector .^ 2);
    end
end