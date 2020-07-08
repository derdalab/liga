%%%[newNUC, newFr] = uniquef(cellstr(NUC))_Bifang
%%% For exapmle z = [1;2;3;4;1;2;1;4] 
%%% z =sort(z)=[1;1;1;2;2;3;4;4]
%%% sZ = [1;2;3;4]; M=[1;4;6;7]
%%% M2=[4;6;7;9]; Occur=M2-M=[3;2;1;2]
function [invout, Occur] = uniquef (inv)

z = sort(inv);

[sZ,M,~] = unique(z, 'first');%%% return the unique element and the first
                              %%% position of the unique element

M2 = [M(2:end); numel(z)+1];
Occur = M2-M; 

[Occur, IX ] = sort(Occur, 'descend');%Occur listes the sorted frequency
%IX contains the corresponding indices of Occur 
invout = sZ(IX); % return the element in the order based on the frequency

end