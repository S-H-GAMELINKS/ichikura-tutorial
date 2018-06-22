#新規さん向けのいちくらWelcomeメンション
task :new_user_mention => :environment do

    # gem mastodon-api を読み込み
    require 'mastodon'

    # ストリーミングAPIとREAT API の使用
    stream = Mastodon::Streaming::Client.new(base_url: ENV["MASTODON_URL"], bearer_token: ENV["MASTODON_ACCESS_TOKEN"])
    client = Mastodon::REST::Client.new(base_url: ENV["MASTODON_URL"], bearer_token: ENV["MASTODON_ACCESS_TOKEN"])
    
    #public_timeline の取得
    stream.firehose() do |toot|
        # Toot情報を取得し、アカウントの作成日時を比較。そのうえで重複してメンションを送っていないか判定
        if toot.uri.to_s =~ /#{ENV['MASTODON_URL'].to_s}/ && toot.account.created_at >= DateTime.now.beginning_of_day && User.where(:uid => "#{toot.account.acct}@ichiji.social").empty? == true then

            #ご新規さん向けのWelcomeメンション
            message = ("@#{toot.account.acct}@ichiji.social いちくらにようこそ！\n 
                        このアカウントはいちくら初心者のためのbotです。\n 
                        初めての方にご案内します。\n\n 
                        詳しくはこちらのURLを参照ください。\n\n
                        http://urahito-solution.hatenablog.com/ichikura-tutorial")
            response = client.create_status(message)

            # 既にメンションを送った新規さんをDBに保存
            User.create!(:uid => "#{toot.account.acct}@ichiji.social")
            exit
        end
    end
end

# LTLのユーザーをDBに保管するタスク
task :ltl_user_get => :environment do

    # gem mastodon-apiの読み込み 
    require 'mastodon'

    # Streaming API の使用
    stream = Mastodon::Streaming::Client.new(base_url: ENV["MASTODON_URL"], bearer_token: ENV["MASTODON_ACCESS_TOKEN"])

    stream.firehose() do |toot|
        if toot.uri.to_s =~ /#{ENV['MASTODON_URL'].to_s}/ && User.where(:uid => "#{toot.account.acct}@ichiji.social").empty? == true then
            User.create!(:uid => "#{toot.account.acct}@ichiji.social")
        end
    end
end

task :singing => :environment do

    require 'mastodon'

    stream = Mastodon::Streaming::Client.new(base_url: ENV["MASTODON_URL"], bearer_token: ENV["MASTODON_ACCESS_TOKEN"])
    client = Mastodon::REST::Client.new(base_url: ENV["MASTODON_URL"], bearer_token: ENV["MASTODON_ACCESS_TOKEN"])
 
    bot_name = ENV['BOT_NAME']

    stream.firehose() do |toot|
        if toot.uri.to_s =~ /#{ENV['MASTODON_URL'].to_s}/ && toot.content =~ /#{bot_name}/ && toot.content =~ /歌って！/ then
            response = client.create_status("@#{toot.account.acct} さん\n でいじ～でいじ～ \n ぎぶみ～　ゆあ　あんさぁ　どぅ！\n")
        end
    end
end