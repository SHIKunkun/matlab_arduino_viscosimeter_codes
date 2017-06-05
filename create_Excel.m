function create_Excel(obj,~)
% Create a new Microsoft Excel file and its name is given by user.

    file_name=inputdlg('please input new file name: ','Create new file');
    name_str = file_name{1}; 
    name_num=double(name_str);
    obj.UserData=name_num;
    title={'n/rpm','raw data','fitting data'};
    
    mbox = msgbox('Please wait several seconds. ');
    uiwait(mbox);
    
   if ~exist(name_str,'file')
        xlswrite( name_str,title,'sheet1','A1:C1');
        mbox = msgbox('Everything is ready ! ');
        uiwait(mbox);
   else
       xlswrite( name_str,title,'sheet1','A1:C1');
   end
   
end