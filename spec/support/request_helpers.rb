module RequestHelpers
  def json
    return {} if response.body.blank?
    JSON.parse(response.body)
  rescue JSON::ParserError
    {}
  end
end
