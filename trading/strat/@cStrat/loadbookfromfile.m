function [] = loadbookfromfile(strategy,fn,dateinput)
    strategy.bookbase_.loadpositionsfromfile(fn,dateinput);
    strategy.bookrunning_.loadpositionsfromfile(fn,dateinput);
end