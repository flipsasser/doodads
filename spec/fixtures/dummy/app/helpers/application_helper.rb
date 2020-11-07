# frozen_string_literal: true

module ApplicationHelper
  include Doodads::Helper

  flags %i[informational success danger warning]

  component :button

  component :nav do
    component :logo, tag: :img

    wrapper :ol, class: "nav-list" do
      component :item, link: :nested, tag: :li
    end
  end
end
