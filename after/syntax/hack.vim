" Syntax files for .hack files
syn include @php <sfile>:p:h/php.vim
syn region hackRegion start="\%^" end="\%$" contains=@phpClTop
