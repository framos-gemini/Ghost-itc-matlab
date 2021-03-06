function [I2Mfout, varargout] = ab2flux(varargin)
%
% % File generated by IDL2Matlab 1.6 130501 %%
%
% %Initialization of parameters
  I2Mkwn=char('I2M_a1', 'I2M_a2', 'si', 'arcsec', 'I2M_pos');
  I2Mkwv={'ab', 'lbda', 'si', 'arcsec', 'I2M_pos'};
  ab=[]; lbda=[]; si=[]; arcsec=[]; I2M_pos=[];
  I2M_lst={}; I2M_out=''; lv=length(varargin); if rem(lv,2) ~= 0, I2M_ok=0; else, I2M_ok=1;
  for I2M=1:2:lv; I2M_tmp=varargin{I2M}; if ~ischar(I2M_tmp); I2M_ok=0; break; end; I2Mx=strmatch(I2M_tmp,I2Mkwn); if length(I2Mx) ~=1; I2M_ok=0; break; end; eval([I2Mkwv{I2Mx} '=varargin{I2M+1};']); I2M_lst{(I2M+1)/2}=I2Mkwv{I2Mx}; end; end;
  if ~I2M_ok; for I2M=1:lv; eval([I2Mkwv{I2M} '=varargin{I2M};']); end; end;
  if ~isempty(I2M_pos); for I2M=1:length(I2M_pos); I2Ms=num2str(I2M); I2M_out=[I2M_out 'varargout{' I2Ms '}=' I2M_lst{I2M_pos(I2M)} '; ']; end; end;

% % End of parameters initialization


  % ab is the ab magnitude
  % lbda is in a
  % flux will be in erg/s/cm^2 if option si is not set
  % flux will be in kg/m/s^3 if option si is set
  % flux will be in arcsec-2 if option sec is set
  % flux will be in a-1 if option a is set
  c = 299792458.0;  % in m/s
  l = lbda .* 1.e-10;  % in m
  M2I_asec = 1.0 ./ 206265.0;  % arcsec in radian
  if ( ~keyword_set(si))

    flux = 10.^(-0.4 .* (ab + 48.60) - 10) .* c ./ l.^2;
  
  else

    flux = 10.^(-0.4 .* (ab + 48.60) - 3) .* c ./ l.^2;
  end%if

  if (keyword_set(arcsec))

    flux = flux ./ M2I_asec.^2;
  end%if

  if ~isempty(I2M_out),eval(I2M_out);end;I2Mfout = flux;
  return;
% % end of function ab2flux
