function qcd --description 'Expand a run of q characters into cd ../.. one level per q'
    echo cd (string repeat -n (string length -- $argv[1]) ../)
end
