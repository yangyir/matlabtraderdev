function sh = wrmacopperfun(x,freq,nperiod)
% define pairs to accept vectorized inputs and return only sharpe ratio

[row,~] = size(x);
sh  = zeros(row,1);

% run simulation
parfor i = 1:row
[~,~,sh(i)] = bkfunc_wrma_copper( 'SampleFrequency',[num2str(freq),'m'],...
        'NPeriod',nperiod,...
        'Lead',x(i,1),...
        'Lag',x(i,2));
end







