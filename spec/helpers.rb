module Helpers
  def file_fixture_path(*path)
    paths = ['spec/fixtures'] + path
    Bundler.root.join(*paths).to_s
  end
end
