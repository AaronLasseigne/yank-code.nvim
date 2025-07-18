# YankCode (neovim)

Yank code to the clipboard. Code is automatically unindented. A header is added
in the form of a comment that includes the file name and lines copied. Adding
the header relies on `commentstring` being set correctly. If `commentstring` is
set to an empty string (e.g. JSON), no header will be added.

Instead of yanking:

```ruby
    def valid?(*)
      if instance_variable_defined?(:@_interaction_valid)
        return @_interaction_valid
      end

      super
    end
```

You'll get:

```ruby
# lib/active_interaction/concerns/runnable.rb (lines 48-54)
def valid?(*)
  if instance_variable_defined?(:@_interaction_valid)
    return @_interaction_valid
  end

  super
end
```

Now you're ready to paste it into Slack or wherever you need!

## Installation

## Lazy

```vim
{
  'AaronLasseigne/yank-code.nvim',
  keys = {
    { '<leader>y', ':YankCode<CR>', mode = '', desc = 'Yank Code' }
  },
  config = function()
    require('yank-code').setup()
  end
}
```

## Usage

Use it just like you would yank!

YankCode is licensed under [the MIT License][].

[the mit license]: LICENSE.txt
