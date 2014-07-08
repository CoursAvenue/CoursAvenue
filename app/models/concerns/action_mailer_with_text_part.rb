module ActionMailerWithTextPart
  def collect_responses(headers)
    responses = super headers
    html_part = responses.detect { |response| response[:content_type] == "text/html" }
    text_part = responses.detect { |response| response[:content_type] == "text/plain" }
    if html_part && ! text_part
      body_parts = []
      Nokogiri::HTML(html_part[:body]).traverse do |node|
        if node.text? and ! (content = node.content ? node.content.strip : nil).blank?
          body_parts << content
        elsif node.name == "a" && (href = node.attr("href")) && href.match(/^https?:/)
          body_parts << href
        end
      end
      responses.insert 0, { content_type: "text/plain", body: body_parts.uniq.join("\n") }
      headers[:parts_order] = [ "text/plain" ] + headers[:parts_order] unless headers[:parts_order].include?("text/plain")
    end
    responses
  end
end
