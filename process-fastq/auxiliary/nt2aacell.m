function [aac] = nt2aacell(nt,Qfix)

% nt could be cell array or character array
% Qfix tells you whether or not to fix the amber stop codon TAG into Q
% (glutamine). In your case, you have sequences from amber-supressing
% strain, which interprets amber stop codon as Q.  Qfix must be 1.
 
if iscell(nt)
  ntc = char(nt); 
else
    ntc=nt;
end
clear('nt');

  aalength = floor(size(ntc,2) / 3);
  aac = ntc(:,1:aalength);
  aac(:) = '@';


  map = geneticcode(1);
  codons = fieldnames(map);
  codons = codons(2:end-1);

  for i=1:aalength
      triplets = (ntc(:,(i-1)*3+1:i*3));
      [utr,~,Y] = unique(triplets,'rows');
      for j=1:size(utr,1)
          IX = (Y==j);
          if Qfix && strcmp(utr(j,:),'TAG')
              aac(IX,i) = 'Q';
          else
              try
              aac(IX,i) = map.(utr(j,:));
              catch
                  if strcmp(utr(j,:),'   ')
                      aac(IX,i)=' ';
                  else
                      aac(IX,i)='X';
                  end
              end
          end
      end
  end
  
end