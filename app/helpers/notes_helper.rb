module NotesHelper
  def markdown(text)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true)
    sanitize markdown.render(text)
  end
end
