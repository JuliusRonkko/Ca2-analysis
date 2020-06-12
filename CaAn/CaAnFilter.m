st = get(dpfilters,'value');
[loca, param] = feval(mt(st).name(1:end-2),fnm,region);

region.filtername = mt(st).name(1:end-2);
region.filterparam = param;

num = 1;
CaAnInputParams;