function [Z,U,D,E] = orzPCA(X,Y,varargin)
%function [Z,U,D,E] = orzPCA(X,Y,varargin)
% ��?�����?� ver.1.00 by ohkawa
% input
%  X: ���̓}�g���b�N�X input matrix
%  Y: ������Ԃ̎����������͊�^�� 
%  Y��1.0�ȉ��Ȃ��?C Y�͊�^���Ɣ��f
%  Y��1.0���߂Ȃ��?C Y�͕�����Ԃ̎����Ɣ��f
%  ��O��??EF�f�t�H���g�ł�?C�����U covariance ?s���PCA
%  ��O��?���'R'�̎�?C���ȑ���?s���PCA
%  
%?@nDim< nNum�̎��͒�?���PCA
%  nDim>=nNum�̂Ƃ���??E`�J?[�l��PCA?i�o�Ζ��?j��K�p����
% output
%  Z: ��?�����ԂɎˉe���ꂽ�f?[�^ projection
%  U: ��?����x�N�g�� basis vector
%  D: �ŗL�l eigenvalue
%  E: ��^�� ratio


X = X(:,:);
[nDim,nNum] = size(X);

flgM = true;
if nargin == 3
    if varargin{1} == 'R'
        flgM = false;
    end
end

if Y <= 1 % ��^��
    cRate = Y;
    if nDim<nNum
        if flgM==true
            C = cov(X',1);
        else
            C = X*X'/nNum;
        end
        [U,tmpD]= eig(C);
        [D ind]= sort(diag(tmpD),'descend');
        U = U(:,ind);
        nSubDim = find(cumsum(D)/sum(D)>=cRate, 1 );
        U=U(:,1:nSubDim);
        D = D(1:nSubDim);
        E = sum(D)/trace(C);
    else
        if flgM==true
            K = X'*X;
            IN =  ones(nNum,nNum)/nNum;
            K = K - IN*K - K*IN + IN*K*IN;
        else
            K = X'*X;
        end
        [A B] = eig(K);
        [B ind] = sort(diag(B),'descend');
        A=A(:,ind);
        D = B/nNum;
        nSubDim = find(cumsum(D)/sum(D)>=cRate, 1 );
        A=A(:,1:nSubDim);
        B=B(1:nSubDim);
        A = A/sqrt(diag(B));
        U = X*A;
        D = D(1:nSubDim);
        E = sum(D);        
    end
elseif Y > 1 % ��?�����Ԃ̎���
    nSubDim = floor(Y);
    if nDim<nNum
        if flgM==true % �����U?s��
            C = cov(X',1);
        else % ���ȑ���?s��
            C = X*X'/nNum;
        end
        
        OPTS.disp = 0;
        if nSubDim<nDim 
           [U tmpD] = eigs(C,nSubDim,'lm',OPTS); %[U,tmpD]= eigs(C,nSubDim);
        else
           [U tmpD] = eig(C);
        end
        [D ind]= sort(diag(tmpD),'descend');
        U = U(:,ind);
        E = sum(D)/trace(C);
    else %�J?[�l��
        if flgM==true % �����U?s��
            K = X'*X;
            IN =  ones(nNum,nNum)/nNum;
            K = K - IN*K - K*IN + IN*K*IN;
        else  % ���ȑ���?s��
            X = double(X);
            K = transpose(X)*X;
        end
        OPTS.disp = 0;    
        [testvec testval] = eig(K);
        [A B] = eigs(K,nSubDim,'lm',OPTS);
        [B ind] = sort(diag(B),'descend');
        A = A(:,ind);
        D = B/nNum;
        A = A/sqrt(diag(B));
        U = X*A;
        E = sum(D);
    end
end
Z = U'*X;