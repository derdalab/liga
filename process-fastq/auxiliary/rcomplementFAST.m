function [ntc] = rcomplementFAST(NTin)

    ntc = fliplr(NTin);

    G = (ntc=='G');
    C = (ntc=='C');
    A = (ntc=='A');
    T = (ntc=='T');

    ntc(G) = 'C';
    ntc(C) = 'G';
    ntc(T) = 'A';
    ntc(A) = 'T';

end