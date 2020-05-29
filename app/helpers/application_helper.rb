module ApplicationHelper

  def link_to_add_fields(name, f, association)
    fields = render("#{association.to_s.singularize}_fields", f: f)
    link_to(name, '#', class: 'add_fields', 
            data: { fields: fields }, remote: true)
  end

  def should_display_cart?(current_order)
    current_order&.cart? && current_order&.line_items&.any?
  end
end
