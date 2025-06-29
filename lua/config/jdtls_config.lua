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

-- TODO: eliminate literal
function M.get_java_debugger()
    return vim.fn.glob(os.getenv("HOME") .. "/.local/share/nvim/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar", 1)
end

function M.java_keymaps()
    -- Allow yourself to run JdtCompile as a Vim command
    vim.cmd("command! -buffer -nargs=? -complete=custom,v:lua.require'jdtls'._complete_compile JdtCompile lua require('jdtls').compile(<f-args>)")
    -- Allow yourself/register to run JdtUpdateConfig as a Vim command
    vim.cmd("command! -buffer JdtUpdateConfig lua require('jdtls').update_project_config()")
    -- Allow yourself/register to run JdtBytecode as a Vim command
    vim.cmd("command! -buffer JdtBytecode lua require('jdtls').javap()")
    -- Allow yourself/register to run JdtShell as a Vim command
    vim.cmd("command! -buffer JdtJshell lua require('jdtls').jshell()")

    -- Set a Vim motion to <Space> + <Shift>J + o to organize imports in normal mode
    vim.keymap.set('n', '<leader>Jo', "<Cmd> lua require('jdtls').organize_imports()<CR>", { desc = "[J]ava [O]rganize Imports" })
    -- Set a Vim motion to <Space> + <Shift>J + v to extract the code under the cursor to a variable
    vim.keymap.set('n', '<leader>Jv', "<Cmd> lua require('jdtls').extract_variable()<CR>", { desc = "[J]ava Extract [V]ariable" })
    -- Set a Vim motion to <Space> + <Shift>J + v to extract the code selected in visual mode to a variable
    vim.keymap.set('v', '<leader>Jv', "<Esc><Cmd> lua require('jdtls').extract_variable(true)<CR>", { desc = "[J]ava Extract [V]ariable" })
    -- Set a Vim motion to <Space> + <Shift>J + <Shift>C to extract the code under the cursor to a static variable
    vim.keymap.set('n', '<leader>JC', "<Cmd> lua require('jdtls').extract_constant()<CR>", { desc = "[J]ava Extract [C]onstant" })
    -- Set a Vim motion to <Space> + <Shift>J + <Shift>C to extract the code selected in visual mode to a static variable
    vim.keymap.set('v', '<leader>JC', "<Esc><Cmd> lua require('jdtls').extract_constant(true)<CR>", { desc = "[J]ava Extract [C]onstant" })
    -- Set a Vim motion to <Space> + <Shift>J + t to run the test method currently under the cursor
    vim.keymap.set('n', '<leader>Jt', "<Cmd> lua require('jdtls').test_nearest_method()<CR>", { desc = "[J]ava [T]est Method" })
    -- Set a Vim motion to <Space> + <Shift>J + t to run the test method that is currently selected in visual mode
    vim.keymap.set('v', '<leader>Jt', "<Esc><Cmd> lua require('jdtls').test_nearest_method(true)<CR>", { desc = "[J]ava [T]est Method" })
    -- Set a Vim motion to <Space> + <Shift>J + <Shift>T to run an entire test suite (class)
    vim.keymap.set('n', '<leader>JT', "<Cmd> lua require('jdtls').test_class()<CR>", { desc = "[J]ava [T]est Class" })
    -- Set a Vim motion to <Space> + <Shift>J + u to update the project configuration
    vim.keymap.set('n', '<leader>Ju', "<Cmd> JdtUpdateConfig<CR>", { desc = "[J]ava [U]pdate Config" })
end

function M.on_attach(_, bufnr)
    -- Map the Java specific key mappings once the server is attached
    M.java_keymaps()

    -- Setup the java debug adapter of the JDTLS server
    require('jdtls.dap').setup_dap()

    -- Find the main method(s) of the application so the debug adapter can successfully start up the application
    -- Sometimes this will randomly fail if language server takes to long to startup for the project, if a ClassDefNotFoundException occurs when running
    -- the debug tool, attempt to run the debug tool while in the main class of the application, or restart the neovim instance
    -- Unfortunately I have not found an elegant way to ensure this works 100%
    require('jdtls.dap').setup_dap_main_class_configs()
    -- Enable jdtls commands to be used in Neovim
    require 'jdtls.setup'.add_commands()
    -- Refresh the codelens
    -- Code lens enables features such as code reference counts, implemenation counts, and more.
    vim.lsp.codelens.refresh()

    -- Setup a function that automatically runs every time a java file is saved to refresh the code lens
    vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = { "*.java" },
        callback = function()
            local _, _ = pcall(vim.lsp.codelens.refresh)
        end
    })
end

return M
