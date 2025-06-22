local M = {}

function M.get_workspace()
    -- Get the home directory of your operating system
    local home = os.getenv("HOME")
    -- Declare a directory where you would like to store project information
    local workspace_path = home .. "/.local/workspace/"
    -- Determine the project name
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
    -- Create the workspace directory by concatenating the designated workspace path and the project name
    local workspace_dir = workspace_path .. project_name
    return workspace_dir
end

return M
