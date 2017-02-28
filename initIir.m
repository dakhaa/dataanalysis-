function [zi,y0] = initIir(b, a, x0)
%% initializes the taps (delay registers) of a IIR filter to a constant DC input
% INPUTS: b - numerator coefficients, a - denominator coefficients, x0 - DC input 
% OUTPUTS: zi - initialized filter taps (delay registers), y0 - DC output 
%
  
  if (nargin == 1) && (ischar(b) && strcmpi(b, 'unittest'))
    unitTest;
    return;
  end
  
  assert(length(b) == length(a));
  
  % autocalculate y0 to constant value such that filter is in equilibrium
  y0 = x0 * sum(b) / (1 + sum(a(2:end)));
  
  zi = zeros(1,max(length(a), length(b)));
  
  zi(end) = b(end)*x0 - y0*a(end);
  for i=length(zi)-1:-1:1
    zi(i) = zi(i+1) + (x0*b(i) - y0*a(i));
  end
  zi = zi(2:end);
  
end


function unitTest
  
  for iType = {'high', 'low'}
    for iW = [0.1:0.1:0.9]
      for iOrder = 1:1:10
        
        [b,a] = butter (iOrder, iW, iType{1});
        x0 = randn();
        [si, y0] = initIir(b, a, x0);
        
        
        % taken from octave's filtfilt(...)
        % see also: Likhterov & Kopeika, 2003. "Hardware-efficient technique for
        %       minimizing startup transients in Direct Form II digital filters"
        kdc = sum(b) / sum(a);
        if (abs(kdc) < inf) % neither NaN nor +/- Inf
          zi = fliplr(cumsum(fliplr(b - kdc * a)));
        else
          zi = zeros(size(a)); % fall back to zero initialization
        end
        zi(1) = [];
        zi = zi * x0;
        
        assert(isEqualWithinPercentage(kdc*x0, y0, 1E-3));
        for i=1:length(zi)  % terribly inefficient - shame on me
          assert(isEqualWithinPercentage(zi(i), si(i), 1E-3));
        end
        
      end
    end
  end
  
  display('unit test successfull!');
  
end


function equal = isEqualWithinPercentage(a, b, percentage)
  
  if a == 0 && b == 0
    equal = true;
  else
    equal = abs((a-b)/mean([a,b])) < percentage/100;
  end
  
end