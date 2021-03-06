warning('off','all')
clear,clc
warning('off','all')
diary('ph-interaction.txt') %TRY TO TAKE ALL NEED VARIABLE TO KEEP IN TXT FILE,
tic 
%x=xlsread('chr6_7_yield','gene','b5:gay277');
x=xlsread('PH-interaction','gene','b3:ed275');
%x=xlsread('chr4_5_yield','gene1','B5:GZJ277');
%x=xlsread('chr4_5_yield','gene','b5:jxp277');%SNP28705
% [n,p]=size(x);
% for i=1:n
   %  for j=1:p
   %      if isnan(x(i,j))
  %          disp([i,j,x(i,j)])
  %      end
 %   end
% end
%stop
y=xlsread('PH-interaction','phy','c2:c274');
%y=xlsread('chr4_5_yield','phy','q2:q274');
!copy fsdx.m fsd.m
ept0=15;%orig 15
[n,p]=size(x)
for l=n:-1:1
    if isnan(y(l))
        y(l)=[];
        x(l,:)=[];
    end
end
[n,p]=size(x);
p1=p;
alfa=.05;
%mdl=input('Using Model II(without square term 2) or Model III(with square term 3) 2/3? ');
mdl=2;
if mdl==1
    np=p1;
elseif mdl==2
    np=p1*(1+p1)/2;
elseif mdl==3
    np=p1*(3+p1)/2;
end
tr0=1:np;Tr0=tr0;tr1=1:p1;
XX=[ones(n,1),x];p0=p+1;
X=XX;
X0=zeros(n,np);
for i=1:p1
    X0(:,i)=x(:,i);
end
if mdl>1
    p2=p1;
    if mdl==3
        for i=1:p1
            p2=p2+1;
            X0(:,p2)=x(:,i).*x(:,i);
        end
    end
    for i=1:p1-1
        for j=i+1:p1
            p2=p2+1;
            X0(:,p2)=x(:,i).*x(:,j);
        end
    end
end
SSy=var(y)*(n-1);alfa=.01;
% Stage I: primary regression
ept=fix(1.5*ept0);
tr=randperm(p1);tr=tr(1:ept);
X=[ones(n,1),X0(:,tr)];p=size(X,2);
for lj=1:3
    dtr=setdiff(1:p1,tr); p3=length(dtr); cp=randperm(p3);
    for li=1:p3
        p=p+1;
        X(:,p)=X0(:,dtr(cp(li)));tr(p-1)=dtr(cp(li));
        if rank(X)<p
            X(:,p)=[];tr(p-1)=[];p=p-1;
        end
        a=X'*X;c=inv(a);k=X'*y;b=a\k;
        q=y'*y-b'*k;mse=q/(n-p);
        up=b.*b./diag(c);up(1)=[]; r2=(SSy-q)/SSy;
        f=up/mse;pr=1-fcdf(min(f),1,n-p);
        qi=find(f-min(f)==0);
        if pr>=falf1(alfa/p,p+fr21(r2)) && p>5
            tr(qi)=[];X(:,qi+1)=[];p=p-1;
        end
    end
