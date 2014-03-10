module NotesHelper
  def markdown(text)
    sanitize GitHub::Markdown.render_gfm(text)
  end
end
