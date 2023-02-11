for i = 1:20
    signalname='BLEsignal';
    signalnum=pad(string(i),6,"left",'0');
    signalname=append(signalname, signalnum, '.mat');
    load(signalname)
    disp(fcfo)
    fcfo_arr=zeros(20,1);
    fcfo_arr(i,1)=fcfo;
end
Sum = sum(fcfo_arr);