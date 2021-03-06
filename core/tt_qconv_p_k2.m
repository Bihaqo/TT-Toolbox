function [tt]=tt_qconv_p_k2(x,y,d,eps)

% returns the periodic convolution in the QTT format
% of vectors x and y given in the QTT format
% using the approximate Krylov (DMRG) matvec with the accuracy eps
%
% x should be of size 2^l(1) x ... x 2^l(d)
% y should be of size 2^l(1) x ... x 2^l(d)
% THEN the output is of size 2^l(1) x ... x 2^l(d)
%
% June 1, 2011
% Vladimir Kazeev
% vladimir.kazeev@gmail.com
% INM RAS
% Moscow, Russia
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For details please see the preprint
% http://www.mis.mpg.de/publications/preprints/2011/prepr2011-36.html
% Vladimir A. Kazeev, Boris N. Khoromskij and Eugene E. Tyrtyshnikov
% Multilevel Toeplitz matrices generated by QTT tensor-structured vectors and convolution with logarithmic complexity
% January 12, 2012
% Vladimir Kazeev,
% Seminar for Applied Mathematics, ETH Zurich
% vladimir.kazeev@sam.math.ethz.ch
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% first, we construct the generating tensor
tt=tt_qshiftstack_p(d);
% then we reshape the generating tensor into a matrix
tt=tt_qreshape(tt,3,[4*ones(sum(d),1),2*ones(sum(d),1)]);
% and perform the matrix-vector multiplication to construct the vectorization of the circulant matrix 
tt=tt_mv(tt,x);
% next, reshape vectorization into a matrix
tt=tt_qreshape(tt,1,2*ones(sum(d),2));
% now we multiply the circulant matrix by the second operand
tt=tt_mvk2(tt,y,eps);

return
end