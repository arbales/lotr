# Monkey-patch Gollum to accept committer names and 
# emails we specify during a before filter.
class Gollum::Wiki
  def default_committer_name
    self.class.default_committer_name
  end
  def default_committer_email
    self.class.default_committer_email
  end
end
