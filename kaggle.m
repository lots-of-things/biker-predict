data = csvread('train.csv',1,1);
T = importdata('train.csv');
t = datenum(T.textdata(2:end,1));
h_ = datevec(T.textdata(2:end,1));
h = h_(:,4);

datatest = csvread('test.csv',1,1);
Test = importdata('test.csv');
tt = datenum(Test.textdata(2:end,1));
h_ = datevec(Test.textdata(2:end,1));
ht = h_(:,4);

yav = zeros(size(data,1),1);
for wd = [0 1]
    for hi=0:23
        cl = h==hi&((wd&data(:,2)==wd)|data(:,3)~=wd);
        
        yav(cl)=smooth(t(cl),data(cl,end),10,'moving');
    end
end
x = [t(2:end) h(2:end) data(2:end,1:3) data(1:end-1,4:8) yav(2:end)];
y = data(2:end,end);

kaggle_nn

yavtest = zeros(size(datatest,1),1);
for wd = [0 1]
    for hi=0:23
        cl = x(:,2)==hi&((wd&x(:,4)==wd)|x(:,5)~=wd);
        su = x(cl,end);
        tu = x(cl,1);
        m = mean(tu);
        c = fit(tu-m,su, 'smoothingspline', 'SmoothingParam', 0.6);
        c2 = fit(tu(tu>7.3511e5)-m,su(tu>7.3511e5), 'poly1');
        cl2 = ht==hi&((wd&datatest(:,2)==wd)|datatest(:,3)~=wd);
        yavtest(cl2)=c(tt(cl2)-m);
        yavtest(cl2&tt>7.3521e5)=c2(tt(cl2&tt>7.3521e5)-m);
    end
end

xt = [tt(2:end) ht(2:end) datatest(2:end,1:3) datatest(1:end-1,4:8) yavtest(2:end)];
wd=0;
cl_b = x(:,2)==16&((wd&x(:,4)==wd)|x(:,5)~=wd);
cl_t = xt(:,2)==16&((wd&xt(:,4)==wd)|xt(:,5)~=wd);

figure;
plot(x(cl_b,1),y(cl_b),'.');
hold on;
plot(x(cl_b,1),x(cl_b,end),'g.');
plot(xt(cl_t,1),xt(cl_t,end),'r.')

trainout = net(x');
yout = net(xt');

figure;
plot(x(cl_b,1),y(cl_b),'.')
hold on;
plot(xt(cl_t,1),yout(cl_t),'m.')

cl_b = x(:,2)==7&((wd&x(:,4)==wd)|x(:,5)~=wd);
cl_t = xt(:,2)==7&((wd&xt(:,4)==wd)|xt(:,5)~=wd);

figure;
plot(x(cl_b,1),y(cl_b),'.')
hold on;
plot(xt(cl_t,1),yout(cl_t),'m.')

wd=1;
cl_b = x(:,2)==16&((wd&x(:,4)==wd)|x(:,5)~=wd);
cl_t = xt(:,2)==16&((wd&xt(:,4)==wd)|xt(:,5)~=wd);

figure;
plot(x(cl_b,1),y(cl_b),'.')
hold on;
plot(xt(cl_t,1),yout(cl_t),'m.')

cl_b = x(:,2)==7&((wd&x(:,4)==wd)|x(:,5)~=wd);
cl_t = xt(:,2)==7&((wd&xt(:,4)==wd)|xt(:,5)~=wd);

figure;
plot(x(cl_b,1),y(cl_b),'.')
hold on;
plot(xt(cl_t,1),yout(cl_t),'m.')


fileID = fopen('mysub.csv','w');
fprintf(fileID,'datetime,count\n');
for i =1: length(yout) 
    fprintf(fileID,'%s,%d\n',Test.textdata{i+1},yout(i));
end
fclose(fileID);