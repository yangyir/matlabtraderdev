function [] = registerinstrument(stratopt,instrument)
    registerinstrument@cStrat(stratopt,instrument);
    stratopt.setlimitamount(instrument,inf);
    stratopt.setlimittype(instrument,'abs');
    stratopt.setstopamount(instrument,-inf);
    stratopt.setstoptype(instrument,'abs');
    stratopt.setautotradeflag(instrument,0);
    stratopt.setbidspread(instrument,0);
    stratopt.setaskspread(instrument,0);
    %note:delta/gamma/vega/theta/impvol is the real time greeks which are
    %updated via the qutoes
    stratopt.setriskvalue(instrument,'delta',0);
    stratopt.setriskvalue(instrument,'gamma',0);
    stratopt.setriskvalue(instrument,'vega',0);
    stratopt.setriskvalue(instrument,'theta',0);
    stratopt.setriskvalue(instrument,'impvol',0);
    %
    %note:deltacarry/gammacarry/vegacarry/thetacarry are the risks
    %carried on the end of current business date
    stratopt.setriskvalue(instrument,'deltacarry',0);
    stratopt.setriskvalue(instrument,'gammacarry',0);
    stratopt.setriskvalue(instrument,'vegacarry',0);
    stratopt.setriskvalue(instrument,'thetacarry',0);
    %
    pnlriskoutput = pnlriskbreakdown1(instrument,getlastbusinessdate);
    %note:deltacarry/gammacarry/vegacarry and thetacarry are the
    %risk carry on the end of the last business date
    stratopt.setriskvalue(instrument,'deltacarryyesterday',pnlriskoutput.deltacarry);
    stratopt.setriskvalue(instrument,'gammacarryyesterday',pnlriskoutput.gammacarry);
    stratopt.setriskvalue(instrument,'vegacarryyesterday',pnlriskoutput.vegacarry);
    stratopt.setriskvalue(instrument,'thetacarryyesterday',pnlriskoutput.thetacarry);
    %note:iv2 is the implied vol using the close price of the
    %option and its underlier as of the last business date
    stratopt.setriskvalue(instrument,'impvolcarryyesterday',pnlriskoutput.iv2);
    %note:premium2 is the close price of the option as of the last
    %business date
    stratopt.setriskvalue(instrument,'pvcarryyesterday',pnlriskoutput.premium2);

    %pls note all the risk figures above have not been scaled by
    %the volume which is embedded in the portfolio

end
%end of registerinstrument