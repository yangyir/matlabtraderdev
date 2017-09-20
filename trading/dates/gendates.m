function dates = gendates(varargin)
p = inputParser;p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('FromDate',{},@(x)validateattributes(x,{'numeric','char'},{},'','FromDate'));
p.addParameter('ToDate',{},@(x)validateattributes(x,{'numeric','char'},{},'','ToDate'));
p.addParameter('Frequency','daily',@(x)validateattributes(x,{'char'},{},'','Frequency'));
p.parse(varargin{:});
fromdate = p.Results.FromDate;
todate = p.Results.ToDate;
freq = p.Results.Frequency;

if isempty(fromdate)
    error('gendates:missing FromDate!')
end

if isempty(todate)
    error('gendates:missing ToDate!')
end

if ~(strcmpi(freq,'daily') || strcmpi(freq,'weekly') || strcmpi(freq,'quarterly') || ...
        strcmpi(freq,'semi-annually') || strcmpi(freq,'annually') || ...
        strcmpi(freq,'zero'))
    error('gendates:invalid freq input!')
end

if isholiday(fromdate)
    %by convention the first business date shall be moved forward
    fromdate = businessdate(fromdate,1);
end

if isholiday(todate)
    %by convention the last business date shall be moved forward
    todate = businessdate(todate,-1);
end

if strcmpi(freq,'daily')
    n = 0;
    t = datenum(fromdate);
    tend = datenum(todate);
    while t <= tend
        n = n+1;
        t = businessdate(t,1);
    end
    dates = zeros(n,1);
    
    t = datenum(fromdate);
    n = 1;
    while t <= tend
        dates(n) = t;
        n = n+1;
        t = businessdate(t,1);
    end
elseif strcmpi(freq,'zero')
    %only the first date poped up
    dates = zeros(1,1);
    dates(1) = datenum(fromdate);
else
    error('other frequency not implemented yet')
    %todo
end


end