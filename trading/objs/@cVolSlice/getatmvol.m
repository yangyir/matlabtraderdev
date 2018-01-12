function atmvol = getatmvol(obj)
%ATM (at-the-money)
k = obj.strikes_;
iv = obj.ivs_;
f = obj.underlier_spot_;
m = log(k./f);

end

