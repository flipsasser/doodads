# frozen_string_literal: true

module ApplicationHelper
  include Doodads::Helper

  flags :status, %i[informational success danger warning]

  component :button do
    use_flags :status
  end

  component :nav do
    component :logo, tagname: :img

    wrapper :ol, class: "nav-list" do
      component :item, link: :nested, tagname: :li
    end
  end
end