end
a=X'*X;c=inv(a);k=X'*y;b=a\k;q=y'*y-b'*k;mse=q/(n-p);
up=b.*b./diag(c);up(1)=[];r2=(SSy-q)/SSy;
f=up/mse;pr=1-fcdf(min(f),1,n-p);
disp(['Initial regression, ','p=',num2str(p),', R^2=',num2str(r2)])
% Stage II: Re-examining all effect terms repeatedly!
dtr=setdiff(Tr0,tr);dtr1=[];sg=-1;fj=0;pt=0;
alf1=.8;cr4=1;alf=.1;rp=0;rp1=2;rp2=1;v=-1;Of=-100;OF=-1000;
nc=0;ne=0;cr=.25;ecr=.15;btr=[];etr=[];nj=0;FR=rand(1,16)-1000;TrR=zeros(16,50);
while rp<=100 %can change
    p3=length(dtr); cp=randperm(p3);
    ii=0;v=v+1;if v>13+.5*rp,v=1;end
    pct3=.15+pt+.001*mod(rp,150); pct4=.85-pt-.001*mod(rp,150);
    while ii<p3
        ii=ii+1;
        qi=find(f-min(f)==0);
        if p>2.7*ept+mod(v,27)+.03*mod(rp,350)*(randn+.1)
            if pr<alf1,dtr1=union(dtr1,tr(qi));end
            tr(qi)=[];X(:,qi+1)=[];p=p-1;
        elseif p<=5+.01*p1
            nc=nc+1;
        else
            alf=cr*alfa/(1+.25*p+.25*fr21(r2));
            alf=.001*(alf<.001)+(alf>=.001)*alf*(alf<=.6)+.6*(alf>.6);
            if pr>=alf
                if pr<alf1,dtr1=union(dtr1,tr(qi));end
                tr(qi)=[];X(:,qi+1)=[];p=p-1;
            else
                nc=nc+1;
            end
        end
        p=p+1;X(:,p)=X0(:,dtr(cp(ii)));tr(p-1)=dtr(cp(ii));
        if rank(X)<p
            X(:,p)=[];tr(p-1)=[];p=p-1;
        end
        a=X'*X;c=inv(a);k=X'*y;
        b=a\k;q=y'*y-b'*k;mse=q/(n-p);
        up=b.*b./diag(c);up(1)=[];
        f=up/mse; pr=1-fcdf(min(f),1,n-p);
        pl=1+length(tr)+.5*sum(tr>p1);
        r2=(SSy-q)/SSy;of=fsd(pl/n)*r2/(p-1)/(1-r2)*(n-p);
        if of>Of
            Bx=X;Btr=tr;Of=of;btr=union(btr,tr);
            fof=str2double(num2str(of,7));
            if sum(FR==fof)==0
                FR(16)=fof; TrR(16,1:end)=0; TrR(16,1:length(Btr))=Btr;
                [FR,ind]=sort(FR,'descend');
                TrR=TrR(ind,:);
            end
        elseif of>Of-ecr
            ne=ne+1;etr=union(etr,tr);
        end        
        while p>2.6*ept+mod(v,25) || pr>alfa+.018*mod(v,63)
            if pr<falf1(alf1/p,p+fr21(r2)) || p<=1.25*ept+.5*mod(v,22)+.01*mod(rp,190)*randn
                break
            end
            qj=find(f-min(f)==0);
            rd=rand(1);
            if rd<=.2+pt && rp>=5
                [F,ind]=sort(f,'descend');
                re=randperm(round((p-1)*pct3));q=round((p-1)*pct4-.05)+re(1);
                qi=ind(q);
            else
                qi=qj;
            end
            if pr<alf1,dtr1=union(dtr1,tr(qi));end
            X(:,qi+1)=[];p=p-1;tr(qi)=[];
            a=X'*X;c=inv(a);k=X'*y;b=a\k;
            q=y'*y-b'*k;mse=q/(n-p);
            up=b.*b./diag(c);up(1)=[];
            f=up/mse;pr=1-fcdf(min(f),1,n-p);
            pl=1+length(tr)+.5*sum(tr>p1);
            r2=(SSy-q)/SSy;of=fsd(pl/n)*r2/(p-1)/(1-r2)*(n-p);
            if of>Of
                Bx=X;Btr=tr;Of=of;btr=union(btr,tr);
                fof=str2double(num2str(of,7));
                if sum(FR==fof)==0
                    FR(16)=fof; TrR(16,1:end)=0; TrR(16,1:length(Btr))=Btr;
                    [FR,ind]=sort(FR,'descend');
                    TrR=TrR(ind,:);
                end
            elseif of>Of-ecr
                ne=ne+1;etr=union(etr,tr);
            end
        end
    end
    p5=p;
    pause(.0001)
    pct1=.18+pt+.001*mod(rp+20,220); pct2=.82-pt-.001*mod(rp+20,220);
    if mod(rp,135)>75, rd1=random('unif',.58,1.18,1); else rd1=.68; end
    while p>rd1*ept+.5*sg*mod(v,20)+.025*mod(rp,180)*randn || pr>=alfa  %changed the || to &&
        if p<=3+.005*p1
            break
        elseif pr<falf1(alf1/p,p+fr21(r2)) && p<=.25*ept+.25*mod(v,17)
            break
        end
        qj=find(f-min(f)==0);
        rd=rand(1);
        if rd<=.25+pt && rp>5
            [F,ind]=sort(f,'descend');
            re=randperm(round((p-1)*pct1));
            q=round((p-1)*pct2-.05)+re(1);
            qi=ind(q);
        else
            qi=qj;
        end
        X(:,qi+1)=[];dtr1=union(dtr1,tr(qi));tr(qi)=[];p=p-1;
        a=X'*X;c=inv(a);k=X'*y;b=a\k;
        q=y'*y-b'*k;mse=q/(n-p);
        up=b.*b./diag(c);up(1)=[];
        f=up/mse;pr=1-fcdf(min(f),1,n-p);
        pl=1+length(tr)+.5*sum(tr>p1);
        r2=(SSy-q)/SSy;of=fsd(pl/n)*r2/(p-1)/(1-r2)*(n-p);
        if of>Of
            Bx=X;Btr=tr;Of=of;btr=union(btr,tr);
            fof=str2double(num2str(of,7));
            if sum(FR==fof)==0
                FR(16)=fof; TrR(16,1:end)=0; TrR(16,1:length(Btr))=Btr;
                [FR,ind]=sort(FR,'descend');
                TrR=TrR(ind,:);
            end
        elseif of>Of-ecr
            ne=ne+1;etr=union(etr,tr);
        end
    end
    p6=p;
    pause(.001)
    for lj=1:2
        rd=rand(1);
        if rd<.6
            Dtr=union(btr,1:p1);
        elseif rd>.85
            if length(etr)>.125*np, etr=btr;end
            Dtr=union(etr,1:p1);
        else
            Dtr=1:p1;
        end
        dtr=setdiff(Dtr,tr); p3=length(dtr); cp=randperm(p3);
        for li=1:p3
            p=p+1;
            X(:,p)=X0(:,dtr(cp(li)));tr(p-1)=dtr(cp(li));
            if rank(X)<p
                dtr1=union(dtr1,tr(p-1));
                X(:,p)=[];tr(p-1)=[];p=p-1;
            end
            a=X'*X;c=inv(a);k=X'*y;b=a\k;
            q=y'*y-b'*k;mse=q/(n-p);
            up=b.*b./diag(c);up(1)=[];
            f=up/mse;pr=1-fcdf(min(f),1,n-p);
            pl=1+length(tr)+.5*sum(tr>p1);
            r2=(SSy-q)/SSy;of=fsd(pl/n)*r2/(p-1)/(1-r2)*(n-p);
            if of>Of
                Bx=X;Btr=tr;Of=of;btr=union(btr,tr);
                fof=str2double(num2str(of,7));
                if sum(FR==fof)==0
                    FR(16)=fof; TrR(16,1:end)=0; TrR(16,1:length(Btr))=Btr;
                    [FR,ind]=sort(FR,'descend');
                    TrR=TrR(ind,:);
                end
            elseif of>Of-ecr/100
                ne=ne+1;etr=union(etr,tr);
            end
            qi=find(f-min(f)==0);
            if pr>=5*falf1(alfa/p,p+fr21(r2)) && p>5
                dtr1=union(dtr1,tr(qi));
                tr(qi)=[];X(:,qi+1)=[];p=p-1;
                a=X'*X;k=X'*y;b=a\k;
                q=y'*y-b'*k;
                pl=1+length(tr)+.5*sum(tr>p1);
                r2=(SSy-q)/SSy;of=fsd(pl/n)*r2/(p-1)/(1-r2)*(n-p);
                if of>Of
                    Bx=X;Btr=tr;Of=of;btr=union(btr,tr);
                    fof=str2double(num2str(of,7));
                    if sum(FR==fof)==0
                        FR(16)=fof; TrR(16,1:end)=0; TrR(16,1:length(Btr))=Btr;
                        [FR,ind]=sort(FR,'descend');
                        TrR=TrR(ind,:);
                    end
                elseif of>Of-ecr/100
                    ne=ne+1;etr=union(etr,tr);
                end
            end
        end
    end
    %p7=p;disp([p5,p6,p7])
    pause(.001), nj=nj+1;
    if v<=0
        btr=[];etr=[];
    elseif length(btr)<=1
        btr=Btr;btr(btr>p1)=[];
    end
    if mod(v,2)==1
        cr1=exp(-6.3*(nc-10-.01*p3)/(.1*p3+.1*p1));
        cr1=.1*(cr1<.1)+(cr1>=.1)*cr1*(cr1<=10)+10*(cr1>10);
        cr=.25*cr*(1+cr1)+.25*(cr+cr1);
        cr2=.65*exp(-5.2*(ne-8-.0065*p3)/(.065*p3+.1*p1))+.3*exp(-.7*(length(etr)-2.5*ept-.1*np./(1+12.5*exp(-.025*nj)))/(.01*np+2.5*nj));
        cr2=.1*(cr2<.1)+(cr2>=.1)*cr2*(cr2<=8)+8*(cr2>8);
        ecr=.24*ecr*(1+cr2)+.24*(ecr+cr2);
    else
        cr1=exp(-6.1*(nc-18-.02*p3)/(.1*p3+.1*p1));
        cr1=.1*(cr1<.1)+(cr1>=.1)*cr1*(cr1<=10)+10*(cr1>10);
        cr=.25*cr*(1+cr1)+.25*(cr+cr1);
        cr2=.65*exp(-5*(ne-15-.013*p3)/(.065*p3+.1*p1))+.3*exp(-.7*(length(etr)-2.5*ept-.1*np./(1+12.5*exp(-.025*nj)))/(.01*np+2.5*nj));
        cr2=.1*(cr2<.1)+(cr2>=.1)*cr2*(cr2<=8)+8*(cr2>8);
        ecr=.24*ecr*(1+cr2)+.24*(ecr+cr2);
        nc=0;ne=0;
    end
    if mod(v,15)==5+fj && rp>=2 % using current result restart searching all terms
        dtr=setdiff(Tr0,tr); p3=length(dtr)+.15;
        alf1=falf2(p3); dtr1=[];
    elseif mod(v,15)==10+fj && rp>=2 % using previous best result restart searching all terms
        r3=randperm(3);tr3=TrR(r3(1),:); tr4=TrR(r3(2),:); rd=rand;
        if rd<.33, tr=union(tr3,tr4); elseif rd>.67, tr=intersect(tr3,tr4); else tr=Btr; end
        tr(tr==0)=[];X=[ones(n,1),X0(:,tr)]; p=size(X,2);dtr=setdiff(Tr0,tr);
        dtr1=[]; p3=length(dtr); alf1=falf2(p3)+.15;ecr=.65*ecr;
    elseif mod(v,15)==0 && rp>=7
        if mod(rp1,7)==1 % intensive search for terms appeared in good results
            rd=rand;
            if rd<.33, tr=union(tr,Btr); elseif rd>.67 tr=intersect(tr,Btr);else tr=Btr;end
            X=[ones(n,1),X0(:,tr)];p=size(X,2);
            Dtr=union(btr,etr);dtr=setdiff(Dtr,tr); p3=length(dtr);
            alf1=falf2(p3)+.25;dtr1=[];
            rp1=rp1+1;if length(etr)>100+.035*np;etr=btr;nj=5;end
            sg=-1;fj=0;pt=0;
            disp(['searching 1: intensive search based on Btr, p=',num2str(p)])
        elseif mod(rp1,7)==2 %restart search all terms based on part terms appeared in btr
            p44=fix(1.25*ept+.01*mod(rp,330)*rand);
            while p44>.85*length(btr), p44=p44-1; end
            X=[ones(n,1),X0(:,btr)]; tr=btr; p=size(X,2);X=X+randn(n,p)/10000;
            X(:,1)=ones(n,1);
            while p>p44
                a=X'*X;c=inv(a);k=X'*y;b=a\k; q=y'*y-b'*k;mse=q/(n-p);
                up=b.*b./diag(c);up(1)=[]; f=up/mse;
                qi=find(f-min(f)==0);
                X(:,qi+1)=[];tr(qi)=[];p=p-1;
            end
            X=[ones(n,1),X0(:,tr)];p=size(X,2);
            dtr=setdiff(Tr0,tr); p3=length(dtr);alf1=falf2(p3)+.15;fj=0;
            dtr1=[];rp1=rp1+1;pt=0;
            rd=rand;if rd<.25, sg=-.5; else sg=-1; end
            disp(['searching 2: restart search based on partial(stepwise) btr, p=',num2str(p44+1)]);
        elseif mod(rp1,7)==3 % intensive search based on terms appeared in best results
            tr3=unique(TrR(1:7,:)); tr4=tr3'; tr4(tr4==0)=[]; p4=length(tr4);
            p44=p4-1; re=randperm(p4); tr=tr4(re(1:p44));
            X=[ones(n,1),X0(:,tr)];p=size(X,2);
            Dtr=union(btr,etr);Dtr=union(Dtr,1:p1);
            dtr=setdiff(Dtr,tr); p3=length(dtr);alf1=falf2(p3)+.25;
            dtr1=[];rp1=rp1+1;fj=0;pt=0;
            rd=rand;if rd<.25, sg=-.25; else sg=-.5;end
            if length(etr)>200+.1*np;etr=btr;nj=5;end
            disp(['searching 3: intensive search based on top 4 Btr, p=',num2str(p)]);
        elseif mod(rp1,7)==4
            if length(Btr)<.85*ept,ce=1.15;elseif length(Btr)>1.15*ept,ce=.85;else ce=1.05;end
            r3=randperm(3); tr2=TrR(r3(1),:); tr3=TrR(r3(2),:);
            l1=length(intersect(tr,intersect(tr2,tr3)));
            l2=length(intersect(tr,union(tr2,tr3)));
            l3=length(union(tr,intersect(tr2,tr3)));
            l4=length(union(tr,union(tr2,tr3)));
            d=[l1,l2,l3,l4];e=ce*ept+.03*randn(1)*mod(rp,110);
            se=find(abs(d-e)-min(abs(d-e))==0);
            if se==1
                tr=intersect(tr,intersect(tr2,tr3));
            elseif se==2
                tr=intersect(tr,union(tr2,tr3));
            elseif se==3
                tr=union(tr,intersect(tr2,tr3));
            else
                tr=union(tr,union(tr2,tr3));
            end
            tr(tr==0)=[];
            X=[ones(n,1),X0(:,tr)];p=size(X,2);dtr=setdiff(Tr0,tr);
            p3=length(dtr);alf1=falf2(p3)+.05;sg=rand-1;
            dtr1=[];rp1=rp1+1; fj=0;pt=.05;
            disp(['searching 4: restart search based on top 5 results, p=',num2str(p)]);
        elseif mod(rp1,7)==5 % restart search based on partial etr terms
            tr3=unique(TrR(1:9,:)); tr4=tr3'; tr4(tr4==0)=[]; p4=length(tr4);
            if p4>10, p44=p4-2; else p44=p4-1;end
            re=randperm(p4); tr=tr4(re(1:p44));
            X=[ones(n,1),X0(:,tr)];p=size(X,2);
            Dtr=union(btr,etr);Dtr=union(Dtr,1:p1);
            dtr=setdiff(Dtr,tr); p3=length(dtr);alf1=falf2(p3)+.75;
            dtr1=[];rp1=rp1+1; sg=-1;fj=15;pt=.15;
            if length(etr)>150+.067*np;etr=btr;nj=5;end
            disp(['searching 5: intensive search based on top 6 Btrs, p=',num2str(p)]);
        elseif mod(rp1,7)==6
            p44=fix(1.5*ept+.015*mod(rp,150)*rand);
            while p44>.85*length(btr),p44=p44-1;end
            p4=length(btr);re=randperm(p4);
            tr=btr(re(1:p44)); 
            X=[ones(n,1),X0(:,tr)]; p=size(X,2);fj=15;pt=.15;
            dtr=setdiff(Tr0,tr); p3=length(dtr);alf1=falf2(p3)+.25;
            dtr1=[];rp1=rp1+1;sg=-1;
            if mod(rp2,2)==1
                Of=(.68+.05*randn)*Of;ecr=.15*ecr;rp2=rp2+1;
            else
                Of=(.5+.05*randn)*Of;ecr=.1*ecr;btr=[];etr=[];nj=0;rp2=rp2+1;
            end
            disp(['searching 6: restart search based on partial etr, p=',num2str(p)]);
        else  %restart search all terms based on partial best terms
            tr3=unique(TrR); tr4=tr3'; tr4(tr4==0)=[]; tr=tr4;
            p44=fix(.8*ept)+randi(5,1); 
            while p44>.8*length(tr),p44=p44-1;end
            X=[ones(n,1),X0(:,tr)]; p=size(X,2);
            while p>p44
                a=X'*X;c=inv(a);k=X'*y;b=a\k; q=y'*y-b'*k;mse=q/(n-p);
                up=b.*b./diag(c);up(1)=[]; f=up/mse;
                pl=1+length(tr)+.5*sum(tr>p1);
                r2=(SSy-q)/SSy;of=fsd(pl/n)*r2/(p-1)/(1-r2)*(n-p);
                if of>Of
                    Bx=X;Btr=tr;Of=of;btr=union(btr,tr);
                    fof=str2double(num2str(of,7));
                    if sum(FR==fof)==0
                        FR(16)=fof; TrR(16,1:end)=0; TrR(16,1:length(Btr))=Btr;
                        [FR,ind]=sort(FR,'descend');
                        TrR=TrR(ind,:);
                    end
                end
                qi=find(f-min(f)==0);
                X(:,qi+1)=[];tr(qi)=[];p=p-1;
            end
            disp(['searching 7: restart search based on tr4(-3), p=',num2str(p44+1)]);
            X=[ones(n,1),X0(:,tr)]; p=size(X,2);fj=15;pt=.15;
            dtr=setdiff(Tr0,tr); p3=length(dtr);alf1=falf2(p3)+.3*rand;
            dtr1=[];rp1=rp1+1;sg=-1;
            Of=(.88+.01*randn)*Of;ecr=.2*ecr;
        end
    else % intensive search for the weak effect terms
        dtr=setdiff(dtr1,tr);
        p3=length(dtr); alf1=falf2(p3)+.15;
        dtr1=[];
    end
    while rank(X)<p
        dtr1=union(dtr1,tr(p-1));
        X(:,p)=[];tr(p-1)=[];p=p-1;
    end
    a=X'*X;c=inv(a);k=X'*y;b=a\k;
    q=y'*y-b'*k;mse=q/(n-p);
    up=b.*b./diag(c);up(1)=[];
    f=up/mse;pr=1-fcdf(min(f),1,n-p);
    r2=(SSy-q)/SSy;
    pl=1+length(tr)+.5*sum(tr>p1);
    of=fsd(pl/n)*r2/(p-1)/(1-r2)*(n-p);
    if of>Of
        Bx=X;Btr=tr;Of=of;btr=union(btr,tr);
        fof=str2double(num2str(of,7));
        if sum(FR==fof)==0
            FR(16)=fof; TrR(16,1:end)=0; TrR(16,1:length(Btr))=Btr;
            [FR,ind]=sort(FR,'descend');
            TrR=TrR(ind,:);
        end
    elseif of>Of-ecr
        ne=ne+1;etr=union(etr,tr);
    end
    if Of>OF
        OF=Of;rp=0;BX=Bx;BTR=Btr;
    else
        rp=rp+1;
    end
    ept=fix(.8*ept0+.065*mod(rp,165));
    qb=y'*y-(Bx\y)'*Bx'*y;r2=(SSy-qb)/SSy;p4=size(Bx,2);p20=length(btr);p30=length(etr);
    disp(['v=',num2str(v),', p=',num2str(p4),', R^2=',num2str(r2),', of=',num2str(Of),',  btrsize=',num2str(p20),', etrsize=',num2str(p30),', ecr=',num2str(ecr)])
