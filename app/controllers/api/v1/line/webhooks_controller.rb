class Api::V1::Line::WebhooksController < Api::V1::Line::BaseController
  def callback
    body = request.body.read
    logger.info("[Log] body: #{body.inspect}")
    render plain: "OK"
  end
end
