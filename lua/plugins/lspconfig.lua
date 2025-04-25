-- shared by Vincent
if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

local on_attach = function(client, bufnr)
    local keymap = function(mode, keys, func, opts)
        opts.buffer = bufnr
        vim.keymap.set(mode, keys, func, opts)
    end

    keymap('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
    keymap('n', 'gD', vim.lsp.buf.declaration, { desc = 'Go to declaration' })
    keymap('n', 'gi', vim.lsp.buf.implementation, { desc = 'Go to implementation' })
    keymap('n', 'gy', vim.lsp.buf.type_definition, { desc = 'Go to type definition' })
    keymap('n', 'gr', vim.lsp.buf.references, { desc = 'List references' })

    keymap('n', '<leader>ds', vim.lsp.buf.document_symbol, { desc = 'List document symbols' })
    keymap('n', '<leader>ws', vim.lsp.buf.workspace_symbol, { desc = 'List workspace symbols' })

    keymap('n', 'K', vim.lsp.buf.hover, { desc = 'Show documentation' })
    keymap('n', 'gK', vim.lsp.buf.signature_help, { desc = 'Show signature' })
    keymap('i', '<C-k>', vim.lsp.buf.signature_help, { desc = 'Show signature' })

    keymap('n', '<leader>lr', vim.lsp.buf.rename, { desc = 'Rename symbol' })
    keymap('n', '<leader>lc', vim.lsp.buf.code_action, { desc = 'Code action' })

    keymap('n', '<Leader>ep', vim.diagnostic.goto_prev, { desc = 'Goto previous diagnostic' })
    keymap('n', '<Leader>en', vim.diagnostic.goto_next, { desc = 'Goto next diagnostic' })

    keymap('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, { desc = 'Add workspace folder' })
    keymap('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, { desc = 'Remove workspace folder' })
    keymap(
        'n',
        '<leader>wl',
        function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
        { desc = 'List workspace folders' }
    )
end



local rust_analyzer_options = {
    checkOnSave = true,
    cargo = {
        extraArgs = { "--target-dir", "target/rust-analyzer" },
    },
    check = {
        command = "clippy",
        extraArgs = { "--target-dir", "target/rust-analyzer" },
    },
    rustfmt = {
        extraArgs = { "--target-dir", "target/rust-analyzer" },
    }

}

if vim.env.IN_NIX_SHELL then
    rust_analyzer_options = {
        checkOnSave = true,
        cargo = {
            -- target = "x86_64-unknown-linux-musl",
            target = "x86_64-win7-windows-msvc",
            -- target = "x86_64-apple-darwin",
            extraArgs = { "--target-dir", "target/rust-analyzer" },
        },
        check = {
            extraArgs = { "--target-dir", "target/rust-analyzer" },
        },
        rustfmt = {
            extraArgs = { "--target-dir", "target/rust-analyzer" },
        }
    }
end



return {
    'neovim/nvim-lspconfig',
    ft = { 'c', 'clojure', 'javascript', 'python', 'rust', 'typescript', 'vue', 'zig' },
    dependencies = {
        -- to ensure PATH set by mason is used
        'williamboman/mason.nvim',
        -- to get info on LSP servers statuses
        'j-hui/fidget.nvim',
        -- to integrate with completion handlers
        'hrsh7th/cmp-nvim-lsp',
    },

    opts = {
        servers = {
            basedpyright = { settings = {} },
            clangd = { settings = {} },
            clojure_lsp = {
                settings = {},
                autoformat = true,
            },
            eslint = { settings = {} },
            rust_analyzer = {
                settings = {
                    ['rust-analyzer'] = rust_analyzer_options,
                },
                autoformat = true,
            },
            ruff = { settings = {} },
            ts_ls = {
                settings = {
                    init_options = {
                        plugins = { {
                            name = "@vue/typescript-plugin",
                            location = "",
                            languages = {"javascript", "typescript", "vue"},
                        } },
                    },
                    filetypes = { "javascript", "typescript", "vue" }
                }
            },
            volar = { settings = {} },
            zls = { settings = {} },
        },
    },

    config = function(_, opts)
        local lspconfig = require('lspconfig');
        local capabilities = require('cmp_nvim_lsp').default_capabilities()

        for name, conf in pairs(opts.servers) do
            local autoformat = false

            if conf.autoformat then
                autoformat = true
            end

            lspconfig[name].setup {
                capabilities = capabilities,
                on_attach = function(client, bufnr)
                    vim.b[bufnr].autoformat = autoformat
                    local _, err = pcall(on_attach, client, bufnr)
                    if err then
                        vim.notify('[on_attach] error: ' .. err, vim.log.levels.ERROR)
                    else
                        vim.notify('[on_attach] ' .. client.name .. ' attached to buffer ' .. bufnr, vim.log.levels.INFO)
                    end
                end,
                settings = conf.settings,
            }
        end
    end
}
