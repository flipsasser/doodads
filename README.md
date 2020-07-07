# Doodads

<table style="border-collapse: collapse; width: 100%;">
	<tbody>
		<tr>
			<td rowspan="2" style="padding: 0;">
				```This is a code block```
			</td>
			<td style="padding: 0;">
				This is an ERB block
			</td>
		</tr>
		<tr>
			<td style="padding: 0;">
				I go under the other thing
			</td>
		</tr>
	</tbody>
</table>

Meet Doodads! This is poorly-named but well-built Rails engine does exactly two things really well:

1. **It makes defining custom view components simple.** Use the DSL to define view helpers that save you time and energy when rendering out common application components.
2. **It makes adding screen reader accessibility as easy as possible.** Doodads supports quick shortcuts for `aria-` linkages, but it also allows you to link rendered components to one-another in order to make the web as easy to use for as many people as we possibly can.

Meet Doodads! It's a Rails engine that helps define the HTML structure of your view components, allowing you to quickly and consistently build interfaces with a custom component library.

It has a simple, declarative DSL you can use to define very complex structures and relationships. Components are defined inside of ActionView helper modules, which eases development by piggybacking on Rails' code-reloading:

```ruby
module ApplicationHelper
  component :cards do
    component :item, link: :optional do
      modifier :flush
      modifier :compact, "is-compact"

      component :action, link: :nested, tagname: :footer
    end
  end
end
```

Will generate a `cards` helper method you can use in your views:

```html.erb
<section class="container">
  <h2>Check out this list of things in a card format</h2>
  <%= cards do %>
    <%= item "This is a card with text content", flush: true %>
    <%= item "This is a compact card with a URL", new_user_path, compact: true %>
    <%= item "This is a card with a footer pointing somewhere" do %>
      <%= action "View details", user_path(current_user) %>
    <% end %>
  <% end %>
</section>
```

That helper method generates the requisite HTML with `class` and `href` correctly defined:

```html
<section class="container">
  <h2>Check out this list of things in a card format</h2>
  <div class="cards">
    <div class="cards-item card-item--flush">This is a card with text content</div>
    <a class="cards-item card-item--is-compact" href="/users/new">This is a compact card with a URL</a>
    <div class="cards-item">
      This is a card with a footer pointing somewhere
      <footer class="cards-item-action cards-item-action--has-link">
        <a class="cards-item-action-link" href="/users/1">View details</a>
      </footer>
    </div>
  </div>
</section>
```

## Customizing the HTML output

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
