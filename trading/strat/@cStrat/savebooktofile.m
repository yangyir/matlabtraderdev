function [] = savebooktofile(strategy,fn)
    strategy.bookrunning_.savepositionstofile(fn);
end