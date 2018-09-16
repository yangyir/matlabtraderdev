fn = 'C:\yangyiran\regressiondata\book_regressiontest.txt';
myBookLoadFromFile = cBook;
myBookLoadFromFile.loadpositionsfromfile(fn);
myBookLoadFromFile.printpositions;
%%
myHelper = cOps('Name','ops-regressiontest');
myHelper.registerbook(myBookLoadFromFile);
%%
myCounter = CounterCTP.citic_kim_fut;
myHelper.registercounter(myCounter);