# Doodads

Custom HTML component helpers with ARIA accessibility baked in.

<table cellpadding="0" cellspacing="0" width="100%">
	<tbody>
		<tr>
			<td rowspan="2" style="padding: 0;">
				<pre><code>module ApplicationHelper
  component :cards do
    component :item, link: :optional do
      flag :flush
      flag :compact, "is-compact"

      component :action, link: :nested, tagname: :footer
    end
  end
end</code></pre>
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

Meet Doodads! This poorly-named but well-built Rails engine does exactly two things really well:

1. **It makes defining reusable view components extremely simple.** Use the DSL to define view helpers that save you time and energy when rendering out common application components.
2. **It makes adding screen reader accessibility as easy as possible.** Doodads supports quick shortcuts for `aria-` linkages, but it also allows you to **link rendered components to one-another** in order to make the web as easy to use for as many people as we possibly can.

## Components

At its core, Doodads allows you to define components that you then use to build your application. You can do it using the Doodads DSL, or by adding your own components that inherit from `Doodads::Component`.

### Defining components with the DSL

Doodads has a simple, declarative DSL you can use to define very complex structures and relationships. Components are defined inside of ActionView helper modules, which eases development by piggybacking on Rails' code-reloading:

```ruby
module ApplicationHelper
  include Doodads::Helper

  component :cards do
    component :item, link: :optional do
      flag :flush
      flag :compact, "is-compact"

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


#### Component options

When defining a component (either via DSL or subclassing), you can specify a number of configuration options. They can

<table>
  <thead>
    <tr>
      <th>Option</th>
      <th>Description</th>
      <th>Type</th>
      <th>Default</th>
      <th>Notes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>as</code></td>
      <td>The name of the component. This is also how you render it, e.g. <code>component :button, as: :button_link</code> is rendered with <code><%= button_link "Link content" %></code></td>
      <td><code>String</code> or <code>Symbol</code></td>
      <td>The name passed into the DSL or an underscored version of the class name</td>
      <td>Automatically converted to a lowercase, underscored method name</td>
    </tr>
    <tr>
      <td><code>class_name</code></td>
      <td>The base class name that will be passed to the CSS strategy and converted to a CSS class.</td>
      <td><code>String</code> or <code>Symbol</code></td>
      <td>The name of the component, e.g. <code>component :button</code> defaults to <code>class_name: :button</code></td>
      <td>This value is often passed to a CSS strategy which modifies it further. To force an explicit <code>class_name</code> rather than having a strategy modify it, set the <code>strategy</code> option on the component itself or globally</td>
    </tr>
    <tr>
      <td><code>link</code></td>
      <td>Allows components to render as links using <code>link_to</code>, or nest links within a wrapper (as in an <code>ol > li > a</code> navigation context)</td>
      <td><code>Boolean</code>, <code>:nested</code>, <code>:optional</code>, or an array of options, e.g. <code>[:nested, :optional]</code></td>
      <td><code>false</code></td>
      <td>
        When <code>link</code> is...
        <ul>
          <li><code>true</code>, the component will require a URL argument, identically to <code>link_to</code> (e.g. either <code>link_to "Link text", link_url</code> or <code>link_to link_url { "Link text" }</code>)</li>
          <li><code>false</code>, it will not accept URL arguments or render as a link, period</li>
          <li><code>:nested</code>, the component will require a URL argument as when <code>true</code>, but it will nest the link within the component, e.g. <code>&lt;li class="nav-item nav-item--has-link"&gt;&lt;a class="nav-item-link" href="/home"&gt;Link content&lt;/a&gt;&lt;/li&gt;</code></li>
          <li><code>:optional</code> then the component will decided how to render based on the presence of a URL argument</li>
          <li>An array of options, it will mix the behavior, e.g. <code>[:nested, :optional]</code> makes the URL argument optional, but nests the link when a URL is present</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td><code>link_class</code></td>
      <td>The <code>class_name</code> base, passed to your strategy, to generate the link class name.</td>
      <td><code>String</code> or <code>Symbol</code></td>
      <td><code>:link</code></td>
      <td>This can be definied globally via <code>Doodads.config.link_class = "is-a-link"</code></td>
    </tr>
    <tr>
      <td><code>link_flag</code></td>
      <td>The <code>class_name</code> base for the parent of a nested link, passed to your strategy, to generate a "has-a-link" class name.</td>
      <td><code>String</code> or <code>Symbol</code></td>
      <td><code>:has_link</code></td>
      <td>This can be definied globally via <code>Doodads.config.link_flag = "contains-a-link"</code></td>
    </tr>
    <tr>
      <td><code>tagname</code></td>
      <td>The HTML tag the component will generate</td>
      <td><code>String</code> or <code>Symbol</code></td>
      <td><code>:div</code>, unless the component name matches a valid HTML content tag, like <code>button</code> or <code>nav</code>.</td>
      <td>If a component is linkable, this will be overridden to be an anchor tag (e.g. <code>&lt;a&gt;</code>)</td>
    </tr>
  </tbody>
</table>


#### Wrapping component content

##### IMPORTANT! Primary content vs. subcomponents


### Defining components as subclases of `Doodads::Component`

Doodads allows you to define component a second way: subclassing `Doodads::Component`. Doing this, you can add more complex rendering logic in the `render` method, including using your own internal what-have-yous.

Custom components typically live in `app/components`, but Doodads will check for `app/doodads` as well. We're just thoughtful like that.

#### Custom rendering

A custom component can override `Doodads::Component#render` to receive two arguments: the content inside the component and an options hash corresponding to the HTML attributes that will be rendered:

