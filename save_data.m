function save_data(hObject,eventdata)
    
    h1=findobj('label','New file');
    h2=findobj('UserData',4); %speed/rpm
    h3=findobj('UserData',5); %result
    h4=findobj('Userdata',3);
    coefficient=2*pi/60;
    
    if ~h4.Value
        Excel_name = char(h1.UserData);
        data1 = str2double(h2.String)*coefficient;
        data2 = str2double(h3.String);
        % Excel_name='test.xls';

        [previous_size,~]=size(xlsread(Excel_name));
        n=previous_size;
        data=[data1 data2];
        cellrange=['A',num2str(n+2),':','B',num2str(n+2)]; % What's important is situated here!
        xlswrite(Excel_name,data,1,cellrange);
    end
    
end

    
    