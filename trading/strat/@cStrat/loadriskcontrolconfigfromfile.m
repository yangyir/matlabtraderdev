function [] = loadriskcontrolconfigfromfile(obj,varargin)
%cStrat
if isempty(obj.riskcontrols_)
    obj.riskcontrols_ = cStratConfigArray;
end

obj.riskcontrols_.loadfromfile(varargin{:});

ninstrument = obj.riskcontrols_.latest_;

for i = 1:ninstrument
    obj.registerinstrument(obj.riskcontrols_.node_(i).codectp_);
end


end