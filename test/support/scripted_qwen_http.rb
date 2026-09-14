# frozen_string_literal: true

# Supplies queued HTTP replies so integration tests exercise QwenRunner offline.
class ScriptedQwenHttp
  Response = Data.define(:code, :body)

  def initialize(*responses)
    @responses = responses
  end

  def get_response(_uri)
    Response.new(code: '200', body: '{"data":[{"id":"ggml-org/Qwen3.5-0.8B-GGUF"}]}')
  end

  def post(_uri, _body, _headers)
    response = @responses.shift
    raise response if response.is_a?(StandardError)

    response || raise('Unexpected chat request.')
  end
end
