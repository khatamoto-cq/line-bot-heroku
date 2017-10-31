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
      when Line::Bot::Event::Postback
        response = client.reply_message(event['replyToken'], {
          type: 'text',
          text: "Postback受信「#{event['postback']['data']}」"
        })
        logger.warn "Message send error: #{response.body}" unless response.is_a?(Net::HTTPOK)
        continue
      when Line::Bot::Event::Message
        case event.message['text']
        when 'テキスト'
          response = client.reply_message(event['replyToken'], { type: 'text', text: 'TextMessage' })
          logger.warn "Message send error: #{response.body}" unless response.is_a?(Net::HTTPOK)
        when '画像'
          response = client.reply_message(event['replyToken'], {
            type: 'image',
            originalContentUrl: request.base_url + '/imgs/original.jpg',
            previewImageUrl: request.base_url + '/imgs/preview.jpg'
          })
          logger.warn "Message send error: #{response.body}" unless response.is_a?(Net::HTTPOK)
        when '位置情報'
          response = client.reply_message(event['replyToken'], {
            type: 'location',
            title: 'LINE',
            address: '東京都渋谷区渋谷2-21-21ヒカリエ27階',
            latitude: 35.659025, longitude: 139.703473
          })
          logger.warn "Message send error: #{response.body}" unless response.is_a?(Net::HTTPOK)
        when 'スタンプ'
          response = client.reply_message(event['replyToken'], { type: 'sticker',
            packageId: 1, stickerId: 1 })
          logger.warn "Message send error: #{response.body}" unless response.is_a?(Net::HTTPOK)
        when '動画'
          response = client.reply_message(event['replyToken'], {
            type: 'video',
            originalContentUrl: request.base_url + '/videos/sample.mp4',
            previewImageUrl: request.base_url + '/videos/sample_preview.jpg'
          })
          logger.warn "Message send error: #{response.body}" unless response.is_a?(Net::HTTPOK)
        when 'オーディオ'
          response = client.reply_message(event['replyToken'], {
            type: 'audio',
            originalContentUrl: request.base_url + '/audios/sample.m4a',
            duration: 6000
          })
          logger.warn "Message send error: #{response.body}" unless response.is_a?(Net::HTTPOK)
        when 'ボタンテンプレート'
          response = client.reply_message(event['replyToken'], {
            type: 'template',
            altText: '代替テンプレート',
            template: {
              type: 'buttons',
              thumbnailImageUrl: request.base_url + '/imgs/template.jpg',
              title: 'お天気お知らせ',
              text: '今日は天気予報は晴れです',
              actions: [
                {
                  type: 'message',
                  label: '明日の天気',
                  text: 'tomorrow'
                }, {
                  type: 'postback',
                  label: '週末の天気',
                  data: 'weekend'
                }, {
                  type: 'uri',
                  label: 'Webで見る',
                  uri: 'http://google.jp'
                }
              ]
            }
          })
          logger.warn "Message send error: #{response.body}" unless response.is_a?(Net::HTTPOK)
        end
      end
    end

    render json: { message: 'ok' }, status: 200
  end
end
