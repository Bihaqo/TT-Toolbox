function [res]=tt_mbl(mat,vec)
%[TT]=TT_MBL(MAT,VEC)
%Matrix-by-vector product in TT format
%
%
% TT Toolbox 1.1, 2009-2010
%
%This is TT Toolbox, written by Ivan Oseledets, Olga Lebedeva
%Institute of Numerical Mathematics, Moscow, Russia
%webpage: http://spring.inm.ras.ru/osel
%
%For all questions, bugs and suggestions please mail
%ivan.oseledets@gmail.com
%---------------------------
d=size(mat,1);
res=cell(d+1,1);
n=size(mat{1},1);
m=size(mat{1},2);
rm1=size(mat{1},3);
rv1=size(vec{1},2);
%mat{1} is (n x m x rm1 , vec{1} is m x rv1)
%            n x rm1 x rv1
res{1}=reshape(permute(mat{1},[1,3,2]),[n*rm1,m])*vec{1};
res{1}=reshape(permute(reshape(res{1},[n,rm1,rv1]),[1,3,2]),[n,rv1*rm1]);


n=size(mat{d},1);
m=size(mat{d},2);
rm1=size(mat{d},3);
rv1=size(vec{d},2);
rv2=size(vec{d},3);
%mat{d} is (n x m x rm1 , vec{d} is m x rv1 x rv2)
res{d}=reshape(permute(mat{d},[1,3,2]),[n*rm1,m])*...
                                reshape(vec{d},[m,rv1*rv2]);
%res{d} n x rm1 x rv1 x rv2

                            %%res{d}=reshape(permute(reshape(res{d},[n,rm1,rv1]),[1,3,2]),[n,rv1*rm1,rv2]);
%%res{d}=reshape(res{d},[n,rm2,rm1,rv1,rv2]);
%%res{d}=permute(res{d},[1,4,3,5,2]);
res{d}=reshape(res{d},[n,rm1,rv1,rv2]);
res{d}=permute(res{d},[1,3,2,4]);
res{d}=reshape(res{d},[n,rv1*rm1,rv2]);

for i=2:d-1
    n=size(mat{i},1);
    m=size(mat{i},2);
    rm1=size(mat{i},3);
    rm2=size(mat{i},4);
    rv1=size(vec{i},2);
    rv2=size(vec{i},3);
    %mat{i} is n x m x rm1 x rm2, vec{i} is m x rv1 x rv2
    %n x (rv1*rv2)*rm1*rm2
    %n x rm2 x rm1 x m, n x rm2 x rm1 x (rv1*rv2)
    %n x rm2 x rmx1 x rv1 x rv2
    %want: n x rv1*rm1 x rv2*rm2
    res{i}=reshape(permute(mat{i},[1,4,3,2]),[n*rm2*rm1,m])*reshape(vec{i},[m,rv1*rv2]);
    res{i}=reshape(res{i},[n,rm2,rm1,rv1,rv2]);
    res{i}=permute(res{i},[1,4,3,5,2]);
    res{i}=reshape(res{i},[n,rv1*rm1,rv2*rm2]);
    %res{i}=permute(reshape(permute(mat{i},[1,3,4,2])*reshape(vec{i},[m,rv1*rv2]),[n,rv1,rv2,rm1,rm2]),[1,2,4,3,5]);
end 
res{d+1}=vec{d+1};
return
end
