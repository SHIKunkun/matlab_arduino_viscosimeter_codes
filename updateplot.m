function [tc_data,viscosity,viscosity_data,var_visco]=updateplot(tc,tc_data,viscosity_data,m,buf_len)

tc_data = [tc_data(2:end),tc];

viscosity=mean(tc_data(buf_len-m+1:end));

viscosity_data=[viscosity_data(2:end),viscosity];

var_visco=var(viscosity_data);

end