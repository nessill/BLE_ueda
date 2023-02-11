for i = 1:20
    signalname='BLEsignal';
    signalnum=pad(string(i),6,"left",'0');
    signalname=append(signalname, signalnum, '.mat');
    load(signalname)
    I_arr=zeros(20,1);
    Ioff_arr(i,1)=I_offset;
    Qoff_arr(i,1)=Q_offset;
end
SumI = sum(abs(Ioff_arr));
meanI = SumI/20;
SumQ = sum(abs(Qoff_arr));
meanQ = SumQ/20;