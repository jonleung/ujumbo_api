class ShowInBrowser
  FILE_LOCATION = "/tmp"
  FILE_NAME = "browser"

  class << self

    def show(body, extension=".html")
      full_path = "#{FILE_LOCATION}/#{FILE_NAME}#{extension}"
      file = File.open(full_path, 'w:UTF-8')
      file.write(body)
      file.close
      `/usr/bin/open -a "/Applications/Google Chrome.app" "http://localhost:8000/#{FILE_NAME}#{extension}"`
      puts body
    end

  end
end