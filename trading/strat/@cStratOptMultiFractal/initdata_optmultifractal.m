function [] = initdata_optmultifractal(stratfractal)
%cStratOptMultiFractal
    stratfractal.mde_opt_.initcandles;
    %
    [bs,ss,lvlup,lvldn,bc,sc] = stratfractal.mde_opt_.calc_tdsq_('IncludeLastCandle',1,'RemoveLimitPrice',1);       
    %
    [~,hh,ll] = stratfractal.mde_opt_.calc_fractal_('IncludeLastCandle',1,'RemoveLimitPrice',1);
    %
    [jaw,teeth,lips] = stratfractal.mde_opt_.calc_alligator_('IncludeLastCandle',1,'RemoveLimitPrice',1);
    %
    wad = stratfractal.mde_opt_.calc_wad_('IncludeLastCandle',1,'RemoveLimitPrice',1);
        
    stratfractal.hh_ = hh;
    stratfractal.ll_ = ll;
    stratfractal.jaw_ = jaw;
    stratfractal.teeth_ = teeth;
    stratfractal.lips_ = lips;
    stratfractal.bs_ = bs;
    stratfractal.ss_ = ss;
    stratfractal.bc_ = bc;
    stratfractal.sc_ = sc;
    stratfractal.lvlup_ = lvlup;
    stratfractal.lvldn_ = lvldn;
    stratfractal.wad_ = wad;

end