end
X=BX;tr=BTR;p=size(X,2);
a=X'*X;k=X'*y;c=inv(a);b=a\k;
q=y'*y-b'*k;mse=q/(n-p);
up=b.*b./diag(c);up(1)=[];
f=up/mse;pr=1-fcdf(f,1,n-p);
SEb=sqrt(mse*diag(c));SEb(1)=[];
%Stage IV display last results.
%Stage IV display last results.
    if mdl==2
        fo=p1;
    end
    for i=1:p1-1
        for j=i+1:p1
            fo=fo+1;
            if i<10 && j<10
                TR(fo,:)=char(['X',num2str(i),'X',num2str(j),'  ']);
            elseif i<10 && j>=10
                TR(fo,:)=char(['X',num2str(i),'X',num2str(j),' ']);
            elseif i>=10 && j<10
                TR(fo,:)=char(['X',num2str(i),'X',num2str(j),' ']);
            else
                TR(fo,:)=char(['X',num2str(i),'X',num2str(j)]);
            end
        end
    end
%for i=1:p1
 %   if i<10
    %    TR(i,:)=char(['X',num2str(i),'   ']);
   % elseif i>=10 && i<100
      %  TR(i,:)=char(['X',num2str(i),'  ']);
   % elseif i>=100 && i<1000
      %  TR(i,:)=char(['X',num2str(i),' ']);
    %elseif i>=1000 && i<2000
        %TR(i,:)=char(['X',num2str(i),' ']);
   % elseif i>=2000&& i<5000
       % TR(i,:)=char(['X',num2str(i),' ']);
    %elseif i>=5000 && i<8000
       % TR(i,:)=char(['X',num2str(i),' ']);
    %elseif i>=8000&& i<10961
      %  TR(i,:)=char(['X',num2str(i),' ']);
    %else
      %  TR(i,:)=char(['X',num2str(i)]);
   % end
%end
Tr=TR(tr,:);
disp(['    p=',num2str(p)])
disp('Last Results:')
disp('Xi       bi       SEb       Up        F       p')
disp(['X0      ',num2str(b(1))])
for i=1:p-1
    disp([Tr(i,:),'  ',num2str(b(i+1)),'  ',num2str(SEb(i)),'  ',num2str(up(i)),'  ',num2str(f(i)),'  ',num2str(pr(i))])
end
disp(['Error  ',num2str(n-p),' ',num2str(q),' ',num2str(mse)])
disp(['Total  ',num2str(n-1),' ' num2str(SSy)])
r2=(SSy-q)/SSy;disp(['p=',num2str(p),', R^2=',num2str(r2),', OF=',num2str(OF)])
dfe=n-p;dfT=n-1;
%filename='PH-interaction.xlsx';
%result={'Xih','bi','SEb','Up','F','p'; Tr(i,:); num2str(b(i+1)); num2str(SEb(i)); num2str(up(i)); num2str(f(i))};
%BX;
%xlswrite(filename,BX);
toc
diary off