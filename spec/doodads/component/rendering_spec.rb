# frozen_string_literal: true

require "spec_helper"

class ViewContext
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include Doodads::Helper

  attr_accessor :output_buffer

  flags %i[danger error informational success warning]

  component :link_button, class: "button", link: true
  component :submit_button, class: "button", link: :optional

  component :nav, tag: :nav do
    wrapper :ul do
      component :item, link: :nested, tag: :li
    end
  end

  component :cards do
    component :item
  end

  def request
    OpenStruct.new(path: "/test", url: "http://example.com/test")
  end
end

RSpec.describe Doodads::Component, "#render", clear: false do
  let(:view) { ViewContext.new }

  describe "in the root context" do
    describe "link components" do
      it "require a URL" do
        expect { view.link_button("Button") }.to raise_error(Doodads::Errors::URLRequiredError)
      end

      it "generates an <a> tag" do
        expect(view.link_button("Button", "/").to_s).to eq(%(<a class="button" href="/">Button</a>))
      end
    end

    describe "optional link components" do
      it "renders without a URL argument" do
        expect(view.submit_button("Button").to_s).to eq(%(<div class="button">Button</div>))
      end

      it "renders with a URL argument" do
        expect(view.submit_button("Link Button", "#").to_s).to eq(%(<a class="button" href="#">Link Button</a>))
      end
    end

    describe "nested link components" do
      it "renders a link within the sub-components" do
        result = view.nav {
          item "Home", "/home"
        }
        expect(result.to_s).to eq(%(<nav class="nav"><ul><li class="nav-item nav-item--has-link"><a class="nav-item-link" href="/home">Home</a></li></ul></nav>))
      end
    end
  end

  xdescribe "in another component's context" do
    # TODO: Is this important?
    it "prefers the immediate component's child components" do
      result = view.cards {
        nav { item("Home", "/") }
      }
      expect(result.to_s).to eq(%(<div class="cards"><nav class="nav cards-nav"><ul><li class="nav-item nav-item--has-link"><a class="nav-item-link" href="/">Home</a></li></ul></nav></div>))
    end
  end
end
