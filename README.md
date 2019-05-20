# Doodads

#### **⚠️THIS PROJECT IS A WORK IN PROGRESS!⚠️**

Meet Doodads! It's a simple way to define HTML components, allowing you to quickly and consistently buiild interfaces with your custom component library. It's real easy to use with its DSL:

```ruby
module ApplicationHelper
  extend Doodads::DSL

  component :button, link: true do
  	modifier :outline
  end
end
```

Will generate a helper method you can use in your views, like so:

```html.erb
<section class="container">
  Ready to add something to a thing?
  <%= button "Add a thing", new_thing_path, outline: true %>
</section>
```

This will generate HTML output like so:

```html
<section class="container">
  Ready to add something to a thing?
  <a class="button button--outline" href="/things/new">Add a thing</a>
</section>
```

## Custom HTML Structure

When you define a component, you can override tagname (defaults to `div` unless the `link` option is set to `true` - in which case it uses an `a` tag), class name (defaults to the [Maintainable CSS](https://maintainablecss.com/chapters/introduction/) apporach but custom strategies can be added), nest content in a hierarchy of elements, and add context-specific sub-components.

A great example is nav components, which are often simply UL's nested in a nav object:

```ruby
module ApplicationHelper
  extend Doodads::DSL

  component :nav, class: "nav-container", tagname: :nav do
	container :ul do
	  component :item, tagname: :li
	end
  end
end
```

Which would allow the following template:

```html.erb
<%= nav do %>
  <%= item link_to("Home", root_path) %>
  <%= item link_to("Things", things_path) %>
  <%= item link_to("Stuff", stuff_path) %>
<% end %>
```

And produce the following markup:

```html
<nav class="nav-container">
  <ul>
    <li class="nav-container-item"><a href="/">Home</a></li>
    <li class="nav-container-item"><a href="/things">Things</a></li>
    <li class="nav-container-item"><a href="/stuff">Stuff</a></li>
  </ul>
</nav>
```

## Class Name Inheritance

Doodads autoamtically provides context-specific classnames for nested components not related by a common hierarchy.

```ruby
module ApplicationHelper
  extend Doodads::DSL

  component :list, tagname: :ul do
    component :item, tagname: :li
  end

  component :badge
end
```

Then, if you were to nest a badge inside of a list like so:

```html.erb
<%= list do %>
  <%= item do %>
    <%= badge "Success!" %>
  <% end %>
<% end %>
```

You would have the following markup:

```html
<ul class="list">
  <li class="list-item">
    <div class="badge list-badge">Success!</div>
  </li>
</ul>
```

## Modifier Sets

Sometimes you reuse modifiers, like the common Bootstrap flags "success", "info", "warning", "error", etc. You can easily define common modifiers and then apply them to components using the `modifiers` method:

```ruby
module ApplicationHelper
  extend Doodads::DSL

  modifier_set :statuses, %w[success info warning error etc etc etc]

  component :badge do
    modifiers :statuses
  end
end
```

You can also provide a hash to a modifier set instead of an array, which allows you to provide aliases for modifiers. This allows you to write your views with domain-model context that translates to more generic HTML classes:

```
module ApplicationHelper
  extend Doodads::DSL

  modifier_set :opportunity_statuses, {
    draft: :neutral,
    open: :info,
    closed_won: :success,
    closed_lost: :warning,
  }

  component :badge do
    modifiers :opportunity_statuses
  end
end
```

Thus you might invoke a badge with

```erb
<%= badge "Closed/Won", closed_won: true %>
```

Which would produce

```
<div class="badge badge--success">Closed/Won</div>
```
