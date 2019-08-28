function [bsout,ssout,lvlupout,lvldnout,bcout,scout] = tdsq_piecewise(data,bsin,ssin,lvlupin,lvldnin,bcin,scin,varargin)
%TDSQ_STEPBYSTEP Summary of this function goes here
%   Detailed explanation goes here
%   Calculate TD Sequential variables in a piecewise approach

    [bsout,ssout,lvlupout,lvldnout] = tdsq_piecewise_setup(data,bsin,ssin,lvlupin,lvldnin,varargin{:});
    
    [bcout,scout] = tdsq_piecewise_countdown(data,bsout,ssout,lvlupout,lvldnout,bcin,scin);
    
end

