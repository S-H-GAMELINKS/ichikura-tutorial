task :new_user => :environment do

    require 'mastodon'

    stream = Mastodon::Streaming::Client.new(base_url: ENV["MASTODON_URL"], bearer_token: ENV["MASTODON_ACCESS_TOKEN"])
    client = Mastodon::REST::Client.new(base_url: ENV["MASTODON_URL"], bearer_token: ENV["MASTODON_ACCESS_TOKEN"])
    
    stream.firehose() do |toot|
        if toot.uri.to_s =~ /#{ENV['MASTODON_URL'].to_s}/ then
            message = ("@S_H_@ichiji.social いちくらにようこそ！")
            response = client.create_status(message)
            exit
        end
    end
end

task :ltl_user_get => :environment do

    require 'mastodon'

    stream = Mastodon::Streaming::Client.new(base_url: ENV["MASTODON_URL"], bearer_token: ENV["MASTODON_ACCESS_TOKEN"])

    stream.firehose() do |toot|
        if User.where(:uid => "#{toot.account.acct}@ichiji.social").empty? == true then
            User.create!(:uid => "#{toot.account.acct}@ichiji.social")
        end
    end
end