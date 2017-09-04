function delta = straddledelta(s,k,r,t,sigma)
d1 = log(s/k)+(r+0.5*sigma^2)*t;
d1 = d1/(sigma*sqrt(t));
calldelta = normcdf(d1);
putdelta = -normcdf(-d1);
delta = calldelta+putdelta;
end