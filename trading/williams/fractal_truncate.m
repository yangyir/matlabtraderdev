function res = fractal_truncate(extrainfo,breachidx)
if isstruct(extrainfo)
    res = struct('px',extrainfo.px(1:breachidx,:),...
        'ss',extrainfo.ss(1:breachidx),...
        'sc',extrainfo.sc(1:breachidx),...
        'bs',extrainfo.bs(1:breachidx),...
        'bc',extrainfo.bc(1:breachidx),...
        'idxhh',extrainfo.idxhh(1:breachidx),...
        'idxll',extrainfo.idxll(1:breachidx),...
        'lvlup',extrainfo.lvlup(1:breachidx),...
        'lvldn',extrainfo.lvldn(1:breachidx),...
        'hh',extrainfo.hh(1:breachidx),...
        'll',extrainfo.ll(1:breachidx),...
        'lips',extrainfo.lips(1:breachidx),...
        'teeth',extrainfo.teeth(1:breachidx),...
        'jaw',extrainfo.jaw(1:breachidx),...
        'wad',extrainfo.wad(1:breachidx));
else
    error('fractal_truncate:struct input missing......')
end