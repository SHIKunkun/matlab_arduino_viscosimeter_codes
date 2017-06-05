function linear_regression(hObject,eventdata)
    %Automatically execute the linear regression of raw data in Excel file
    %%
    h1= findobj('label','New file');
    h2=findobj('UserData',5); %result
    Excel_name = char(h1.UserData);
    %Excel_name='test.xls';
    [num,~] = xlsread(Excel_name);
    [data_size,~] = size(num);
    xrange1= ['A2',':','A',num2str(data_size)];
    yrange1= ['B2',':','B',num2str(data_size)];
    xdata = xlsread(Excel_name,1,xrange1)';
    ydata = xlsread(Excel_name,1,yrange1)';

    % xdata=xlsread('BDT1006_2.xlsx',1,'A2:A28');
    % ydata=xlsread('BDT1006_2.xlsx',1,'B2:B28');
    p=xdata'\ydata';
    y=polyval([p;0],xdata);

    figure;
    plot([0,xdata],[0,ydata],[0,xdata],[0,y]);
    title('linear regression of raw datas');
    legend('raw data line','fitting result');
    xlabel('n/rpm');
    %ylabel(' ');
    grid on;
    str=sprintf('y=%d*n',p);
    gtext(str);
    
    final_result=p(1)*103; %adaptable to correction 
    set(h2,'String',num2str(final_result));

end