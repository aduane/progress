# frozen_string_literal: true

# Main helper file
module ApplicationHelper
  def progress_bar(label:, numerator:, denominator:, units:)
    percent = ((numerator.to_f / denominator.to_f) * 100).round(1)
    content_tag(:div) do
      content_tag(:span, label) +
        content_tag(:progress, nil, class: 'bar', max: denominator,
                                    value: numerator) +
        content_tag(:span,
                    "#{numerator} / #{denominator} #{units} – #{percent}% " \
                    'complete')
    end
  end
end