```ruby
class Button < Doodads::Component
  link :optional

  def render(content, options = {})
    if link?
      # `link?` will return true if the button has been rendered with a URL argument
      link_to(content, url, options)
    else
      # `tagname` will infer itself to be `:button` based on the name of the component
      content_tag(tagname, content, options)
    end
  end
end
```

The core of Doodads is a `render` method that accepts a **normalized** set of arguments which are generated from the rendering process inside a view. The result is such that the following all produce the same arguments:

```html.erb
<%= button "Sign In", new_session_path, outline: true %> # Button#render(:a, '<span class="button-content">Sign In</span>', "/sessions/new", {class: "button button--outline"})
<%= button new_session_path, outline: true do %>Sign In<% end %> # Button#render(:a, '<span class="button-content">Sign In</span>', "/sessions/new", {class: "button button--outline"})
<%= button "Sign In" %> # Button#render(:button, '<span class="button-content">Sign In</span>', nil, {class: "button button--outline"}) )
```

### Rendering components

## Accessibility shortcuts

## Linking accessible components



## Customizing the HTML output

When you define a component, you can override tagname (defaults to `div` unless the `link` option is set to `true` - in which case it uses an `a` tag), class name (defaults to the [Maintainable CSS](https://maintainablecss.com/chapters/introduction/) apporach but custom strategies can be added), nest content in a hierarchy of elements, and add context-specific sub-components.

A great example is nav components, which are often simply UL's nested in a nav object:

```ruby
module ApplicationHelper
  extend Doodads::DSL

  component :nav, class: "nav-container", tagname: :nav do
	  wrapper :ul do
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

## Flags

Doodads supports defining class that, when used at rendering-time, allow you to modify the class name of a component, render other components inside its content, or generate shortcuts for more complex HTML attribute sets.

When configured using Doodads' simple DSL, flags can be extremely powerful. A simple request like the following...

```html.erb
<%= badge "Learn more", learn_more_path, icon: :exclamation, icon_position: :end, info: true, label: "Click Here To" %>
```

...can produce extremely useful, accessible, and complex HTML:

```html
<a class="badge badge--informational badge--has-icon" aria-label="Click Here To" href="/learn-more">
  <span class="badge-content">Learn More</span>
  <em aria-hidden class="icon bage-icon">
    <svg src="/icons.svg#exclamation" />
  </em>
</a>
```

Read on to learn more about how unbelievably awesome flags are!

### Defining flags per-component

You can define a flag on a component directly using the following shorthand:

```ruby
module ApplicationHelper
  extend Doodads::DSL

  component :badge do
    flag :info, :informational # Adds an `info` flag that will append an `informational` class name using your chosen CSS strategy
    flag :label, attribute: "aria-label" # Adds an attribute shortcut that, when the component sees a `:label` option, will be translated into an `aria-label` attribute
    flag :icon, component: :icon # Adds a content shortcut that will render a component
  end

  component :icon do
    render do |icon_name|
      content_tag(:em) { content_tag(:svg, src: asset_path("icons.svg##{icon_name}")) }
    end
  end
end
```

### Defining reusable flag sets

Sometimes you reuse class name extensions, like the common Bootstrap statuses "success", "info", "warning", "error", etc. You can easily define common flags and then apply them to components using the `flags` top-level method, and `use_flags` within a component:

```ruby
module ApplicationHelper
  extend Doodads::DSL

  flags :statuses, %w[success info warning error etc etc etc]

  component :badge do
    use_flags :statuses
  end
end
```

You can also provide a hash to a flag set instead of an array, which allows you to provide aliases for flags. This allows you to write your views with domain-model context that translates to more generic HTML classes:

```ruby
module ApplicationHelper
  extend Doodads::DSL

  flag_set :opportunity_statuses, {
    draft: :neutral,
    open: :info,
    closed_won: :success,
    closed_lost: :warning,
  }

  component :badge do
    use_flags :opportunity_statuses
  end
end
```

Thus you might invoke a badge with

```html.erb
<%= badge "Closed/Won", closed_won: true %>
```

Which would produce

```html
<div class="badge badge--success">Closed/Won</div>
```

### Globally available flags

If you have a set of flags that _every_ component should use, you can simply pass `global: true` to the flag definition like so:


