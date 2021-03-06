function [varargout] = fracspagauss(varargin)
%
% File generated by IDL2Matlab 1.6 130501 %%

% %Initialization of parameters
  I2Mkwn=char('I2M_a1', 'I2M_a2', 'I2M_a3', 'I2M_a4', 'I2M_a5', 'I2M_pos');
  I2Mkwv={'mode', 'seeing', 'lmu', 'dlens', 'fa', 'I2M_pos'};
  mode=[]; seeing=[]; lmu=[]; dlens=[]; fa=[]; I2M_pos=[];
  I2M_lst={}; I2M_out=''; lv=length(varargin); if rem(lv,2) ~= 0, I2M_ok=0; else, I2M_ok=1;
  for I2M=1:2:lv; I2M_tmp=varargin{I2M}; if ~ischar(I2M_tmp); I2M_ok=0; break; end; I2Mx=strmatch(I2M_tmp,I2Mkwn); if length(I2Mx) ~=1; I2M_ok=0; break; end; eval([I2Mkwv{I2Mx} '=varargin{I2M+1};']); I2M_lst{(I2M+1)/2}=I2Mkwv{I2Mx}; end; end;
  if ~I2M_ok; for I2M=1:lv; eval([I2Mkwv{I2M} '=varargin{I2M};']); end; end;
  if ~isempty(I2M_pos); for I2M=1:length(I2M_pos); I2Ms=num2str(I2M); I2M_out=[I2M_out 'varargout{' I2Ms '}=' I2M_lst{I2M_pos(I2M)} '; ']; end; end;

% %End of parameters initialization


  %
  % description
  % compute the fraction of the total flux enclosed in the ghost ifu for given spectral
  % mode, seeing fwhm, and wavelength (wavelength dependence not
  % implemented, so this is currently a dummy argument)
  %
  % inputs
  % mode - instrument mode:
  %        sr - standard resolution
  %        hr - high resolution
  % seeing  - seeing fwhm
  % lmu  - wavelength (in micron) of requested fractional flux (not used)
  % dlens - lens diameter, flat-to-flat in arcsec
  % outputs
  % fa   - returned fraction of the flux enclosed within aperture, at given wavelength
  %
  % comments
  %
  % history:
  % - written by r.mcdermid
  %
  %=======================================================================================
  % first create the psf image. assume 0.01" pixels. these
  % parameters are ok for typica seeing values (0.2"-1.2" fwhm)
  scale = 0.01;  % arcsec/pixel scale for psf image
  npix = 500;  % size of psf image
  x = scale .* d1_array(d1_array(findgen(npix) - npix ./ 2) * replicate(1,npix));
  y = scale .* d1_array(replicate(1,npix) * d1_array(findgen(npix) - npix ./ 2));
  r = sqrt(x.^2 + y.^2);
  mof = psf_gaussian(npix,2,seeing ./ scale,1,npix ./ 2);
  % ####################
  % set up the ifu field
  % ####################
  % hexagon parameters. a = half flat-to-flat = apothem, s = side length
  a = dlens ./ 2.0;
  s = sqrt(3.) .* a ./ 2.;
  % set up lens centres
  % standard rsolution modes
  if (strcomp(mode, 'SR') | strcomp(mode, 'SF') | strcomp(mode, 'SVF') | strcomp(mode, 'BS') | strcomp(mode, 'BF') | strcomp(mode, 'BVF'))

    xcen = d1_array(0.,0.,-2. .* s,-2. .* s,0.,2. .* s,2. .* s);
    ycen = d1_array(0.,2. .* a,a,-1. .* a,-2. .* a,-1. .* a,a);
  
  else
    if (strcomp(mode, 'HR') | strcomp(mode, 'HF') | strcomp(mode, 'PRV'))

      % high resolution modes
      xcen = d1_array(0.,0.,-2. .* s,-2. .* s,0.,2. .* s,2. .* s,0.,-2. .* s,-4. .* s,-4. .* s,-4. .* s,-2. .* s,0.,2. .* s,4. .* s,4. .* s,4. .* s,2. .* s);
% inner ring

            ycen = d1_array(0.,2. .* a,a,-1. .* a,-2. .* a,-1. .* a,a,4. .* a,3. .* a,2. .* a,0.,-2. .* a,-3. .* a,-4. .* a,-3. .* a,-2. .* a,0.,2. .* a,3. .* a);
    end%if

    % now cycle through each lens, finding the regions of the psf it covers
  end%if
  nhex = eval('n_elements(xcen)','0');
  width = dlens;
  for i = 0:nhex - 1,

    xx = x + xcen(i +1);
    yy = y + ycen(i +1);
    w = where(yy < width ./ 2. & yy > (-width ./ 2.) & yy < (width - sqrt(3.) .* xx) & yy > (-width + sqrt(3.) .* xx) & yy < (width + sqrt(3.) .* xx) & yy > (-width - sqrt(3.) .* xx));
    M2I_print = 0;    % collect boundary coordinates for plotting?
    if (M2I_print == 1)

      bpts = find_boundary(w,npix,npix);
      if (i == 0)
        xb = scale .* reform(bpts(0 +1,:)) + miin(x);      
      else
        xb = d1_array(xb,reform(scale .* bpts(0 +1,:)) + miin(x));
      end%if
      if (i == 0)
        yb = scale .* reform(bpts(1 +1,:)) + miin(y);      
      else
        yb = d1_array(yb,reform(scale .* bpts(1 +1,:)) + miin(y));
      end%if
      if (i == 0)
        lens = replicate(i,eval('n_elements(bpts(0 +1,:))','0'));      
      else
        lens = d1_array(lens,replicate(i,eval('n_elements(bpts(0 +1,:))','0')));
      end%if
    end%if

    % accumulate the psf pixels covered by the lenses
    if (i == 0)
      wtot = w;    
    else
      wtot = d1_array(wtot,w);
    end%if
  end% for

  % comput enclosed flux. the psf function is already normalised, so it
  % is just the total of the psf pixels covered by the lenses
  fa = total(mof(wtot +1));
  if (M2I_print == 1)
    % show boundaries of lenslets on a plot
    loadct(3);
    image_plot(log10(mof ./ maax(mof)),x,y,1,strung('I2M_a1', seeing, 'f', '(f4.2)') + '" seeing: EE=' + strung('I2M_a1', fa, 'f', '(f4.2)'),1,1);
    for i = 0:nhex - 1,

      ind = where(lens == i);
      oplott('I2M_a1', xb(ind +1), 'I2M_a2', yb(ind +1), 'thick', 3, 'col', cgcolor('green'));
    end% for

    keyboard;
  end%if


if ~isempty(I2M_out),eval(I2M_out);end;
 return;
% % end of function fracspagauss
