return {
     -- "ekickx/clipboard-image.nvim",
     -- event = "VeryLazy",
     -- config = function()
     --    require'clipboard-image'.setup {
     --      markdown = {
     --       img_dir = {"images", "%:p:h:t", "%:t:r"},
     --       img_dir_txt = {"images", "%:p:h:t", "%:t:r"},
     --       img_name = function ()
     --          vim.fn.inputsave()
     --          local name = vim.fn.input('Name: ')
     --          vim.fn.inputrestore()

     --          if name == nil or name == '' then
     --            return os.date('%y-%m-%d-%H-%M-%S')
     --          end
     --          return name
     --        end,
     --      }
     --    }
     --    -- require('clipboard-image').setup {
     --    --   default = {
     --    --     -- img_dir = "images",
     --    --     img_name = function ()
     --    --       vim.fn.inputsave()
     --    --       local name = vim.fn.input('Name: ')
     --    --       vim.fn.inputrestore()
     --    --       return name
     --    --     end,
     --    --     -- img_name = function() return os.date('%Y-%m-%d-%H-%M-%S') end, -- Example result: "2021-04-13-10-04-18"
     --    --     -- affix = "<\n  %s\n>" -- Multi lines affix
     --    --   },
     --    --   -- You can create configuration for ceartain filetype by creating another field (markdown, in this case)
     --    --   -- If you're uncertain what to name your field to, you can run `lua print(vim.bo.filetype)`
     --    --   -- Missing options from `markdown` field will be replaced by options from `default` field
     --    --   markdown = {
     --    --     img_dir = {"src", "assets", "img"}, -- Use table for nested dir (New feature form PR #20)
     --    --     img_dir_txt = "/images/",
     --    --     img_handler = function(img) -- New feature from PR #22
     --    --       local script = string.format('./image_compressor.sh "%s"', img.path)
     --    --       os.execute(script)
     --    --     end,
     --    --   }
     --    -- }

     --    -- local function paste_url(url)
     --    --   url = url.args
     --    --   local utils = require "clipboard-image.utils"
     --    --   local conf_utils = require "clipboard-image.config"

     --    --   local conf_toload = conf_utils.get_usable_config()
     --    --   local conf = conf_utils.load_config(conf_toload)

     --    --   utils.insert_txt(conf.affix, url)
     --    -- end

     --    -- -- Now let's create the command (works on neovim 0.7+)
     --    -- local create_command = vim.api.nvim_create_user_command
     --    -- create_command("PasteImgUrl", paste_url, { nargs=1 })
     -- end
   }
