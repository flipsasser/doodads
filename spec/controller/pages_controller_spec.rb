# frozen_string_literal: true

require "spec_helper"

RSpec.describe PagesController, clear: false, type: :controller do
  render_views

  it "successfully renders the nav component" do
    get :index
    expect(response.body).to match(Regexp.new(%(<nav class="nav">)))
    expect(response.body).to match(Regexp.new(%(<li class="nav-item nav-item--has-link"><a class="nav-item-link nav-item-link--active" href="/">Home</a></li>)))
    expect(response.body).to match(Regexp.new(%(<li class="nav-item nav-item--has-link"><a class="nav-item-link" href="/test">Test</a></li>)))
  end
end
