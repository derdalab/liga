function [FR] = add(SeqF,SeqR)
% this function adds forward and reverse reads %%%%%%%%%%%%%%%%%%%    
    FR = char((SeqF+SeqR)/2);

    a = char(('A'+'~')/2); % a='_'
    t = char(('T'+'~')/2); % t='i'
    g = char(('G'+'~')/2); % g='b'
    c = char(('C'+'~')/2); % c='`'

    FR(FR==a)='A';
    FR(FR==t)='T';
    FR(FR==g)='G';
    FR(FR==c)='C';
    FR(FR=='O')=' '; % this char. results from averaging of '~' and space
    clear a t g c SeqF SeqR;

    fprintf([num2str(size(FR,1)) ' raw ' ...
             '(' num2str(toc,'%10.1f')   ' s); ']);
end
