for i = 1:20
    signalname='BLEsignal';
    signalnum=pad(string(i),6,"left",'0');
    signalname=append(signalname, signalnum, '.mat');
    load(signalname)
    disp(fcfo)
end