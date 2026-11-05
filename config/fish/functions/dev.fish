function dev --description "Select and enter a project under ~/Code"
    set project (fd -H -t d '^\.git$' ~/Code -d 4 | sed 's|/.git/$||' | fzf --prompt="Project > " --with-nth=-1)

    if test -n "$project"
        cd "$project"
    end
end
