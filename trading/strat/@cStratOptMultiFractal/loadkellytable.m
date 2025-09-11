function [] = loadkellytable(obj,varargin)
% a cStratOptMultiFractal public method
% to load empirical kelly tables based on intraday (30m) data
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Directory','',@ischar);
    p.addParameter('FileName','',@ischar);
    p.parse(varargin{:});
    dir_ = p.Results.Directory;
    fn_ = p.Results.FileName;
    
    try
        d = load([dir_,fn_]);
        props = fields(d);
        obj.kellytable_ = d.(props{1});
    catch
        fprintf('cStratOptMultiFractal:load_kelly_intraday:error!!!\n')
    end
