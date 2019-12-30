 
function SE=MMSEV3(M,r,tau,x,epsilon)

% V3 - the increase in embedding dimension is performed in a way so that
% there is no 'leakage' between channels

% This function calculates multivariate sample entropy using the full multivariate approach
% Inputs:

% M - embedding vector parameter
% r - threshold scalar parameter 
% tau - time lag vector parameter
% x - multivariate time series-a matrix of size nsamp X nvar
% epsiloon - number of scales (scalar)

% Output:
% SE - vector quantity

[n,b]=size(x);

for j=1:epsilon
   for p=1:b
     for i=1:n/j
     y(i)=0;
         for k=1:j
            y(i)=y(i)+x((i-1)*j+k,p);
         end
     y(i)=y(i)/j;
     end
  z=y(1:floor(n/j));
  X(:,p)=z;
  end

e=mvsampen_full(M,r,tau,X');
SE(j)=e;
clear('X')
end



function e=mvsampen_full(M,r,tau,ts)
%number of match templates of length m closed within the tolerance r where m=sum(M) is calculated first




[nvar,nsamp]=size(ts);

A=embd(M,tau,ts);%all the embedded vectors are created
y=pdist(A,'chebychev');%infinite norm is calculated between all possible pairs
[~,~,v1]= find(y<=r);% threshold is implemented
p1=numel(v1)/length(y); %the probability that two templates of length m are closed within the tolerance r
clear  y  v1 A;


M=M+1;



% number of match templates of length m+1 closed within the tolerance r where m=sum(M) is calculated afterwards
B=embd(M,tau,ts);
z=pdist(B,'chebychev'); %now comparison is done between subspaces
[~,~,v2]= find(z<=r);
p2=numel(v2)/length(z);
clear  z  v2 B;


e=log(p1/p2);

function A=embd(M,tau,ts)
% This function creates multivariate delay embedded vectors with embedding
% vector parameter M and time lag vector parameter tau.
% M is a row vector [m1 m2 ...mnvar] and tau is also a row vector [tau1 tau2....taunvar] where nvar is the 
% number of channels; 
% ts is the multivariate time series-a matrix of size nvarxnsamp;

[nvar,nsamp]=size(ts);
A=[];

for j=1:nvar
for i=1:nsamp-max(M)*max(tau)
temp1(i,:)=ts(j,i:tau(j):i+(M(j)-1)*tau(j));
end
A=horzcat(A,temp1);
temp1=[];
end

