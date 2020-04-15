module ApplicationHelper

  def link_to_add_fields(name, f, association)
    fields = render("#{association.to_s.singularize}_fields", f: f)
    link_to(name, '#', class: 'add_fields', 
            data: { fields: fields })
  end
end
