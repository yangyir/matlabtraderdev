book = cBook;
txtfn = 'c:\yangyiran\trades.txt';
book.loadpositionsfromtxt(txtfn);
%%
book2 = cBook;
excelfn = 'c:\yangyiran\trades.xlsx';
sheetn = 'tradeopen';
book2.loadpositionsfromexcel(excelfn,sheetn);
