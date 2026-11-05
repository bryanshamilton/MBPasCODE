function dev --description "Select a project, safely update it, and start Copilot"
    set project (fd -H -t d '^\.git$' ~/Code -d 4 | sed 's|/.git/$||' | fzf --prompt="Project > " --with-nth=-1)

    if test -z "$project"
        return
    end

    cd "$project"

    echo
    echo "Fetching latest from GitHub..."
    git fetch --quiet

    set upstream (git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)

    if test -n "$upstream"
        git merge --ff-only "$upstream"
        or echo "Unable to fast-forward safely. Leaving repository unchanged."
    else
        echo "Current branch has no upstream. Skipping update."
    end

    echo
    git status --short --branch
    echo

    copilot
end
