function [] = loadbookfromcounter(strategy,varargin)
    strategy.bookbase_.loadpositionsfromcounter(varargin{:});
    strategy.bookrunning_.loadpositionsfromcounter(varargin{:});

end