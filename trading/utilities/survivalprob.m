function p = survivalprob(S,B,wedge,barshift,bartype)
if nargin < 2
    error('survivalprob:not sufficient input parameters')
end

if nargin < 3
    wedge = 0;
    barshift = 0;
    bartype = 'uo'; %up and out
elseif nargin < 4
    barshift = 0;
    bartype = 'uo';
elseif nargin < 5
    bartype = 'uo';
end

if ~(strcmpi(bartype,'uo') || strcmpi(bartype,'do'))
    error('survivalprob:invalid bartype input')
end

newB = B+barshift;
if wedge == 0
    if strcmpi(bartype,'uo')
        p = double(S<newB);
    else
        p = double(S>newB);
    end
    return
end



end