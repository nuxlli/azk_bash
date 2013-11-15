function __fish_azk_needs_command
  set cmd (commandline -opc)
  if [ (count $cmd) -eq 1 -a $cmd[1] = 'azk' ]
    return 0
  end
  return 1
end

function __fish_azk_using_command
  set cmd (commandline -opc)
  if [ (count $cmd) -gt 1 ]
    if [ $argv[1] = $cmd[2] ]
      return 0
    end
  end
  return 1
end

complete -f -c azk -n '__fish_azk_needs_command' -a '(azk commands)'
for cmd in (azk commands)
  complete -f -c azk -n "__fish_azk_using_command $cmd" -a "(azk completions $cmd)"
end
