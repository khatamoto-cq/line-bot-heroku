class Api::V1::Line::WebhooksController < Api::V1::Line::BaseController
  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']

    unless client.validate_signature(body, signature)
      return render json: { message: 'Bad Request'}, status: 400
    end

    events = client.parse_events_from(body)
    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = { type: 'text', text: event.message['text'] }
          response = client.reply_message(event['replyToken'], message)
        end
      end
    end

    render json: { message: 'ok' }, status: 200
  end
end
