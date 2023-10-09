function [] = load_kelly_daily(obj,varargin)
% a cStratFutMultiFractal public method
% to load empirical kelly tables based on daily data
%     error('cStratFutMultiFractal:load_kelly_daily not implemented')
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
        obj.tbl_all_daily_ = d.(props{1});
    catch
        fprintf('cStratFutMultiFractal:load_kelly_daily:error!!!\n')
    end
    
end

