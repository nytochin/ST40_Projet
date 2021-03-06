classdef OrzEval
    properties (SetAccess = public)
        ER;
        EER;
        Thres;
        
        A;
        FAR;
        FRR;
        
        nP;
        nN;
        
        flgSIM;
        
    end% properties
    
    methods
        function OB = OrzEval(VAL, Label, varargin)
%function OB = OrzEval(VAL, Label, varargin)
% VAL:      類似度もしくは非類似度?i距離?jが入った?s列?Aもしくは?sベクトル
%           VALが?s列の?�?�?A多クラス問題?i２クラス以?�?jと判断
%           VALが?sベクトルの?�?�?A１クラスと判断?ﾋERを計算しない
% Label:    VALの列?狽ﾆ同じサイズの?sベクトル
%           VALの?ｳ解ラベルを保�?
%           多クラス問題の?�?�?A１?`クラス?狽ﾌ値
%           １クラス問題の?�?�?A１?iPositive?jと０?iNegative?j
% 第三引?�?F VALの値が類似度か非類似度?i距離?jを決定する
%           デフォルトでは?A類似度
%           文字'D'が第三引?狽ﾉ入力された?�?�?A非類似度?i距離?jとして計算
%           
% PlotEER?F False Reject RateとFalse Alarm  RateをFigure(10)に描画
%           引?狽ﾉより?A番?�を変?X可能
% PlotROC?F ROC curveをFigure(100)に描画
%           引?狽ﾉより?A番?�を変?X可能
            
            VAL=VAL(:,:);
            % 類似度か非類似度か
            OB.flgSIM=true;
            if nargin == 3
                if varargin{1}=='D';
                    OB.flgSIM=false;
                end
            end
            
            % One-Class 問題かどうか
            if size(VAL,1)>=2
                B=zeros(size(VAL));
                Lu = unique(Label);
                for I=1:size(Lu,2)
                    B(I,Label==Lu(I))=1;
                end
                
                if OB.flgSIM
                    [v ind] = max(VAL,[],1);
                else
                    [v ind] = min(VAL,[],1);
                end
                OB.ER = 1-mean(ind == Label);
                
            else
                B = zeros(size(Label));
                B(Label~=0)=1;
            end
            VAL=VAL(:);
            B=B(:);
            
            OB.nP = sum(B==1);
            OB.nN = sum(B==0);
            
            if OB.flgSIM
                [OB.A C]= sort(VAL,'ascend');
            else
                [OB.A C]= sort(VAL,'descend');
            end
            D = B(C);
            
            OB.FAR = 1-cumsum(D==0)/OB.nN;
            OB.FRR = cumsum(D==1)/OB.nP;
            
            [val ind] = min((abs(OB.FAR-OB.FRR)));
            OB.EER = (OB.FAR(ind)+OB.FRR(ind))/2;
            OB.Thres = OB.A(ind);
        end
        
        function PlotEER(OB,varargin)
            if nargin == 2
                No = varargin{1};
            else
                No = 10;
            end
            
            figure(No)
            clf;
            hold on
            plot(OB.A,OB.FRR,'b');
            plot(OB.A,OB.FAR,'r');
            title('FRR - FAR');
            legend('False Reject Rate','False Alarm  Rate',0);
            xlabel('Threshold')
            ylabel('Rate')
            hold off
        end
        
        function PlotROC(OB,varargin)
            if nargin == 2
                No = varargin{1};
                color = 'r';
            elseif nargin == 3
                No = varargin{1};
                color = varargin{2};   
            else
                No = 100;
                color = 'r';
            end
            
            figure(No)
            %clf;
            hold on
            plot(OB.FAR,1-OB.FRR,color);
            xlabel('False Positive Rate')
            ylabel('True Positive Rate')
            hold off
        end
    end
end